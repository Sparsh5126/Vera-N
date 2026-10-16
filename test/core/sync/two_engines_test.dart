import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vera_n/core/sync/pairing_code.dart';
import 'package:vera_n/core/sync/pairing_exchange.dart';
import 'package:vera_n/core/sync/sync_engine.dart';
import 'package:vera_n/core/sync/sync_setup.dart';

/// Two real engines on this computer, paired with the real pairing code
/// over loopback: a note written in one folder reaches the other, both
/// ways. Skipped where the engine hasn't been fetched.
void main() {
  final binary = File(p.join('windows', 'sync_engine', 'syncthing.exe'))
      .absolute
      .path;
  final available = Platform.isWindows && File(binary).existsSync();

  test(
    'pair, then sync both ways',
    () async {
      final tmp = await Directory.systemTemp.createTemp('vera_n_two');
      final laptopFolder = Directory(p.join(tmp.path, 'laptop'))..createSync();
      final phoneFolder = Directory(p.join(tmp.path, 'phone'))..createSync();
      final laptop = SyncEngine(binary: binary, home: p.join(tmp.path, 'le'));
      final phone = SyncEngine(binary: binary, home: p.join(tmp.path, 'pe'));
      try {
        final la = await laptop.start();
        final pa = await phone.start();
        final words = File('assets/pairing/words_en.txt')
            .readAsLinesSync()
            .where((w) => w.isNotEmpty)
            .toList();
        final host = PairingHost(
          code: PairingCode.random(words),
          laptopId: await la.myId(),
          name: 'Laptop',
          syncPort: (await la.listenPort())!,
          findPort: 23999,
          onPhone: (d) => SyncSetup(la).pair(
            PairedDevice(
              id: d.id,
              name: d.name,
              address: '127.0.0.1',
              syncPort: d.syncPort,
            ),
            folderPath: laptopFolder.path,
          ),
        );
        final invite = await host.open();
        final local = PairingInvite(
          code: invite.code,
          addresses: ['127.0.0.1'],
          port: invite.port,
        );
        final found = await PairingGuest.join(
          code: local.code,
          invite: local,
          phoneId: await pa.myId(),
          name: 'Phone',
          syncPort: (await pa.listenPort())!,
        );
        await SyncSetup(pa).pair(found, folderPath: phoneFolder.path);
        expect((await SyncSetup(la).peer())!.name, 'Phone');
        expect((await SyncSetup(pa).peer())!.name, 'Laptop');

        File(p.join(laptopFolder.path, 'Notes', 'Trek.md'))
          ..createSync(recursive: true)
          ..writeAsStringSync('Triund in spring.');
        await _until(
          () => File(p.join(phoneFolder.path, 'Notes', 'Trek.md')).existsSync(),
        );
        File(p.join(phoneFolder.path, 'Notes', 'Back.md'))
            .writeAsStringSync('Written on the phone.');
        await _until(
          () =>
              File(p.join(laptopFolder.path, 'Notes', 'Back.md')).existsSync(),
        );
        expect(
          File(p.join(laptopFolder.path, 'Notes', 'Back.md'))
              .readAsStringSync(),
          'Written on the phone.',
        );

        await SyncSetup(pa).unpair();
        expect(await SyncSetup(pa).peer(), isNull);
      } finally {
        await laptop.stop();
        await phone.stop();
        try {
          await tmp.delete(recursive: true);
        } on FileSystemException {
          // The engine may still hold its database for a moment.
        }
      }
    },
    skip: available ? false : 'sync engine not fetched',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

Future<void> _until(bool Function() done) async {
  for (var i = 0; i < 120; i++) {
    if (done()) return;
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  fail('timed out waiting for sync');
}
