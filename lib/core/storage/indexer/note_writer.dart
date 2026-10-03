import 'dart:async';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_file_store.dart';

/// Writes notes with unsaved changes to their files, shortly after the last
/// change. Never overwrites a file that changed elsewhere: that note is
/// marked as in conflict instead and both versions are kept.
class NoteWriter {
  NoteWriter(this._db, this._store, {this.delay = defaultDelay});

  /// Pause after the last change before writing the file.
  static const defaultDelay = Duration(milliseconds: 800);

  final AppDatabase _db;
  final NoteFileStore _store;
  final Duration delay;
  Timer? _timer;
  Future<void>? _running;

  /// Writes pending notes after [delay], restarting the wait on each call.
  void schedule() {
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(flush()));
  }

  /// Writes every pending note now. Calls never overlap.
  Future<void> flush() async {
    _timer?.cancel();
    while (_running != null) {
      await _running;
    }
    final run = _writePending();
    _running = run;
    try {
      await run;
    } finally {
      _running = null;
    }
  }

  void dispose() => _timer?.cancel();

  Future<void> _writePending() async {
    final rows =
        await (_db.select(_db.notes)..where(
              (n) => n.pendingWrite & n.conflict.not() & n.trashedAt.isNull(),
            ))
            .get();
    for (final row in rows) {
      await _write(row);
    }
  }

  Future<void> _write(NoteRow row) async {
    final onDisk = await _store.stat(row.path);
    if (onDisk != null && _changedElsewhere(row, onDisk)) {
      await _byId(row.id).write(const NotesCompanion(conflict: Value(true)));
      return;
    }
    final written = await _store.write(row.path, NoteRows.fileText(row));
    await _byId(row.id).write(
      NotesCompanion(
        fileModifiedMs: Value(written.modified.millisecondsSinceEpoch),
        fileSize: Value(written.size),
      ),
    );
    final unchangedSince = _db.update(_db.notes)
      ..where((n) => n.id.equals(row.id) & n.revision.equals(row.revision));
    await unchangedSince.write(
      const NotesCompanion(pendingWrite: Value(false)),
    );
  }

  /// A file exists that this app didn't write last.
  bool _changedElsewhere(NoteRow row, NoteFileEntry onDisk) =>
      row.fileModifiedMs != onDisk.modified.millisecondsSinceEpoch ||
      row.fileSize != onDisk.size;

  UpdateStatement<$NotesTable, NoteRow> _byId(int id) =>
      _db.update(_db.notes)..where((n) => n.id.equals(id));
}
