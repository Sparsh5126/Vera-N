import 'package:drift/drift.dart';

import '../../models/graph_data.dart';
import '../../models/search_filters.dart';
import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_markup.dart';
import '../files/note_text.dart';
import 'note_filter_sql.dart';

/// The Graph's data: notes and the links the user confirmed (written
/// `[[links]]`, including accepted suggestions). Trash is left out.
class GraphRepository {
  GraphRepository(this._db);

  final AppDatabase _db;

  static const _matches =
      "(n.name_key = l.target_key OR n.path_key = l.target_key || '.md')";

  /// Updates whenever notes, tags or links change. With [filters], only
  /// notes in that folder (subfolders too) or with that tag, and the links
  /// between them.
  Stream<GraphData> watch({SearchFilters filters = const SearchFilters()}) {
    return _db
        .customSelect(
          'SELECT DISTINCT l.source AS a, n.id AS b FROM links l '
          'JOIN notes n ON $_matches JOIN notes s ON s.id = l.source '
          'WHERE n.trashed_at IS NULL AND s.trashed_at IS NULL '
          'AND n.id != l.source',
          readsFrom: {_db.links, _db.notes, _db.noteTags},
        )
        .watch()
        .asyncMap((rows) async {
          final nodes = await _nodes(filters);
          final ids = {for (final n in nodes) n.ref};
          final edges = {
            for (final r in rows)
              if (ids.contains(r.read<int>('a')) &&
                  ids.contains(r.read<int>('b')))
                GraphEdge.of(r.read<int>('a'), r.read<int>('b')),
          };
          return GraphData(nodes: nodes, edges: edges.toList());
        });
  }

  Future<List<GraphNode>> _nodes(SearchFilters filters) async {
    final where = NoteFilterSql(filters, DateTime.now());
    final rows = await _db
        .customSelect(
          'SELECT n.id, n.title, n.folder, substr(n.body, 1, ?) AS body '
          'FROM notes n '
          'WHERE ${where.sql} ORDER BY n.id',
          variables: [
            const Variable(NoteRows.previewLength),
            ...where.variables,
          ],
          readsFrom: {_db.notes, _db.noteTags},
        )
        .get();
    return [
      for (final r in rows)
        GraphNode(
          ref: r.read<int>('id'),
          title: NoteMarkup.display(r.read<String>('title')),
          preview: NoteText.preview(r.read<String>('body')),
          folder: r.read<String>('folder'),
        ),
    ];
  }
}
