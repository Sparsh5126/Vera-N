import 'package:drift/drift.dart';

import '../../models/archive_folder.dart';
import '../../models/search_filters.dart';

/// The SQL conditions for [SearchFilters] on the `notes n` table, shared
/// by Search, Home and the Graph.
///
/// Archived notes are left out unless [includeArchived] (Search) or the
/// folder filter is the archive itself (browsing it under Folders).
class NoteFilterSql {
  NoteFilterSql(SearchFilters f, DateTime now, {bool includeArchived = false}) {
    final folder = f.folder;
    if (!includeArchived &&
        !(folder != null && ArchiveFolder.contains(folder))) {
      _add(ArchiveFolder.notArchivedSql, const []);
    }
    if (folder != null) {
      // The folder itself or any subfolder; folders compare without case.
      _add(
        '(lower(n.folder) = lower(?) OR '
        "substr(lower(n.folder), 1, length(?) + 1) = lower(?) || '/')",
        [Variable(folder), Variable(folder), Variable(folder)],
      );
    }
    final tag = f.tag;
    if (tag != null) {
      _add(
        'EXISTS (SELECT 1 FROM note_tags t WHERE t.note = n.id '
        'AND t.tag = ? COLLATE NOCASE)',
        [Variable(tag)],
      );
    }
    final date = f.date;
    if (date != null) {
      _add('n.modified >= ?', [Variable<DateTime>(date.startFrom(now))]);
    }
  }

  final _parts = <String>['n.trashed_at IS NULL'];
  final variables = <Variable>[];

  String get sql => _parts.join(' AND ');

  void _add(String part, List<Variable> vars) {
    _parts.add(part);
    variables.addAll(vars);
  }
}
