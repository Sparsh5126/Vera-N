import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'ai_server_address.dart';

/// The server didn't answer, or answered with something unusable. Normal
/// when it isn't running: the booster just waits for a later idle spell.
class AiServerUnavailable implements Exception {
  const AiServerUnavailable(this.reason);

  final String reason;

  @override
  String toString() => 'AiServerUnavailable($reason)';
}

/// Talks to a local OpenAI-compatible server (LM Studio, Ollama,
/// llama.cpp) for the laptop booster (docs/LAPTOP_PLAN.md, L2).
///
/// Every request goes to the address [AiServerAddress.resolve] approved:
/// no proxy, no redirects, so note text can't be carried elsewhere.
class AiServerClient {
  AiServerClient(this.address, {Duration? answerTimeout})
    : answerTimeout = answerTimeout ?? const Duration(minutes: 2);

  static const connectTimeout = Duration(seconds: 3);
  static const _maxReply = 1 << 20;
  static final _thinking = RegExp(r'<think>[\s\S]*?</think>');

  final AiServerAddress address;

  /// A local model can be slow; a reply taking longer than this is given
  /// up on.
  final Duration answerTimeout;

  final HttpClient _http = HttpClient()
    ..connectionTimeout = connectTimeout
    ..findProxy = ((_) => 'DIRECT');

  /// The models the server offers, by id. Also the connection test.
  Future<List<String>> models() async {
    final json = await _send('GET', '/models', null, connectTimeout * 2);
    final data = json['data'];
    if (data is! List) throw const AiServerUnavailable('no model list');
    return [
      for (final m in data)
        if (m is Map && m['id'] is String) m['id'] as String,
    ];
  }

  /// One chat turn: [system] sets the job, [user] carries the note text.
  /// Returns the reply text, without any `<think>` reasoning.
  Future<String> chat({
    required String model,
    required String system,
    required String user,
    int maxTokens = 200,
  }) async {
    final json = await _send('POST', '/chat/completions', {
      'model': model,
      'messages': [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': user},
      ],
      'temperature': 0.2,
      'max_tokens': maxTokens,
      'stream': false,
    }, answerTimeout);
    final choices = json['choices'];
    final message = choices is List && choices.isNotEmpty
        ? choices.first['message']
        : null;
    final content = message is Map ? message['content'] : null;
    if (content is! String) throw const AiServerUnavailable('no reply');
    return content.replaceAll(_thinking, '').trim();
  }

  void close() => _http.close(force: true);

  Future<Map<String, Object?>> _send(
    String method,
    String path,
    Map<String, Object?>? body,
    Duration timeout,
  ) async {
    final target = await _target(path);
    try {
      return await _exchange(method, target, body).timeout(timeout);
    } on TimeoutException {
      throw const AiServerUnavailable('timed out');
    } on SocketException catch (e) {
      throw AiServerUnavailable(e.message);
    } on HttpException catch (e) {
      throw AiServerUnavailable(e.message);
    } on FormatException {
      throw const AiServerUnavailable('not JSON');
    }
  }

  /// The URL to call. Plain http goes to the checked IP itself (with the
  /// original Host header), so the name can't be re-pointed in between.
  Future<Uri> _target(String path) async {
    final ip = await address.resolve();
    final uri = address.uri;
    final full = uri.replace(path: '${uri.path}$path');
    return uri.scheme == 'http' ? full.replace(host: ip.address) : full;
  }

  Future<Map<String, Object?>> _exchange(
    String method,
    Uri target,
    Map<String, Object?>? body,
  ) async {
    final request = await _http.openUrl(method, target);
    request
      ..followRedirects = false
      ..headers.host = address.uri.host
      ..headers.port = address.uri.port;
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode(body)));
    }
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw AiServerUnavailable('status ${response.statusCode}');
    }
    final bytes = <int>[];
    await for (final part in response) {
      bytes.addAll(part);
      if (bytes.length > _maxReply) {
        throw const AiServerUnavailable('reply too long');
      }
    }
    final json = jsonDecode(utf8.decode(bytes));
    if (json is! Map<String, Object?>) {
      throw const AiServerUnavailable('unexpected reply');
    }
    return json;
  }
}
