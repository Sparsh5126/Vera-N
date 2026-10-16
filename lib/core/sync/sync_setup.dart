import 'pairing_exchange.dart';
import 'syncthing_api.dart';

/// The one paired device, as the engine's config holds it.
class SyncPeer {
  const SyncPeer({required this.id, required this.name});

  final String id;
  final String name;
}

/// Puts a pairing into the engine's config (docs/LAPTOP_PLAN.md, S2–S3):
/// the other device, reached at the address pairing found (and by local
/// discovery), and the one shared folder. The config is the only record
/// of the pairing, so unpairing is removing both.
class SyncSetup {
  SyncSetup(this.api);

  static const folderId = 'vera-n-notes';

  final SyncthingApi api;

  Future<void> pair(PairedDevice other, {required String folderPath}) async {
    final me = await api.myId();
    await api.putDevice({
      'deviceID': other.id,
      'name': other.name,
      'addresses': ['tcp://${other.address}:${other.syncPort}', 'dynamic'],
      'autoAcceptFolders': false,
      'paused': false,
    });
    await api.putFolder({
      'id': folderId,
      'label': 'Vera N',
      'path': folderPath,
      'type': 'sendreceive',
      'devices': [
        {'deviceID': me},
        {'deviceID': other.id},
      ],
      'fsWatcherEnabled': true,
      'fsWatcherDelayS': 2,
      'rescanIntervalS': 600,
      'ignorePerms': true,
      'paused': false,
    });
  }

  /// The paired device, or null when there is none.
  Future<SyncPeer?> peer() async {
    final me = await api.myId();
    for (final d in await api.devices()) {
      if (d['deviceID'] != me) {
        return SyncPeer(
          id: d['deviceID'] as String,
          name: (d['name'] as String?)?.trim().isNotEmpty == true
              ? d['name'] as String
              : 'Paired device',
        );
      }
    }
    return null;
  }

  Future<void> unpair() async {
    if ((await api.folders()).any((f) => f['id'] == folderId)) {
      await api.removeFolder(folderId);
    }
    final me = await api.myId();
    for (final d in await api.devices()) {
      final id = d['deviceID'] as String;
      if (id != me) await api.removeDevice(id);
    }
  }
}
