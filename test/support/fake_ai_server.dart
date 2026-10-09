import 'dart:convert';
import 'dart:io';

/// A stand-in for LM Studio on a free loopback port.
class FakeServer {
  late final HttpServer _server;
  final requests = <(String, String, Map<String, Object?>?, String?)>[];
  Object? Function(String path, Map<String, Object?>? body)? reply;
  int status = 200;
  String? redirectTo;

  int get port => _server.port;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((r) async {
      final text = await utf8.decodeStream(r);
      final body = text.isEmpty
          ? null
          : jsonDecode(text) as Map<String, Object?>;
      requests.add((r.method, r.uri.path, body, r.headers.host));
      if (redirectTo != null) {
        r.response.statusCode = HttpStatus.found;
        r.response.headers.set('location', redirectTo!);
      } else {
        r.response.statusCode = status;
        r.response.write(jsonEncode(reply?.call(r.uri.path, body) ?? {}));
      }
      await r.response.close();
    });
  }

  Future<void> stop() => _server.close(force: true);

  /// Chat requests so far, as (system prompt, user text).
  List<(String, String)> get chats => [
    for (final (_, path, body, _) in requests)
      if (path.endsWith('/chat/completions'))
        (
          (body!['messages'] as List).first['content'] as String,
          (body['messages'] as List).last['content'] as String,
        ),
  ];

  /// Answers like a chat server: the model list, and [answer]'s reply to
  /// each chat turn (by its system prompt).
  void chatWith(String Function(String system, String user) answer) {
    reply = (path, body) {
      if (path.endsWith('/models')) {
        return {
          'data': [
            {'id': 'text-embedding-nomic'},
            {'id': 'gemma-4'},
          ],
        };
      }
      final messages = body!['messages'] as List;
      final text = answer(
        messages.first['content'] as String,
        messages.last['content'] as String,
      );
      return {
        'choices': [
          {
            'message': {'content': text},
          },
        ],
      };
    };
  }
}
