import 'dart:math';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_file_store.dart';
import '../indexer/note_writer.dart';

/// Where a note's file lives: trash, restore, and move to a folder.
///
/// File names never change; only the folder does. A name clash in the
/// target gets a short suffix rather than overwriting anything.
class NotePlacement {
  NotePlacement(
    this._db,
    this._store,
    this._writer, {
    required this.clock,
    required this.random,
  });

  static const trashFolder = '.trash';

  final AppDatabase _db;
  final NoteFileStore _store;
  final NoteWriter _writer;
  final DateTime Function() clock;
  final Random random;

  /// Moves the note's file into `.trash/` and hides the note. The file is
  /// kept, so the note survives uninstall and can be restored.
  Future<void> trash(int ref) async {
    await _writer.flush();
    final row = await _row(ref);
    if (row == null || row.trashedAt != null) return;
    final target = await _free('$trashFolder/${row.path}');
    await _moveFile(row, target);
    await _place(ref, target, trashedAt: Value(clock()));
  }

  /// Brings a trashed note back to where it was (undo for [trash]).
  Future<void> restore(int ref) async {
    final row = await _row(ref);
    if (row == null || row.trashedAt == null) return;
    final target = await _free(row.path.substring(trashFolder.length + 1));
    final fileKept = await _store.exists(row.path);
    await _moveFile(row, target);
    // File gone (e.g. left in another folder): write it from the database.
    await _place(ref, target, trashedAt: const Value(null), rewrite: !fileKept);
  }

  /// Moves the note into [folder] (`''` is the top level). Returns the
  /// folder it was in, for undo, or null if there is no such note.
  Future<String?> moveToFolder(int ref, String folder) async {
    await _writer.flush();
    final row = await _row(ref);
    if (row == null || row.trashedAt != null) return null;
    if (row.folder.toLowerCase() == folder.toLowerCase()) return row.folder;
    final name = row.path.split('/').last;
    final wanted = folder.isEmpty ? name : '$folder/$name';
    checkNotePath(wanted);
    final target = await _free(wanted);
    await _moveFile(row, target);
    await _place(ref, target);
    return row.folder;
  }

  /// In use by another note (any letter case) or by a file on disk.
  Future<bool> pathTaken(String path) async {
    final row =
        await (_db.select(_db.notes)
              ..where((n) => n.pathKey.equals(NoteRows.pathKey(path))))
            .getSingleOrNull();
    return row != null || await _store.exists(path);
  }

  /// [path], or `a/b-3f9c.md` if `a/b.md` is taken.
  Future<String> _free(String path) async {
    if (!await pathTaken(path)) return path;
    final hex = random.nextInt(0x10000).toRadixString(16).padLeft(4, '0');
    return path.replaceFirst(RegExp(r'\.md$'), '-$hex.md');
  }

  Future<void> _moveFile(NoteRow row, String target) async {
    if (await _store.exists(row.path)) await _store.move(row.path, target);
  }

  /// Points the row at [target]. Records the moved file's new time and
  /// size (a copy-then-delete move changes them), so the indexer doesn't
  /// re-read it; or, with [rewrite], marks it for writing from here.
  Future<void> _place(
    int ref,
    String target, {
    Value<DateTime?> trashedAt = const Value.absent(),
    bool rewrite = false,
  }) async {
    final onDisk = rewrite ? null : await _store.stat(target);
    await (_db.update(_db.notes)..where((n) => n.id.equals(ref))).write(
      NotesCompanion(
        path: Value(target),
        pathKey: Value(NoteRows.pathKey(target)),
        folder: Value(NoteRows.folderOf(target)),
        trashedAt: trashedAt,
        pendingWrite: rewrite ? const Value(true) : const Value.absent(),
        fileModifiedMs: Value(onDisk?.modified.millisecondsSinceEpoch),
        fileSize: Value(onDisk?.size),
      ),
    );
    if (rewrite) _writer.schedule();
  }

  Future<NoteRow?> _row(int ref) =>
      (_db.select(_db.notes)..where((n) => n.id.equals(ref))).getSingleOrNull();
}
