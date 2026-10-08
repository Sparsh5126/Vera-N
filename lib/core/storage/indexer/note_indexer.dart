import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_file_store.dart';
import '../files/sync_conflict.dart';

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
    final listed = await _store.listNotes();
    // Syncthing's conflict copies are other versions, not notes.
    final entries = [
      for (final e in listed)
        if (!SyncConflict.isCopy(e.path)) e,
    ];
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
    // A conflict copy whose note is gone is kept as a note.
    final copies = [
      for (final e in listed)
        if (SyncConflict.originalOf(e.path) case final original?) (e, original),
    ];
    for (final (copy, original) in copies) {
      if (!seen.contains(NoteRows.pathKey(original))) added.add(copy);
    }

    // Rows whose file is gone. Notes never written yet are not missing.
    final missing = rows
        .where((r) => !seen.contains(r.pathKey) && r.fileModifiedMs != null)
        .toList();
    for (final entry in added) {
      await _addOrMove(entry, missing, report);
    }
    await _markSyncConflicts(copies, seen, report);
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

  /// Replaces note [ref] with its file's current text, clearing a
  /// conflict ("keep the other version"). False if the file is gone.
  Future<bool> reload(int ref) async {
    final row = await _row(ref);
    final entry = row == null ? null : await _store.stat(row.path);
    if (row == null || entry == null) return false;
    await _apply(ref, entry, row.created);
    return true;
  }

  /// The text of note [ref]'s file, without its header: in a conflict,
  /// the version changed outside the app. Null if the file is gone.
  Future<String?> fileBody(int ref) async {
    final row = await _row(ref);
    final entry = row == null ? null : await _store.stat(row.path);
    if (row == null || entry == null) return null;
    return (await _read(entry, row.created)).body.value;
  }

  /// A note with a Syncthing conflict copy beside it is in conflict until
  /// the user settles it.
  Future<void> _markSyncConflicts(
    List<(NoteFileEntry, String)> copies,
    Set<String> seen,
    IndexReport report,
  ) async {
    for (final (_, original) in copies) {
      final key = NoteRows.pathKey(original);
      if (!seen.contains(key)) continue;
      final row = await (_db.select(
        _db.notes,
      )..where((n) => n.pathKey.equals(key))).getSingleOrNull();
      if (row == null || row.conflict) continue;
      await _update(row.id, const NotesCompanion(conflict: Value(true)));
      report.conflicts++;
    }
  }

  /// The body of the note file at [path], or null if there is none.
  Future<String?> bodyAt(String path) async {
    final entry = await _store.stat(path);
    if (entry == null) return null;
    return (await _read(entry)).body.value;
  }

  Future<NoteRow?> _row(int ref) =>
      (_db.select(_db.notes)..where((n) => n.id.equals(ref))).getSingleOrNull();

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
