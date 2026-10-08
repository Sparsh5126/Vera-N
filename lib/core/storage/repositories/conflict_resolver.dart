import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../files/note_file_store.dart';
import '../indexer/note_indexer.dart';
import '../indexer/note_writer.dart';
import 'notes_repository.dart';

/// A note changed both here and outside the app (another app, or a synced
/// copy) is "in conflict": the app keeps its own text and stops writing the
/// file, so neither version is lost (product spec §14). These are the
/// user's ways out of it. Nothing is overwritten without their choice, and
/// each choice can be undone without losing a version.
class ConflictResolver {
  ConflictResolver(
    this._db,
    this._store,
    this._writer,
    this._indexer,
    this._notes,
  );

  final AppDatabase _db;
  final NoteFileStore _store;
  final NoteWriter _writer;
  final NoteIndexer _indexer;
  final NotesRepository _notes;

  /// The other version (the file's text), for Compare.
  Future<String?> otherVersion(int ref) => _indexer.fileBody(ref);

  /// Keep this version: the app's text is written to the file. Undo saves
  /// the other version as a separate note, so it is never lost.
  Future<Future<void> Function()> keepThis(int ref) async {
    final other = await _indexer.fileBody(ref);
    final folder = (await _row(ref))?.folder ?? '';
    await _writeOurs(ref);
    return () async {
      if (other != null) await _notes.create(other, folder: folder);
    };
  }

  /// Keep the other version: the file's text replaces the app's. Undo puts
  /// the app's text back (it is then written to the file).
  Future<Future<void> Function()> keepOther(int ref) async {
    final ours = (await _row(ref))?.body;
    await _indexer.reload(ref);
    return () async {
      if (ours != null) await _notes.updateBody(ref, ours);
    };
  }

  /// Keep both: the other version becomes a new note in the same folder,
  /// and this note keeps the app's text. Returns the new note.
  Future<int?> keepBoth(int ref) async {
    final other = await _indexer.fileBody(ref);
    final folder = (await _row(ref))?.folder ?? '';
    final copy = other == null
        ? null
        : await _notes.create(other, folder: folder);
    await _writeOurs(ref);
    return copy;
  }

  /// Clears the conflict and lets the writer replace the file with the
  /// app's text: the file's current time and size are recorded as known,
  /// so the writer no longer sees it as changed elsewhere.
  Future<void> _writeOurs(int ref) async {
    final row = await _row(ref);
    if (row == null) return;
    final onDisk = await _store.stat(row.path);
    await (_db.update(_db.notes)..where((n) => n.id.equals(ref))).write(
      NotesCompanion(
        conflict: const Value(false),
        pendingWrite: const Value(true),
        fileModifiedMs: Value(onDisk?.modified.millisecondsSinceEpoch),
        fileSize: Value(onDisk?.size),
      ),
    );
    _writer.schedule();
  }

  Future<NoteRow?> _row(int ref) =>
      (_db.select(_db.notes)..where((n) => n.id.equals(ref))).getSingleOrNull();
}
