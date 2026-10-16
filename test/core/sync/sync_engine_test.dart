import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vera_n/core/sync/sync_engine.dart';

/// Runs the real engine (fetched by tool/fetch_sync_engine.ps1) in a
/// temporary folder. Skipped where it hasn't been fetched.
void main() {
  final binary = p.join('windows', 'sync_engine', 'syncthing.exe');
  final available = Platform.isWindows && File(binary).existsSync();

  test(
    'starts with its own folder, on localhost, with everything that would '
    'leave the home network switched off, and stops',
    () async {
      final home = await Directory.systemTemp.createTemp('vera_n_engine');
      final engine = SyncEngine(
        binary: File(binary).absolute.path,
        home: home.path,
      );
      try {
        final api = await engine.start();
        expect(await api.healthy(), isTrue);
        expect(
          await api.myId(),
          matches(RegExp(r'^[A-Z0-9]{7}(-[A-Z0-9]{7}){7}$')),
        );
        final options = await api.getOptions();
        expect(options['relaysEnabled'], isFalse);
        expect(options['globalAnnounceEnabled'], isFalse);
        expect(options['natEnabled'], isFalse);
        expect(options['urAccepted'], -1);
        expect(options['crashReportingEnabled'], isFalse);
        expect(options['localAnnounceEnabled'], isTrue);
        expect(await api.folders(), isEmpty, reason: 'no default folder');
        await engine.stop();
        expect(engine.running, isFalse);
        expect(await api.healthy(), isFalse);
      } finally {
        await engine.stop();
        await home.delete(recursive: true);
      }
    },
    skip: available ? false : 'sync engine not fetched',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
