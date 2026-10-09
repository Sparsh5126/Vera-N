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

  static final _file = RegExp(r'^rejections-[A-Za-z0-9]+\.jsonl$');

  /// Reads every device's rejections file in `.app/` into the database,
  /// so rejections survive uninstall (this device's file) and reach this
  /// device (others' files, once sync exists). Pairs already known keep
  /// their row, including the word fingerprints only the database holds.
  /// Damaged lines are skipped. Returns how many pairs were new.
  Future<int> importFiles() async {
    final before = await _count();
    for (final name in await _store.listAppFiles()) {
      if (!_file.hasMatch(name)) continue;
      final text = await _store.readAppFile(name) ?? '';
      for (final line in const LineSplitter().convert(text)) {
        final r = _parse(line);
        if (r == null) continue;
        await _db
            .into(_db.rejections)
            .insert(
              RejectionsCompanion.insert(
                pairKey: r.pairKey,
                noteA: r.noteA,
                hashA: r.hashA,
                noteB: r.noteB,
                hashB: r.hashB,
                rejectedAt: r.rejectedAt,
                deviceId: r.deviceId,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
    return await _count() - before;
  }

  Future<int> _count() async {
    final count = _db.rejections.pairKey.count();
    final row = await (_db.selectOnly(
      _db.rejections,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  static Rejection? _parse(String line) {
    if (line.trim().isEmpty) return null;
    try {
      final json = jsonDecode(line);
      return json is Map<String, Object?> ? Rejection.fromFileJson(json) : null;
    } on FormatException {
      return null;
    }
  }

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

  /// The pair keys of every remembered rejection.
  Future<Set<String>> pairKeys() async {
    final query = _db.selectOnly(_db.rejections)
      ..addColumns([_db.rejections.pairKey]);
    return {for (final r in await query.get()) r.read(_db.rejections.pairKey)!};
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
