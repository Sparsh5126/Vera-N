import 'package:characters/characters.dart';
import 'package:drift/drift.dart';

import 'note_placement.dart';
import '../../models/locked_folder.dart';
import '../../models/trashed_note.dart';
import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_file_store.dart';
import '../files/note_markup.dart';
import '../files/note_text.dart';

/// The trash (ARCHITECTURE.md §8, UI spec §11): what is in it, deleting
/// for good, and the 30-day clean-up. Moving notes in and out of the trash
/// is `NotesRepository.trash` / `restore`.
class TrashRepository {
  TrashRepository(this._db, this._store);

  /// Notes stay in the trash this long, then are deleted for good.
  static const keptFor = Duration(days: 30);

  final AppDatabase _db;
  final NoteFileStore _store;

  static TrashedNote _trashed(NoteRow r) {
    // In the trash a note sits in `.trash/<its folder>`.
    const prefix = '${NotePlacement.trashFolder}/';
    final from = r.folder.startsWith(prefix)
        ? r.folder.substring(prefix.length)
        : r.folder;
    if (LockedFolder.contains(from)) {
      return TrashedNote(
        ref: r.id,
        title: '',
        preview: '',
        trashedAt: r.trashedAt!,
        locked: true,
      );
    }
    return TrashedNote(
      ref: r.id,
      title: NoteMarkup.display(r.title),
      preview: NoteText.preview(
        r.body.characters.take(NoteRows.previewLength).toString(),
      ),
      trashedAt: r.trashedAt!,
    );
  }

  /// Notes in the trash, most recently deleted first.
  Stream<List<TrashedNote>> watch() {
    final query = _db.select(_db.notes)
      ..where((n) => n.trashedAt.isNotNull())
      ..orderBy([(n) => OrderingTerm.desc(n.trashedAt)]);
    return query.watch().map((rows) => [for (final r in rows) _trashed(r)]);
  }

  /// Removes a trashed note for good: its file in `.trash/` and everything
  /// the app kept about it (tags, links, suggestions go with it). Notes
  /// not in the trash are never touched.
  Future<void> deleteForever(int ref) async {
    final row = await (_db.select(
      _db.notes,
    )..where((n) => n.id.equals(ref))).getSingleOrNull();
    if (row == null || row.trashedAt == null) return;
    if (await _store.exists(row.path)) await _store.delete(row.path);
    await (_db.delete(_db.notes)..where((n) => n.id.equals(ref))).go();
  }

  /// Deletes for good what has been in the trash longer than [keptFor].
  /// Returns how many notes were removed.
  Future<int> purge(DateTime now) async {
    final old =
        await (_db.select(_db.notes)..where(
              (n) => n.trashedAt.isSmallerThanValue(now.subtract(keptFor)),
            ))
            .get();
    for (final row in old) {
      await deleteForever(row.id);
    }
    return old.length;
  }
}
