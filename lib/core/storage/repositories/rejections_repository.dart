import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/rejection.dart';
import '../db/app_database.dart';
import '../files/note_file_store.dart';

/// Rejected suggestions (product spec §8): in the database, and appended to
/// this device's `MyNotes/.app/rejections-<deviceid>.jsonl` so they survive
/// uninstall and reach other devices. Each device writes only its own file.
class RejectionsRepository {
  RejectionsRepository(this._db, this._store);

  final AppDatabase _db;
  final NoteFileStore _store;

  static String fileName(String deviceId) => 'rejections-$deviceId.jsonl';

  Future<void> add(Rejection r) async {
    await _db
        .into(_db.rejections)
        .insertOnConflictUpdate(
          RejectionsCompanion.insert(
            pairKey: r.pairKey,
            noteA: r.noteA,
            hashA: r.hashA,
            noteB: r.noteB,
            hashB: r.hashB,
            signatureA: Value(r.signatureA),
            signatureB: Value(r.signatureB),
            rejectedAt: r.rejectedAt,
            deviceId: r.deviceId,
          ),
        );
    final name = fileName(r.deviceId);
    final old = await _store.readAppFile(name) ?? '';
    await _store.writeAppFile(name, '$old${jsonEncode(r.toFileJson())}\n');
  }

  /// Undo for [add]: forgets the pair and takes its lines out of this
  /// device's file.
  Future<void> remove(String pairKey, String deviceId) async {
    await (_db.delete(
      _db.rejections,
    )..where((r) => r.pairKey.equals(pairKey))).go();
    final name = fileName(deviceId);
    final old = await _store.readAppFile(name);
    if (old == null) return;
    final kept = const LineSplitter()
        .convert(old)
        .where((l) => l.trim().isNotEmpty && !_isPair(l, pairKey));
    await _store.writeAppFile(name, kept.map((l) => '$l\n').join());
  }

  /// Every remembered rejection (kept by "Reset" for its Undo).
  Future<List<Rejection>> all() async {
    final rows = await _db.select(_db.rejections).get();
    return [
      for (final r in rows)
        Rejection(
          noteA: r.noteA,
          hashA: r.hashA,
          noteB: r.noteB,
          hashB: r.hashB,
          rejectedAt: r.rejectedAt,
          deviceId: r.deviceId,
          signatureA: r.signatureA,
          signatureB: r.signatureB,
        ),
    ];
  }

  /// Forgets every rejection ("Reset rejected suggestions") and empties
  /// this device's file.
  Future<void> clear(String deviceId) async {
    await _db.delete(_db.rejections).go();
    final name = fileName(deviceId);
    if (await _store.readAppFile(name) != null) {
      await _store.writeAppFile(name, '');
    }
  }

  static bool _isPair(String line, String pairKey) {
    try {
      return (jsonDecode(line) as Map)['pairKey'] == pairKey;
    } on FormatException {
      return false;
    }
  }
}
