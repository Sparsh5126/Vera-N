import 'package:drift/drift.dart';

import '../../models/locked_folder.dart';
import '../../models/linked_note.dart';
import '../db/app_database.dart';
import '../files/note_links.dart';
import '../files/note_markup.dart';

/// Links the user wrote (`[[name]]`): what a note links to, what mentions
/// it, and the text to insert when linking from the picker.
///
/// A link matches a note by file name, or by path when it includes a
/// folder. Notes in the trash are left out.
class LinksRepository {
  LinksRepository(this._db);

  final AppDatabase _db;

  /// How a link row finds its note (by name, or by path without `.md`).
  static const _matches =
      "(n.name_key = l.target_key OR n.path_key = l.target_key || '.md')";

  /// Notes that [ref]'s text links to, in the order they appear. Links to
  /// notes that don't exist aren't shown.
  Stream<List<LinkedNote>> watchLinked(int ref) {
    return _watch(
      'SELECT n.id, n.title, MIN(l.position) AS pos FROM links l '
      'JOIN notes n ON $_matches '
      'WHERE l.source = ? AND n.trashed_at IS NULL AND n.id != ? '
      // A locked note shows here only to a note that is locked too.
      'AND (${LockedFolder.notLockedSql()} OR EXISTS (SELECT 1 FROM notes v '
      'WHERE v.id = l.source AND NOT ${LockedFolder.notLockedSql('v')})) '
      'GROUP BY n.id ORDER BY pos',
      [Variable(ref), Variable(ref)],
    );
  }

  /// Notes whose text links to [ref] ("Mentioned in"), newest first.
  Stream<List<LinkedNote>> watchMentionedIn(int ref) {
    return _watch(
      'SELECT DISTINCT s.id, s.title, s.modified FROM notes n '
      'JOIN links l ON $_matches JOIN notes s ON s.id = l.source '
      'WHERE n.id = ? AND s.trashed_at IS NULL AND s.id != n.id '
      'AND (${LockedFolder.notLockedSql('s')} '
      'OR NOT ${LockedFolder.notLockedSql()}) '
      'ORDER BY s.modified DESC',
      [Variable(ref)],
    );
  }

  /// The note a link written as `[[target]]` points at, if it exists.
  Future<int?> findNote(String target) async {
    final key = NoteLinks.targetKey(target);
    if (key == null) return null;
    final row = await _db
        .customSelect(
          'SELECT n.id FROM notes n WHERE '
          "(n.name_key = ? OR n.path_key = ? || '.md') "
          'AND n.trashed_at IS NULL ORDER BY n.id LIMIT 1',
          variables: [Variable(key), Variable(key)],
          readsFrom: {_db.notes},
        )
        .getSingleOrNull();
    return row?.read<int>('id');
  }

  /// The `[[…]]` text that links to note [ref]: its file name, or its
  /// folder path too when another note has the same file name. Shown as
  /// [label] (e.g. the words the user selected), or the note's title.
  Future<String?> linkTextFor(int ref, {String? label}) async {
    final note = await (_db.select(
      _db.notes,
    )..where((n) => n.id.equals(ref))).getSingleOrNull();
    if (note == null) return null;
    final sameName =
        await (_db.select(_db.notes)..where(
              (n) =>
                  n.nameKey.equals(note.nameKey) &
                  n.trashedAt.isNull() &
                  n.id.equals(ref).not(),
            ))
            .get();
    return NoteLinks.write(
      note.path,
      label ?? note.title,
      ambiguous: sameName.isNotEmpty,
    );
  }

  Stream<List<LinkedNote>> _watch(String sql, List<Variable> vars) {
    return _db
        .customSelect(sql, variables: vars, readsFrom: {_db.notes, _db.links})
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              LinkedNote(
                ref: r.read<int>('id'),
                title: NoteMarkup.display(r.read<String>('title')),
              ),
          ],
        );
  }
}
