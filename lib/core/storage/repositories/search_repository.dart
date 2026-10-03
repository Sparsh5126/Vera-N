import 'package:drift/drift.dart';

import '../../models/search_hit.dart';
import '../db/app_database.dart';

/// Keyword search over the notes' titles and text (FTS5 index).
///
/// Only the user's notes are searched, never AI suggestions.
class SearchRepository {
  SearchRepository(this._db);

  /// Words of context around the matches in a result's snippet.
  static const snippetWords = 16;
  static const defaultLimit = 50;

  final AppDatabase _db;

  /// Notes matching every word of [query], best first. Each word matches
  /// as a prefix, so results appear while a word is still being typed.
  Future<List<SearchHit>> search(
    String query, {
    int limit = defaultLimit,
  }) async {
    final match = ftsQuery(query);
    if (match == null) return const [];
    final rows = await _db
        .customSelect(
          'SELECT n.id, n.modified, '
          "highlight(notes_fts, 0, '$searchMatchStart', '$searchMatchEnd') "
          'AS marked_title, '
          "snippet(notes_fts, 1, '$searchMatchStart', '$searchMatchEnd', "
          "'…', $snippetWords) AS marked_snippet "
          'FROM notes_fts JOIN notes n ON n.id = notes_fts.rowid '
          'WHERE notes_fts MATCH ? AND n.trashed_at IS NULL '
          'ORDER BY rank LIMIT ?',
          variables: [Variable(match), Variable(limit)],
          readsFrom: {_db.notes},
        )
        .get();
    return [
      for (final r in rows)
        SearchHit(
          ref: r.read<int>('id'),
          title: MarkedText.parse(r.read<String>('marked_title')),
          snippet: MarkedText.parse(r.read<String>('marked_snippet')),
          modified: r.read<DateTime>('modified'),
        ),
    ];
  }

  /// Turns what the user typed into a safe FTS5 query: each word quoted
  /// (so operators like OR, NEAR or `*` are just text) and matched as a
  /// prefix. Null when there is nothing to search for.
  static String? ftsQuery(String query) {
    final terms = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '"${t.replaceAll('"', '""')}"*');
    return terms.isEmpty ? null : terms.join(' ');
  }
}
