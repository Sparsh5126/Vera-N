import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../platform/device_kind.dart';
import '../storage/files/io_note_file_store.dart';
import '../storage/storage_services.dart';
import 'mirror_bridge.dart';
import 'pairing_code.dart';
import 'pairing_exchange.dart';
import 'sync_engine.dart';
import 'sync_setup.dart';
import 'sync_status.dart';
import 'syncthing_api.dart';

/// Built-in sync (docs/LAPTOP_PLAN.md, S): runs the engine while paired
/// (or pairing) and Vera N is open, stopping a minute after it is left.
/// The laptop shares its notes folder itself; the phone shares a private
/// mirror that [MirrorBridge] keeps level with the user's folder.
class SyncService {
  SyncService(this._storage, this._engine);

  /// The service, or one that is always [SyncState.unavailable] where no
  /// engine ships.
  static Future<SyncService> open(StorageServices storage) async =>
      SyncService(storage, await SyncEngine.forThisDevice());

  static const stopAfter = Duration(minutes: 1);
  static const bridgeEvery = Duration(seconds: 20);

  final StorageServices _storage;
  final SyncEngine? _engine;
  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _last = const SyncStatus(SyncState.unavailable);
  Timer? _stopTimer;
  Timer? _tick;
  MirrorBridge? _bridge;
  List<String>? _words;
  bool _bridging = false;

  /// Pairing in progress: the engine stays up even while not paired yet.
  var _pairing = 0;

  Stream<SyncStatus> get status => _status.stream;
  SyncStatus get current => _last;

  /// App opened or back in front: start if paired.
  Future<void> resume() async {
    _stopTimer?.cancel();
    final engine = _engine;
    if (engine == null) return _emit(const SyncStatus(SyncState.unavailable));
    try {
      final api = await engine.start();
      final peer = await SyncSetup(api).peer();
      if (peer == null) {
        if (_pairing == 0) await engine.stop();
        return _emit(const SyncStatus(SyncState.notPaired));
      }
      _startTicking();
      await _refresh();
    } on Object catch (e) {
      debugPrint('VeraN sync: could not start: $e');
      _emit(const SyncStatus(SyncState.problem));
    }
  }

  /// App left: stop after [stopAfter] (a quick return keeps it running).
  /// A laptop keeps syncing while Vera N runs, minimised or not.
  void pause() {
    if (DeviceKind.isDesktop || _pairing > 0) return;
    _stopTimer?.cancel();
    _stopTimer = Timer(stopAfter, () => unawaited(_stop()));
  }

  /// Laptop: opens a pairing window and returns what to show. The phone is
  /// added when it answers; [PairingSession.result] completes then.
  Future<PairingSession> hostPairing() async {
    _pairing++;
    final SyncthingApi api;
    try {
      api = await _engine!.start();
    } on Object {
      _pairing--;
      rethrow;
    }
    final setup = SyncSetup(api);
    final host = PairingHost(
      code: PairingCode.random(await _wordList()),
      laptopId: await api.myId(),
      name: Platform.localHostname,
      syncPort: await api.listenPort() ?? 22000,
      onPhone: (phone) async {
        await setup.unpair();
        await setup.pair(phone, folderPath: await _sharedPath());
      },
    );
    final invite = await host.open();
    final result = host.result.then((phone) async {
      _pairing--;
      await resume();
      return phone;
    });
    return PairingSession(invite: invite, result: result, cancel: host.close);
  }

  /// Phone: joins the laptop shown by a scanned QR code or typed words.
  Future<PairedDevice> join({PairingCode? code, PairingInvite? invite}) async {
    _pairing++;
    try {
      final api = await _engine!.start();
      final laptop = await PairingGuest.join(
        code: invite?.code ?? code!,
        invite: invite,
        phoneId: await api.myId(),
        name: 'Phone',
        syncPort: await api.listenPort() ?? 22000,
      );
      final setup = SyncSetup(api);
      await setup.unpair();
      await setup.pair(laptop, folderPath: await _sharedPath());
      return laptop;
    } finally {
      _pairing--;
      await resume();
    }
  }

  /// Vera N is quitting: the engine it started quits too.
  Future<void> shutdown() => _stop();

  Future<void> unpair() async {
    final engine = _engine;
    if (engine == null) return;
    await SyncSetup(await engine.start()).unpair();
    await _stop();
    _emit(const SyncStatus(SyncState.notPaired));
  }

  /// Words for typing in: the list the code is drawn from.
  Future<List<String>> wordList() => _wordList();

  Future<List<String>> _wordList() async => _words ??= [
    for (final w in (await rootBundle.loadString(
      'assets/pairing/words_en.txt',
    )).split('\n'))
      if (w.trim().isNotEmpty) w.trim(),
  ];

  /// The folder the engine shares: the laptop's notes folder (or its
  /// private one), or the phone's mirror.
  Future<String> _sharedPath() async {
    final support = (await getApplicationSupportDirectory()).path;
    if (DeviceKind.isPhone) return p.join(support, 'sync_mirror');
    return await _storage.settings.notesFolder() ?? p.join(support, 'MyNotes');
  }

  void _startTicking() {
    _tick?.cancel();
    _tick = Timer.periodic(bridgeEvery, (_) => unawaited(_refresh()));
  }

  Future<void> _refresh() async {
    final api = _engine?.api;
    if (api == null) return;
    if (DeviceKind.isPhone) await _runBridge();
    try {
      final peer = await SyncSetup(api).peer();
      if (peer == null) return _emit(const SyncStatus(SyncState.notPaired));
      final connections = await api.connections();
      final connected = (connections[peer.id] as Map?)?['connected'] == true;
      final seen = (await api.deviceStats())[peer.id] as Map?;
      final last = DateTime.tryParse('${seen?['lastSeen']}');
      _emit(
        SyncStatus(
          connected ? SyncState.connected : SyncState.waiting,
          peerName: peer.name,
          lastSynced: last == null || last.year < 2000 ? null : last.toLocal(),
        ),
      );
    } on Object catch (e) {
      debugPrint('VeraN sync: status failed: $e');
    }
  }

  /// Phone: levels the mirror and the user's folder; what came in is
  /// indexed at once.
  Future<void> _runBridge() async {
    if (_bridging) return;
    _bridging = true;
    try {
      final support = (await getApplicationSupportDirectory()).path;
      final mirror = p.join(support, 'sync_mirror');
      final bridge = _bridge ??= MirrorBridge(
        folder: _storage.store,
        mirror: IoNoteFileStore(Directory(p.join(mirror, 'Notes'))),
        stateFile: File(p.join(support, 'sync_bridge.json')),
      );
      final report = await bridge.run();
      if (report.changedFolder) {
        await _storage.reconcile();
        await _storage.afterOutsideChanges?.call();
      }
    } on Object catch (e) {
      debugPrint('VeraN sync: mirror failed: $e');
    } finally {
      _bridging = false;
    }
  }

  Future<void> _stop() async {
    _tick?.cancel();
    if (DeviceKind.isPhone && _engine?.api != null) await _runBridge();
    await _engine?.stop();
  }

  void _emit(SyncStatus s) {
    _last = s;
    _status.add(s);
  }
}

/// An open pairing window on the laptop.
class PairingSession {
  const PairingSession({
    required this.invite,
    required this.result,
    required this.cancel,
  });

  final PairingInvite invite;

  /// The phone once paired, or null when the window closed.
  final Future<PairedDevice?> result;
  final Future<void> Function() cancel;
}
