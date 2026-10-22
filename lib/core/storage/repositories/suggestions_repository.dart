import 'package:drift/drift.dart';

import '../../models/suggestion.dart';
import '../../models/suggestion_draft.dart';
import '../db/app_database.dart';
import '../db/note_rows.dart';

/// AI suggestions waiting for review (product spec §7). Kept only in the
/// database: never written to note files, and rebuildable by analysis.
class SuggestionsRepository {
  SuggestionsRepository(this._db);

  final AppDatabase _db;

  static const fresh = 'fresh';
  static const notSure = 'notSure';

  /// A revisit the user put off ("Not now"): hidden until it expires.
  static const snoozed = 'snoozed';

  /// Stores new suggestions. A pair already suggested keeps its status
  /// and expiry date, so a suggestion can't live forever by re-matching.
  Future<void> add(List<SuggestionDraft> drafts, DateTime now, Duration ttl) {
    return _db.batch((b) {
      for (final d in drafts) {
        // A link or copies are a pair, stored lower id first; a tag or a
        // revisit belongs to noteA.
        final pair =
            d.kind == Suggestion.linkKind || d.kind == Suggestion.duplicateKind;
        final (a, z) = !pair || d.noteA < d.noteB
            ? (d.noteA, d.noteB)
            : (d.noteB, d.noteA);
        final swapped = a != d.noteA;
        b.insert(
          _db.suggestions,
          SuggestionsCompanion.insert(
            kind: d.kind,
            noteA: a,
            noteB: z,
            tag: Value(d.tag),
            detail: Value(d.detail),
            fromLaptop: Value(d.fromLaptop),
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

  /// Removes this device's suggestions for note [ref] that matched on its
  /// "Linked notes" footer, which starts at [footerStart]: the footer
  /// lists link titles, not the user's words, so notes linked to the same
  /// notes looked alike (found 2026-10-17). Call it before [ref]'s chunks
  /// are replaced, while the matched chunks' positions are still stored.
  /// A chunk counts when it reaches into the footer, since a short last
  /// line shares a chunk with the line below it.
  Future<int> dropFooterMatches(int ref, int footerStart) async {
    final inFooter =
        await (_db.selectOnly(_db.chunks)
              ..addColumns([_db.chunks.idx])
              ..where(
                _db.chunks.note.equals(ref) &
                    _db.chunks.end.isBiggerThanValue(footerStart),
              ))
            .map((r) => r.read(_db.chunks.idx)!)
            .get();
    if (inFooter.isEmpty) return 0;
    return (_db.delete(_db.suggestions)..where(
          (s) =>
              s.fromLaptop.equals(false) &
              ((s.noteA.equals(ref) & s.chunkA.isIn(inFooter)) |
                  (s.noteB.equals(ref) & s.chunkB.isIn(inFooter))),
        ))
        .go();
  }

  /// The next review batch: fresh suggestions first, then "not sure"
  /// ones; within each, same-folder links first, then oldest first (the
  /// order [_pending] gives, kept by splitting rather than re-sorting).
  /// Pairs with a note in the trash are left out.
  Future<List<Suggestion>> batch({required int size}) async {
    final rows = await _pending().get();
    final ordered = [
      ...rows.where((r) => r.status != notSure),
      ...rows.where((r) => r.status == notSure),
    ];
    return ordered.take(size).map(_suggestion).toList();
  }

  /// Every suggestion waiting for review, oldest first.
  Future<List<Suggestion>> pending() async =>
      (await _pending().get()).map(_suggestion).toList();

  /// How many suggestions are waiting, for the Home card.
  Stream<int> watchCount() => _pending().watch().map((rows) => rows.length);

  /// Every suggestion waiting, for the Graph's dashed lines.
  Stream<List<Suggestion>> watchPending() =>
      _pending().watch().map((rows) => rows.map(_suggestion).toList());

  /// Old notes to revisit (product spec §10), newest first, at most
  /// [limit]. Put-off ones stay hidden until they expire.
  Stream<List<Suggestion>> watchRevisit({required int limit}) {
    final query = _pendingJoin(revisit: true)
      ..orderBy([OrderingTerm.desc(_db.suggestions.createdAt)])
      ..limit(limit);
    return query.watch().map(
      (rows) => [
        for (final r in rows) _suggestion(r.readTable(_db.suggestions)),
      ],
    );
  }

  /// "Not now": the revisit stays hidden until [until], then expires, and
  /// may come back later if it is still relevant.
  Future<void> snooze(int id, DateTime until) {
    return (_db.update(_db.suggestions)..where((s) => s.id.equals(id))).write(
      SuggestionsCompanion(
        status: const Value(snoozed),
        expiresAt: Value(until),
      ),
    );
  }

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

  /// Turns waiting link [id] into copies to merge, keeping its status and
  /// expiry date, so it can't live longer by changing kind. If the pair is
  /// already offered as copies, the link is just removed.
  Future<void> makeCopies(int id) => _db.transaction(() async {
    await _db.customUpdate(
      'UPDATE OR IGNORE suggestions SET kind = ? WHERE id = ?',
      variables: [Variable(Suggestion.duplicateKind), Variable(id)],
      updates: {_db.suggestions},
    );
    await (_db.delete(
      _db.suggestions,
    )..where((s) => s.id.equals(id) & s.kind.equals(Suggestion.linkKind))).go();
  });

  /// Removes a suggestion once the user decided on it.
  Future<void> remove(int id) =>
      (_db.delete(_db.suggestions)..where((s) => s.id.equals(id))).go();

  /// Sets the laptop's sentence on the waiting link between [a] and [b],
  /// if there is one.
  Future<void> setLinkDetail(int a, int b, String detail) {
    final (first, second) = a < b ? (a, b) : (b, a);
    return (_db.update(_db.suggestions)..where(
          (s) =>
              s.kind.equals(Suggestion.linkKind) &
              s.noteA.equals(first) &
              s.noteB.equals(second),
        ))
        .write(SuggestionsCompanion(detail: Value(detail)));
  }

  /// Laptop results already offered (docs/LAPTOP_PLAN.md, L3), by job key.
  Future<Set<String>> importedResults() async => {
    for (final r in await _db.select(_db.importedResults).get()) r.jobKey,
  };

  /// Records that [jobKeys] were offered, and forgets the ones not in
  /// [current] (their notes changed or are gone).
  Future<void> markImported(
    Iterable<String> jobKeys,
    Set<String> current,
    DateTime now,
  ) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.importedResults,
      )..where((r) => r.jobKey.isNotIn(current))).go();
      await _db.batch((b) {
        for (final k in jobKeys) {
          b.insert(
            _db.importedResults,
            ImportedResultsCompanion.insert(jobKey: k, importedAt: now),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
    });
  }

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
            tag: Value(s.tag),
            detail: Value(s.detail),
            fromLaptop: Value(s.fromLaptop),
            score: s.score,
            chunkA: s.chunkA,
            chunkB: s.chunkB,
            status: s.notSure ? notSure : fresh,
            createdAt: s.createdAt,
            expiresAt: s.expiresAt,
          ),
        );
  }

  /// Waiting suggestions with both notes in place. Reviewable ones (links,
  /// tags) by default; with [revisit], the old notes to revisit instead.
  JoinedSelectStatement<HasResultSet, dynamic> _pendingJoin({
    bool revisit = false,
  }) {
    final a = _db.alias(_db.notes, 'a');
    final b = _db.alias(_db.notes, 'b');
    return _db.select(_db.suggestions).join([
      innerJoin(a, a.id.equalsExp(_db.suggestions.noteA)),
      innerJoin(b, b.id.equalsExp(_db.suggestions.noteB)),
    ])..where(
      a.trashedAt.isNull() &
          b.trashedAt.isNull() &
          NoteRows.notArchived(a) &
          NoteRows.notArchived(b) &
          NoteRows.notLocked(a) &
          NoteRows.notLocked(b) &
          _db.suggestions.status.equals(snoozed).not() &
          (revisit
              ? _db.suggestions.kind.equals(Suggestion.resurfaceKind)
              : _db.suggestions.kind.equals(Suggestion.resurfaceKind).not()),
    );
  }

  /// Oldest first, except that links between two notes in the same folder
  /// come before the rest: they are more likely related (user, 2026-10-18).
  /// No folder never counts as the same folder.
  Selectable<SuggestionRow> _pending() {
    const sameFolderFirst = CustomExpression<int>(
      "CASE WHEN suggestions.kind = 'link' AND a.folder != '' "
      'AND lower(a.folder) = lower(b.folder) THEN 0 ELSE 1 END',
    );
    final query = _pendingJoin()
      ..orderBy([
        OrderingTerm(expression: sameFolderFirst),
        OrderingTerm(expression: _db.suggestions.createdAt),
      ]);
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
    tag: r.tag,
    detail: r.detail,
    fromLaptop: r.fromLaptop,
  );
}
