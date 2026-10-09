import 'dart:convert';

import '../../models/archive_folder.dart';
import '../../models/booster_result.dart';
import '../../models/locked_folder.dart';
import '../db/app_database.dart';
import '../files/note_file_store.dart';

/// The laptop booster's results (docs/LAPTOP_PLAN.md, L2): appended to
/// this device's `MyNotes/.app/laptop-<deviceid>.jsonl`, and read back from
/// every device's file. Each device writes only its own file.
///
/// Notes are matched across devices by [NoteStamp.key] and only used
/// while their text hash is unchanged.
class BoosterRepository {
  BoosterRepository(this._db, this._store);

  final AppDatabase _db;
  final NoteFileStore _store;

  static String fileName(String deviceId) => 'laptop-$deviceId.jsonl';

  static final _file = RegExp(r'^laptop-[A-Za-z0-9]+\.jsonl$');

  /// Every live note the AI may read (not trashed, archived or locked):
  /// its key across devices, mapped to its row and text hash.
  Future<Map<String, ({int ref, String hash})>> stamps() async {
    final rows = await _db
        .customSelect(
          'SELECT n.id, n.note_id, n.path, n.content_hash FROM notes n '
          'WHERE n.trashed_at IS NULL AND ${ArchiveFolder.notArchivedSql} '
          'AND ${LockedFolder.notLockedSql()}',
          readsFrom: {_db.notes},
        )
        .get();
    return {
      for (final r in rows)
        r.readNullable<String>('note_id') ?? r.read<String>('path'): (
          ref: r.read<int>('id'),
          hash: r.read<String>('content_hash'),
        ),
    };
  }

  /// Results from every device's file, the newest per job, damaged lines
  /// skipped. Stale ones are included; see [BoosterResult.freshIn].
  Future<List<BoosterResult>> readAll() async {
    final latest = <String, BoosterResult>{};
    for (final name in await _store.listAppFiles()) {
      if (!_file.hasMatch(name)) continue;
      for (final r in _parse(await _store.readAppFile(name) ?? '')) {
        final old = latest[r.jobKey];
        if (old == null || !old.madeAt.isAfter(r.madeAt)) latest[r.jobKey] = r;
      }
    }
    return latest.values.toList();
  }

  /// Adds [results] to this device's file.
  Future<void> add(String deviceId, List<BoosterResult> results) async {
    if (results.isEmpty) return;
    final name = fileName(deviceId);
    final old = await _store.readAppFile(name) ?? '';
    final lines = results.map((r) => '${jsonEncode(r.toFileJson())}\n');
    await _store.writeAppFile(name, '$old${lines.join()}');
  }

  /// Rewrites this device's file with only the newest result per job
  /// whose notes are unchanged ([current]: key to hash), so it doesn't
  /// grow without end. Returns how many lines were dropped.
  Future<int> compact(String deviceId, Map<String, String> current) async {
    final name = fileName(deviceId);
    final text = await _store.readAppFile(name);
    if (text == null) return 0;
    final all = _parse(text);
    final latest = <String, BoosterResult>{};
    for (final r in all) {
      if (r.freshIn(current)) latest[r.jobKey] = r;
    }
    final dropped = all.length - latest.length;
    if (dropped == 0) return 0;
    await _store.writeAppFile(
      name,
      latest.values.map((r) => '${jsonEncode(r.toFileJson())}\n').join(),
    );
    return dropped;
  }

  static List<BoosterResult> _parse(String text) => [
    for (final line in const LineSplitter().convert(text)) ?_line(line),
  ];

  static BoosterResult? _line(String line) {
    if (line.trim().isEmpty) return null;
    try {
      final json = jsonDecode(line);
      return json is Map<String, Object?>
          ? BoosterResult.fromFileJson(json)
          : null;
    } on FormatException {
      return null;
    }
  }
}
