import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_file_store.dart';

/// What one reconcile pass changed.
class IndexReport {
  int added = 0;
  int updated = 0;
  int moved = 0;
  int removed = 0;
  int conflicts = 0;
  int unchanged = 0;

  /// Every indexed file was missing, so nothing was removed.
  bool folderMissing = false;
}

/// Brings the database in line with the notes folder. Runs off the UI (on
/// start and on app resume); the UI only ever reads the database.
///
/// Unchanged files (same time and size) are not read. Outside moves and
/// renames keep the same note: a vanished path is matched to a new one by
/// header `id`, then by content hash. Paths compare case-insensitively.
class NoteIndexer {
  NoteIndexer(this._db, this._store);

  final AppDatabase _db;
  final NoteFileStore _store;

  Future<IndexReport> reconcile() async {
    final report = IndexReport();
    final entries = await _store.listNotes();
    final rows = await (_db.select(
      _db.notes,
    )..where((n) => n.trashedAt.isNull())).get();
    final byKey = {for (final r in rows) r.pathKey: r};
    final seen = <String>{};
    final added = <NoteFileEntry>[];

    for (final entry in entries) {
      final key = NoteRows.pathKey(entry.path);
      // Two files differing only in letter case count as one note.
      if (!seen.add(key)) continue;
      final row = byKey[key];
      if (row == null) {
        added.add(entry);
        continue;
      }
      await _refresh(row, entry, report);
    }

    // Rows whose file is gone. Notes never written yet are not missing.
    final missing = rows
        .where((r) => !seen.contains(r.pathKey) && r.fileModifiedMs != null)
        .toList();
    for (final entry in added) {
      await _addOrMove(entry, missing, report);
    }
    // An empty folder where several notes were means the folder is
    // unavailable (unmounted, renamed, access lost), not that the user
    // deleted every note. Keep the index; the files will come back.
    final onDisk = rows.where((r) => r.fileModifiedMs != null).length;
    if (entries.isEmpty && onDisk > 1) {
      report.folderMissing = true;
      return report;
    }
    for (final row in missing) {
      if (row.pendingWrite) continue; // The writer will recreate the file.
      await (_db.delete(_db.notes)..where((n) => n.id.equals(row.id))).go();
      report.removed++;
    }
    return report;
  }

  Future<void> _refresh(
    NoteRow row,
    NoteFileEntry entry,
    IndexReport report,
  ) async {
    if (row.path != entry.path) {
      // Renamed only in letter case.
      await _update(row.id, NoteRows.placedAt(entry.path));
    }
    final sameFile =
        row.fileModifiedMs == entry.modified.millisecondsSinceEpoch &&
        row.fileSize == entry.size;
    if (sameFile) {
      report.unchanged++;
      return;
    }
    if (row.pendingWrite) {
      await _update(row.id, const NotesCompanion(conflict: Value(true)));
      report.conflicts++;
      return;
    }
    await _apply(row.id, entry, row.created);
    report.updated++;
  }

  Future<void> _addOrMove(
    NoteFileEntry entry,
    List<NoteRow> missing,
    IndexReport report,
  ) async {
    final values = await _read(entry);
    final id = values.noteId.value;
    final hash = values.contentHash.value;
    NoteRow? match;
    for (final candidate in missing) {
      if (id != null && candidate.noteId == id) match = candidate;
    }
    match ??= missing.where((r) => r.contentHash == hash).firstOrNull;

    if (match == null) {
      final ref = await _db.into(_db.notes).insert(values);
      await _derive(ref, values);
      report.added++;
      return;
    }
    missing.remove(match);
    if (match.pendingWrite) {
      // Moved elsewhere while edited here: take the new path, keep our text.
      await _update(
        match.id,
        NoteRows.placedAt(values.path.value)
            .copyWith(conflict: const Value(true)),
      );
      report.conflicts++;
      return;
    }
    final kept = values.noteId.value == null
        ? values.copyWith(created: Value(match.created))
        : values;
    await _update(match.id, kept);
    await _derive(match.id, values);
    report.moved++;
  }

  Future<void> _apply(int ref, NoteFileEntry entry, DateTime created) async {
    final values = await _read(entry, created);
    await _update(ref, values);
    await _derive(ref, values);
  }

  Future<NotesCompanion> _read(NoteFileEntry entry, [DateTime? created]) async {
    final text = await _store.read(entry.path);
    return NoteRows.fromFile(
      path: entry.path,
      text: text,
      fileModified: entry.modified,
      fileSize: entry.size,
      knownCreated: created,
    );
  }

  /// Tags and links come from the file's header and text.
  Future<void> _derive(int ref, NotesCompanion values) async {
    await NoteRows.replaceTags(
      _db,
      ref,
      NoteRows.tagsOf(values.headerRaw.value),
    );
    await NoteRows.replaceLinks(_db, ref, values.body.value);
  }

  Future<void> _update(int ref, NotesCompanion values) =>
      (_db.update(_db.notes)..where((n) => n.id.equals(ref))).write(values);
}
