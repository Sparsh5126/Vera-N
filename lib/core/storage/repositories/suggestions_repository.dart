import 'package:drift/drift.dart';

import '../../models/suggestion.dart';
import '../../models/suggestion_draft.dart';
import '../db/app_database.dart';

/// AI suggestions waiting for review (product spec §7). Kept only in the
/// database: never written to note files, and rebuildable by analysis.
class SuggestionsRepository {
  SuggestionsRepository(this._db);

  final AppDatabase _db;

  static const fresh = 'fresh';
  static const notSure = 'notSure';

  /// Stores new suggestions. A pair already suggested keeps its status
  /// and expiry date, so a suggestion can't live forever by re-matching.
  Future<void> add(List<SuggestionDraft> drafts, DateTime now, Duration ttl) {
    return _db.batch((b) {
      for (final d in drafts) {
        final (a, z) = d.noteA < d.noteB
            ? (d.noteA, d.noteB)
            : (d.noteB, d.noteA);
        final swapped = a != d.noteA;
        b.insert(
          _db.suggestions,
          SuggestionsCompanion.insert(
            kind: d.kind,
            noteA: a,
            noteB: z,
            score: d.score,
            chunkA: swapped ? d.chunkB : d.chunkA,
            chunkB: swapped ? d.chunkA : d.chunkB,
            status: fresh,
            createdAt: now,
            expiresAt: now.add(ttl),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  /// Removes suggestions nobody reviewed in time. Returns how many.
  Future<int> expire(DateTime now) {
    return (_db.delete(
      _db.suggestions,
    )..where((s) => s.expiresAt.isSmallerThanValue(now))).go();
  }

  /// The next review batch: fresh suggestions first, then "not sure"
  /// ones, oldest first; pairs with a note in the trash are left out.
  Future<List<Suggestion>> batch({required int size}) async {
    final rows = await _pending().get();
    rows.sort((a, b) {
      final status =
          (a.status == notSure ? 1 : 0) - (b.status == notSure ? 1 : 0);
      return status != 0 ? status : a.createdAt.compareTo(b.createdAt);
    });
    return rows.take(size).map(_suggestion).toList();
  }

  /// Every suggestion waiting for review, oldest first.
  Future<List<Suggestion>> pending() async =>
      (await _pending().get()).map(_suggestion).toList();

  /// How many suggestions are waiting, for the Home card.
  Stream<int> watchCount() => _pending().watch().map((rows) => rows.length);

  /// Every suggestion waiting, for the Graph's dashed lines.
  Stream<List<Suggestion>> watchPending() =>
      _pending().watch().map((rows) => rows.map(_suggestion).toList());

  /// Suggestions waiting that involve note [ref], for its note view.
  Stream<List<Suggestion>> watchFor(int ref) => _pending().watch().map(
    (rows) => [
      for (final r in rows)
        if (r.noteA == ref || r.noteB == ref) _suggestion(r),
    ],
  );

  Future<void> setNotSure(int id, {required bool notSure}) {
    return (_db.update(_db.suggestions)..where((s) => s.id.equals(id))).write(
      SuggestionsCompanion(
        status: Value(notSure ? SuggestionsRepository.notSure : fresh),
      ),
    );
  }

  /// Removes a suggestion once the user decided on it.
  Future<void> remove(int id) =>
      (_db.delete(_db.suggestions)..where((s) => s.id.equals(id))).go();

  /// Removes every suggestion waiting for review ("Rebuild suggestions").
  Future<void> clear() => _db.delete(_db.suggestions).go();

  /// Undo for [remove]: puts the same suggestion back.
  Future<void> putBack(Suggestion s) {
    return _db
        .into(_db.suggestions)
        .insertOnConflictUpdate(
          SuggestionsCompanion.insert(
            id: Value(s.id),
            kind: s.kind,
            noteA: s.noteA,
            noteB: s.noteB,
            score: s.score,
            chunkA: s.chunkA,
            chunkB: s.chunkB,
            status: s.notSure ? notSure : fresh,
            createdAt: s.createdAt,
            expiresAt: s.expiresAt,
          ),
        );
  }

  JoinedSelectStatement<HasResultSet, dynamic> _pendingJoin() {
    final a = _db.alias(_db.notes, 'a');
    final b = _db.alias(_db.notes, 'b');
    return _db.select(_db.suggestions).join([
      innerJoin(a, a.id.equalsExp(_db.suggestions.noteA)),
      innerJoin(b, b.id.equalsExp(_db.suggestions.noteB)),
    ])..where(a.trashedAt.isNull() & b.trashedAt.isNull());
  }

  Selectable<SuggestionRow> _pending() {
    final query = _pendingJoin()
      ..orderBy([OrderingTerm(expression: _db.suggestions.createdAt)]);
    return query.map((r) => r.readTable(_db.suggestions));
  }

  static Suggestion _suggestion(SuggestionRow r) => Suggestion(
    id: r.id,
    kind: r.kind,
    noteA: r.noteA,
    noteB: r.noteB,
    score: r.score,
    chunkA: r.chunkA,
    chunkB: r.chunkB,
    notSure: r.status == notSure,
    createdAt: r.createdAt,
    expiresAt: r.expiresAt,
  );
}
