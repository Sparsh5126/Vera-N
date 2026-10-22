import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vera_n/core/sync/pairing_code.dart';
import 'package:vera_n/core/sync/pairing_exchange.dart';
import 'package:vera_n/core/sync/sync_engine.dart';
import 'package:vera_n/core/sync/sync_setup.dart';
import 'package:vera_n/core/sync/syncthing_api.dart';

/// Two real sync engines on this computer, a laptop and a phone, each
/// sharing its own folder. Tests using it are skipped where the engine
/// hasn't been fetched ([available]).
class EnginePair {
  EnginePair._(this.tmp)
    : laptopFolder = Directory(p.join(tmp.path, 'laptop'))..createSync(),
      phoneFolder = Directory(p.join(tmp.path, 'phone'))..createSync(),
      laptop = SyncEngine(binary: binary, home: p.join(tmp.path, 'le')),
      phone = SyncEngine(binary: binary, home: p.join(tmp.path, 'pe'));

  static final binary = File(p.join('windows', 'sync_engine', 'syncthing.exe'))
      .absolute
      .path;
  static final available = Platform.isWindows && File(binary).existsSync();

  static Future<EnginePair> create() async =>
      EnginePair._(await Directory.systemTemp.createTemp('vera_n_two'));

  final Directory tmp;
  final Directory laptopFolder;
  final Directory phoneFolder;
  final SyncEngine laptop;
  final SyncEngine phone;
  late SyncthingApi laptopApi;
  late SyncthingApi phoneApi;

  File laptopFile(String path) => File(p.join(laptopFolder.path, path));
  File phoneFile(String path) => File(p.join(phoneFolder.path, path));

  /// Starts both engines and pairs them with the real pairing code over
  /// loopback.
  Future<void> pair() async {
    laptopApi = await laptop.start();
    phoneApi = await phone.start();
    final words = File('assets/pairing/words_en.txt')
        .readAsLinesSync()
        .where((w) => w.isNotEmpty)
        .toList();
    final host = PairingHost(
      code: PairingCode.random(words),
      laptopId: await laptopApi.myId(),
      name: 'Laptop',
      syncPort: (await laptopApi.listenPort())!,
      findPort: 23999,
      onPhone: (d) => SyncSetup(laptopApi).pair(
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
      phoneId: await phoneApi.myId(),
      name: 'Phone',
      syncPort: (await phoneApi.listenPort())!,
    );
    await SyncSetup(phoneApi).pair(found, folderPath: phoneFolder.path);
  }

  Future<void> dispose() async {
    await laptop.stop();
    await phone.stop();
    try {
      await tmp.delete(recursive: true);
    } on FileSystemException {
      // The engine may still hold its database for a moment.
    }
  }

  /// Waits up to two minutes for [done].
  static Future<void> until(bool Function() done) async {
    for (var i = 0; i < 120; i++) {
      if (done()) return;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    fail('timed out waiting for sync');
  }
}
