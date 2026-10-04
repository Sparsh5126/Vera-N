import 'package:drift/drift.dart';

import '../../models/search_filters.dart';
import '../../models/search_hit.dart';
import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_markup.dart';
import '../files/note_text.dart';
import 'note_filter_sql.dart';

/// Keyword search over the notes' titles and text (FTS5 index), with the
/// Folder, Tag and Date filters.
///
/// Only the user's notes are searched, never AI suggestions.
class SearchRepository {
  SearchRepository(this._db);

  /// Words of context around the matches in a result's snippet.
  static const snippetWords = 16;
  static const defaultLimit = 50;

  final AppDatabase _db;

  /// Notes matching every word of [query] and all [filters], best first.
  /// Each word matches as a prefix, so results appear while typing.
  ///
  /// With no words but some filter set, lists the matching notes newest
  /// first. With neither, returns nothing.
  Future<List<SearchHit>> search(
    String query, {
    SearchFilters filters = const SearchFilters(),
    DateTime? now,
    int limit = defaultLimit,
  }) async {
    final match = ftsQuery(query);
    if (match == null && !filters.isActive) return const [];
    final where = NoteFilterSql(filters, now ?? DateTime.now());
    final rows = match == null
        ? await _browse(where, limit)
        : await _match(match, where, limit);
    return rows.map(_hit).toList();
  }

  /// Every folder that holds notes, with its parent folders, sorted.
  Future<List<String>> folders() async =>
      _expandFolders(await _folderRows().get());

  /// [folders], kept up to date.
  Stream<List<String>> watchFolders() =>
      _folderRows().watch().map(_expandFolders);

  /// Every confirmed tag on a note that isn't in the trash, sorted.
  Future<List<String>> tags() async => _tagNames(await _tagRows().get());

  /// [tags], kept up to date.
  Stream<List<String>> watchTags() => _tagRows().watch().map(_tagNames);

  Selectable<QueryRow> _folderRows() => _db.customSelect(
    "SELECT DISTINCT folder FROM notes WHERE folder != '' "
    'AND trashed_at IS NULL',
    readsFrom: {_db.notes},
  );

  static List<String> _expandFolders(List<QueryRow> rows) {
    final all = <String>{};
    for (final r in rows) {
      final parts = r.read<String>('folder').split('/');
      for (var i = 1; i <= parts.length; i++) {
        all.add(parts.take(i).join('/'));
      }
    }
    return all.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  Selectable<QueryRow> _tagRows() => _db.customSelect(
    'SELECT DISTINCT t.tag FROM note_tags t '
    'JOIN notes n ON n.id = t.note WHERE n.trashed_at IS NULL '
    'ORDER BY t.tag COLLATE NOCASE',
    readsFrom: {_db.notes, _db.noteTags},
  );

  static List<String> _tagNames(List<QueryRow> rows) => [
    for (final r in rows) r.read<String>('tag'),
  ];

  Future<List<QueryRow>> _match(String match, NoteFilterSql where, int limit) {
    return _db
        .customSelect(
          'SELECT n.id, n.modified, '
          "highlight(notes_fts, 0, '$searchMatchStart', '$searchMatchEnd') "
          'AS marked_title, '
          "snippet(notes_fts, 1, '$searchMatchStart', '$searchMatchEnd', "
          "'…', $snippetWords) AS marked_snippet "
          'FROM notes_fts JOIN notes n ON n.id = notes_fts.rowid '
          'WHERE notes_fts MATCH ? AND ${where.sql} '
          'ORDER BY rank LIMIT ?',
          variables: [Variable(match), ...where.variables, Variable(limit)],
          readsFrom: {_db.notes, _db.noteTags},
        )
        .get();
  }

  Future<List<QueryRow>> _browse(NoteFilterSql where, int limit) {
    return _db
        .customSelect(
          'SELECT n.id, n.modified, n.title AS marked_title, '
          'substr(n.body, 1, ${NoteRows.previewLength}) AS raw_body '
          'FROM notes n WHERE ${where.sql} '
          'ORDER BY n.modified DESC, n.id DESC LIMIT ?',
          variables: [...where.variables, Variable(limit)],
          readsFrom: {_db.notes, _db.noteTags},
        )
        .get();
  }

  SearchHit _hit(QueryRow r) {
    final rawBody = r.readNullable<String>('raw_body');
    return SearchHit(
      ref: r.read<int>('id'),
      title: MarkedText.parse(r.read<String>('marked_title')),
      snippet: rawBody == null
          ? MarkedText.parse(
              NoteMarkup.display(r.read<String>('marked_snippet')),
            )
          : MarkedText(NoteText.preview(rawBody), const []),
      modified: r.read<DateTime>('modified'),
    );
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
