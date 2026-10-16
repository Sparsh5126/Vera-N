import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// The engine didn't answer or refused a request.
class SyncEngineError implements Exception {
  const SyncEngineError(this.reason);

  final String reason;

  @override
  String toString() => 'SyncEngineError($reason)';
}

/// Talks to the sync engine Vera N runs (Syncthing; docs/LAPTOP_PLAN.md,
/// S1) through its local API: on 127.0.0.1 only, with the random key Vera
/// N gave it at start. Nothing here reaches the network.
class SyncthingApi {
  SyncthingApi({required this.port, required this.apiKey});

  final int port;
  final String apiKey;
  static const _timeout = Duration(seconds: 10);
  final HttpClient _http = HttpClient()..findProxy = ((_) => 'DIRECT');

  /// Whether it is up and answering.
  Future<bool> healthy() async {
    try {
      final json = await _call('GET', '/rest/noauth/health');
      return json is Map && json['status'] == 'OK';
    } on Object {
      return false;
    }
  }

  /// This device's id (what the other device adds).
  Future<String> myId() async =>
      (await _map('GET', '/rest/system/status'))['myID'] as String;

  Future<Map<String, Object?>> getOptions() =>
      _map('GET', '/rest/config/options');

  /// The TCP port it accepts other devices on (for the pairing reply).
  Future<int?> listenPort() async {
    final status = await _map('GET', '/rest/system/status');
    final services = status['connectionServiceStatus'];
    if (services is! Map) return null;
    for (final key in services.keys) {
      final m = RegExp(r'^tcp://[^ ]*:(\d+)$').firstMatch('$key');
      if (m != null) return int.parse(m.group(1)!);
    }
    return null;
  }

  /// Changes the engine's options (only the given keys).
  Future<void> setOptions(Map<String, Object?> options) =>
      _call('PATCH', '/rest/config/options', options);

  Future<List<Map<String, Object?>>> devices() => _list('/rest/config/devices');

  Future<void> putDevice(Map<String, Object?> device) =>
      _call('PUT', '/rest/config/devices/${device['deviceID']}', device);

  Future<void> removeDevice(String id) =>
      _call('DELETE', '/rest/config/devices/$id');

  Future<List<Map<String, Object?>>> folders() => _list('/rest/config/folders');

  Future<void> putFolder(Map<String, Object?> folder) =>
      _call('PUT', '/rest/config/folders/${folder['id']}', folder);

  Future<void> removeFolder(String id) =>
      _call('DELETE', '/rest/config/folders/$id');

  /// Connection state per device id.
  Future<Map<String, Object?>> connections() async =>
      ((await _map('GET', '/rest/system/connections'))['connections'] as Map)
          .cast<String, Object?>();

  /// A folder's state: `idle`, `scanning`, `syncing`, … and what it needs.
  Future<Map<String, Object?>> folderStatus(String id) =>
      _map('GET', '/rest/db/status?folder=${Uri.encodeQueryComponent(id)}');

  /// When each device was last connected.
  Future<Map<String, Object?>> deviceStats() =>
      _map('GET', '/rest/stats/device');

  /// Events after [since], waiting up to [wait] for one (long poll).
  Future<List<Map<String, Object?>>> events({
    required int since,
    Duration wait = const Duration(seconds: 30),
  }) async {
    final json = await _call(
      'GET',
      '/rest/events?since=$since&timeout=${wait.inSeconds}',
      null,
      wait + _timeout,
    );
    return [for (final e in json as List) (e as Map).cast<String, Object?>()];
  }

  Future<void> shutdown() => _call('POST', '/rest/system/shutdown');

  void close() => _http.close(force: true);

  Future<List<Map<String, Object?>>> _list(String path) async => [
    for (final e in await _call('GET', path) as List)
      (e as Map).cast<String, Object?>(),
  ];

  Future<Map<String, Object?>> _map(String method, String path) async =>
      ((await _call(method, path)) as Map).cast<String, Object?>();

  Future<Object?> _call(
    String method,
    String path, [
    Object? body,
    Duration timeout = _timeout,
  ]) async {
    try {
      final request = await _http
          .openUrl(method, Uri.parse('http://127.0.0.1:$port$path'))
          .timeout(timeout);
      request
        ..followRedirects = false
        ..headers.set('X-API-Key', apiKey);
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(body)));
      }
      final response = await request.close().timeout(timeout);
      final text = await utf8.decodeStream(response).timeout(timeout);
      if (response.statusCode >= 300) {
        throw SyncEngineError('status ${response.statusCode}: $text');
      }
      return text.isEmpty ? null : jsonDecode(text);
    } on SocketException catch (e) {
      throw SyncEngineError(e.message);
    } on TimeoutException {
      throw const SyncEngineError('timed out');
    } on FormatException {
      throw const SyncEngineError('not JSON');
    }
  }
}
