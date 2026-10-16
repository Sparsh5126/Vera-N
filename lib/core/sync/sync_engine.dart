import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../platform/launch_channel.dart';
import 'syncthing_api.dart';

/// The sync engine Vera N ships and runs (Syncthing, MPL-2.0;
/// docs/LAPTOP_PLAN.md, S1). Started only while Vera N is open, with its
/// own private folder, a random API key and its page on 127.0.0.1 only.
/// Everything that would reach past the user's own network is switched
/// off: internet relays, global discovery, NAT port opening, usage and
/// crash reports, upgrades. Only local discovery stays on.
class SyncEngine {
  SyncEngine({required this.binary, required this.home});

  final String binary;

  /// The engine's own config, keys and database (never the notes).
  final String home;

  Process? _process;
  SyncthingApi? _api;
  final _log = <String>[];

  /// What the engine may do (applied at every start).
  static const options = <String, Object?>{
    'relaysEnabled': false,
    'globalAnnounceEnabled': false,
    'localAnnounceEnabled': true,
    'natEnabled': false,
    'urAccepted': -1,
    'crashReportingEnabled': false,
    'autoUpgradeIntervalH': 0,
    'startBrowser': false,
  };

  /// The engine on this device, or null where none is shipped (a build
  /// without it, tests).
  static Future<SyncEngine?> forThisDevice() async {
    final String? binary;
    if (Platform.isWindows) {
      binary = p.join(p.dirname(Platform.resolvedExecutable), 'syncthing.exe');
    } else if (Platform.isAndroid) {
      final dir = await LaunchChannel.nativeLibraryDir();
      binary = dir == null ? null : p.join(dir, 'libsyncthingnative.so');
    } else {
      binary = null;
    }
    if (binary == null || !File(binary).existsSync()) return null;
    final support = await getApplicationSupportDirectory();
    return SyncEngine(
      binary: binary,
      home: p.join(support.path, 'sync_engine'),
    );
  }

  bool get running => _process != null;
  SyncthingApi? get api => _api;

  /// The last lines the engine printed, for diagnosing a failed start.
  List<String> get log => List.unmodifiable(_log);

  /// Starts it (if not running) and returns its API once it answers.
  Future<SyncthingApi> start() async {
    final running = _api;
    if (running != null && await running.healthy()) return running;
    await Directory(home).create(recursive: true);
    if (!File(p.join(home, 'config.xml')).existsSync()) await _generate();
    final port = await _freePort();
    final key = _randomKey();
    final process = await Process.start(binary, [
      'serve',
      '--home=$home',
      '--no-browser',
      '--no-restart',
      '--no-upgrade',
      '--gui-address=http://127.0.0.1:$port',
      '--gui-apikey=$key',
    ], environment: _environment);
    _process = process;
    _drain(process);
    unawaited(process.exitCode.then((_) => _process = null));
    final api = SyncthingApi(port: port, apiKey: key);
    _api = api;
    await _waitUntilUp(api);
    await api.setOptions(options);
    return api;
  }

  /// Asks it to stop, and ends it if it doesn't within a few seconds.
  Future<void> stop() async {
    final process = _process;
    final api = _api;
    _api = null;
    if (process == null) return;
    try {
      await api?.shutdown();
    } on SyncEngineError {
      // Not answering: ended below.
    }
    api?.close();
    final exited = await process.exitCode.timeout(
      const Duration(seconds: 5),
      onTimeout: () => -1,
    );
    if (exited == -1) process.kill();
    _process = null;
  }

  Map<String, String> get _environment => {
    'STNOUPGRADE': '1',
    'STNODEFAULTFOLDER': '1',
    'HOME': home,
    'TMPDIR': p.join(home, 'tmp'),
  };

  Future<void> _generate() async {
    await Directory(p.join(home, 'tmp')).create(recursive: true);
    // Port probing stays on: another Syncthing on the same computer keeps
    // its port, and this one takes a free one.
    final result = await Process.run(binary, [
      'generate',
      '--home=$home',
    ], environment: _environment);
    if (result.exitCode != 0) {
      throw SyncEngineError('generate failed: ${result.stderr}');
    }
  }

  Future<void> _waitUntilUp(SyncthingApi api) async {
    for (var i = 0; i < 40; i++) {
      if (_process == null) {
        throw SyncEngineError('engine exited: ${_log.join(' | ')}');
      }
      if (await api.healthy()) return;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw const SyncEngineError('engine did not start');
  }

  void _drain(Process process) {
    void keep(String line) {
      _log.add(line);
      if (_log.length > 50) _log.removeAt(0);
      if (line.contains('WRN') || line.contains('ERR')) {
        debugPrint('VeraN sync engine: $line');
      }
    }

    for (final stream in [process.stdout, process.stderr]) {
      stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(keep);
    }
  }

  static Future<int> _freePort() async {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  static String _randomKey() {
    final r = Random.secure();
    return [for (var i = 0; i < 32; i++) r.nextInt(16).toRadixString(16)]
        .join();
  }
}
