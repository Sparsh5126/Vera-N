import 'package:drift/drift.dart';

import '../../models/archive_folder.dart';
import '../../models/locked_folder.dart';
import '../../models/chunk_vector.dart';
import '../../models/note_to_analyze.dart';
import '../../models/rejected_pair.dart';
import '../db/app_database.dart';
import '../db/note_rows.dart';

/// What on-device analysis reads and writes: which notes changed since
/// they were embedded, and their chunk vectors. All of it is rebuildable
/// from the notes; trashed notes are left out.
class AnalysisRepository {
  AnalysisRepository(this._db);

  final AppDatabase _db;

  /// Notes whose text changed since they were analyzed with [model]
  /// (or were never analyzed), oldest change first.
  Future<List<NoteToAnalyze>> stale(String model, {required int limit}) {
    return _db
        .customSelect(
          'SELECT n.id, n.body, n.content_hash FROM notes n '
          'LEFT JOIN note_analysis a ON a.note = n.id '
          'WHERE n.trashed_at IS NULL AND ${ArchiveFolder.notArchivedSql} '
          'AND ${LockedFolder.notLockedSql()} '
          'AND (a.note IS NULL '
          'OR a.content_hash != n.content_hash OR a.model != ?) '
          'ORDER BY n.modified LIMIT ?',
          variables: [Variable(model), Variable(limit)],
          readsFrom: {_db.notes, _db.noteAnalysis},
        )
        .map(
          (r) => NoteToAnalyze(
            r.read<int>('id'),
            r.read<String>('body'),
            r.read<String>('content_hash'),
          ),
        )
        .get();
  }

  /// [ref]'s stored chunks made with [model], in order. (Vectors from
  /// another model can't be compared or reused.)
  Future<List<ChunkVector>> chunksOf(int ref, String model) async {
    final rows =
        await (_db.select(_db.chunks)
              ..where((c) => c.note.equals(ref) & c.model.equals(model))
              ..orderBy([(c) => OrderingTerm(expression: c.idx)]))
            .get();
    return rows.map(_vector).toList();
  }

  /// Every chunk made with [model], of notes not in the trash.
  Future<List<ChunkVector>> allChunks(String model) async {
    final query =
        _db.select(_db.chunks).join([
          innerJoin(_db.notes, _db.notes.id.equalsExp(_db.chunks.note)),
        ])..where(
          _db.chunks.model.equals(model) &
              _db.notes.trashedAt.isNull() &
              NoteRows.notArchived(_db.notes) &
              NoteRows.notLocked(_db.notes),
        );
    final rows = await query.get();
    return [for (final r in rows) _vector(r.readTable(_db.chunks))];
  }

  /// Replaces [ref]'s chunks and records that its text [contentHash] was
  /// analyzed with [model]. If the note changed meanwhile, the next run
  /// sees the new hash and analyzes it again.
  Future<void> save(
    int ref,
    String contentHash,
    String model,
    List<ChunkVector> chunks,
    DateTime now,
  ) {
    return _db.transaction(() async {
      await (_db.delete(_db.chunks)..where((c) => c.note.equals(ref))).go();
      for (final c in chunks) {
        await _db
            .into(_db.chunks)
            .insert(
              ChunksCompanion.insert(
                note: ref,
                idx: c.idx,
                start: c.start,
                end: c.end,
                hash: c.hash,
                model: model,
                vector: c.vector,
              ),
            );
      }
      await _db
          .into(_db.noteAnalysis)
          .insertOnConflictUpdate(
            NoteAnalysisCompanion.insert(
              note: Value(ref),
              contentHash: contentHash,
              model: model,
              analyzedAt: now,
            ),
          );
    });
  }

  /// Locked notes are never touched by the AI: their passages, vectors,
  /// analysis record and suggestions are deleted. Runs when a note is
  /// locked and before every analysis run (a note may reach `Locked/`
  /// through another app).
  Future<void> forgetLocked() {
    final locked =
        'SELECT n.id FROM notes n WHERE NOT ${LockedFolder.notLockedSql()}';
    Future<void> delete(String sql, TableInfo table) =>
        _db.customUpdate(sql, updates: {table}, updateKind: UpdateKind.delete);
    return _db.transaction(() async {
      await delete('DELETE FROM chunks WHERE note IN ($locked)', _db.chunks);
      await delete(
        'DELETE FROM note_analysis WHERE note IN ($locked)',
        _db.noteAnalysis,
      );
      await delete(
        'DELETE FROM suggestions WHERE note_a IN ($locked) '
        'OR note_b IN ($locked)',
        _db.suggestions,
      );
    });
  }

  /// Marks every note as not yet analyzed, so the next run matches all of
  /// them again. Stored vectors stay: a chunk whose text and model are
  /// unchanged gets the same vector, so they are reused, not recomputed.
  Future<void> forgetAll() => _db.delete(_db.noteAnalysis).go();

  /// Where chunk [idx] of note [ref] sits in its text, if stored.
  Future<(int, int)?> chunkRange(int ref, int idx) async {
    final row =
        await (_db.select(_db.chunks)
              ..where((c) => c.note.equals(ref) & c.idx.equals(idx))
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : (row.start, row.end);
  }

  /// The text of note [ref], or null if it is gone.
  Future<String?> bodyOf(int ref) async {
    final row = await (_db.select(
      _db.notes,
    )..where((n) => n.id.equals(ref))).getSingleOrNull();
    return row?.body;
  }

  /// Rejections involving note [ref], seen from it.
  Future<List<RejectedPair>> rejectedWith(int ref) async {
    final rows = await _db
        .customSelect(
          'SELECT o.id AS other, '
          'CASE WHEN r.note_a = n.note_id THEN r.signature_a '
          'ELSE r.signature_b END AS own_sig, '
          'CASE WHEN r.note_a = n.note_id THEN r.signature_b '
          'ELSE r.signature_a END AS other_sig '
          'FROM notes n JOIN rejections r '
          'ON r.note_a = n.note_id OR r.note_b = n.note_id '
          'JOIN notes o ON o.note_id = '
          'CASE WHEN r.note_a = n.note_id THEN r.note_b ELSE r.note_a END '
          'WHERE n.id = ?',
          variables: [Variable(ref)],
          readsFrom: {_db.notes, _db.rejections},
        )
        .get();
    return [
      for (final r in rows)
        RejectedPair(
          r.read<int>('other'),
          r.readNullable<Uint8List>('own_sig'),
          r.readNullable<Uint8List>('other_sig'),
        ),
    ];
  }

  /// When each live, unarchived note last changed, for Revisit.
  /// Notes in exactly [ref]'s folder (letter case ignored), not [ref]
  /// itself; none when [ref] has no folder, since that says nothing.
  Future<Set<int>> sameFolderAs(int ref) async {
    final rows = await _db
        .customSelect(
          'SELECT o.id FROM notes n JOIN notes o '
          "ON lower(o.folder) = lower(n.folder) AND o.id != n.id "
          "WHERE n.id = ? AND n.folder != '' AND o.trashed_at IS NULL",
          variables: [Variable(ref)],
          readsFrom: {_db.notes},
        )
        .get();
    return {for (final r in rows) r.read<int>('id')};
  }

  Future<Map<int, DateTime>> modifiedTimes() async {
    final rows =
        await (_db.select(_db.notes)..where(
              (n) =>
                  n.trashedAt.isNull() &
                  NoteRows.notArchived(n) &
                  NoteRows.notLocked(n),
            ))
            .get();
    return {for (final r in rows) r.id: r.modified};
  }

  /// Old notes already offered to revisit (waiting or put off): not
  /// offered again until that expires.
  Future<Set<int>> revisitNotes() async {
    final rows = await (_db.select(
      _db.suggestions,
    )..where((s) => s.kind.equals('resurface'))).get();
    return {for (final r in rows) r.noteA};
  }

  /// The tags of each of [refs] (notes without tags are left out).
  Future<Map<int, Set<String>>> tagsOf(Iterable<int> refs) async {
    final ids = refs.toList();
    if (ids.isEmpty) return const {};
    final rows = await (_db.select(
      _db.noteTags,
    )..where((t) => t.note.isIn(ids))).get();
    final out = <int, Set<String>>{};
    for (final r in rows) {
      (out[r.note] ??= {}).add(r.tag);
    }
    return out;
  }

  /// Tags the user rejected for note [ref], lowercase, without `#`. A tag
  /// rejection is a pair of the note's id and `#tag` (see [Rejection]).
  Future<Set<String>> rejectedTags(int ref) async {
    final rows = await _db
        .customSelect(
          "SELECT CASE WHEN r.note_a = n.note_id THEN r.note_b "
          'ELSE r.note_a END AS tag FROM notes n JOIN rejections r '
          "ON (r.note_a = n.note_id AND r.note_b LIKE '#%') "
          "OR (r.note_b = n.note_id AND r.note_a LIKE '#%') WHERE n.id = ?",
          variables: [Variable(ref)],
          readsFrom: {_db.notes, _db.rejections},
        )
        .get();
    return {for (final r in rows) r.read<String>('tag').substring(1)};
  }

  /// Tags already waiting as suggestions for note [ref], lowercase.
  Future<Set<String>> pendingTags(int ref) async {
    final rows = await (_db.select(
      _db.suggestions,
    )..where((s) => s.kind.equals('tag') & s.noteA.equals(ref))).get();
    return {for (final r in rows) r.tag.toLowerCase()};
  }

  /// Notes [ref] is already linked with, in either direction: these are
  /// never suggested.
  Future<Set<int>> linkedWith(int ref) async {
    const matches =
        "(n.name_key = l.target_key OR n.path_key = l.target_key || '.md')";
    final rows = await _db
        .customSelect(
          'SELECT n.id AS other FROM links l JOIN notes n ON $matches '
          'WHERE l.source = ? '
          'UNION SELECT l.source AS other FROM links l '
          'JOIN notes n ON $matches WHERE n.id = ?',
          variables: [Variable(ref), Variable(ref)],
          readsFrom: {_db.links, _db.notes},
        )
        .get();
    return {for (final r in rows) r.read<int>('other')};
  }

  static ChunkVector _vector(ChunkRow r) => ChunkVector(
    note: r.note,
    idx: r.idx,
    start: r.start,
    end: r.end,
    hash: r.hash,
    vector: r.vector,
  );
}
