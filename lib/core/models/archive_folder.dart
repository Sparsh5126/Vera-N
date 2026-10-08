/// Archived notes live in `Notes/Archive/`, keeping their folder inside it
/// (`Ideas/x.md` becomes `Archive/Ideas/x.md`), so unarchiving puts a note
/// back exactly where it was and other apps see a plain folder (decided by
/// the user, 2026-10-08). Archived notes leave Home, the Graph and
/// suggestions, and stay in Search and in the Folders view.
abstract final class ArchiveFolder {
  static const name = 'Archive';

  /// Whether [folder] is the archive or inside it (any letter case).
  static bool contains(String folder) {
    final f = folder.toLowerCase();
    return f == _lower || f.startsWith('$_lower/');
  }

  /// Where a note in [folder] goes when archived.
  static String into(String folder) => folder.isEmpty ? name : '$name/$folder';

  /// Where an archived note in [folder] goes back to.
  static String outOf(String folder) {
    if (!contains(folder)) return folder;
    return folder.length == name.length
        ? ''
        : folder.substring(name.length + 1);
  }

  /// SQL: true when the note `n` is not archived.
  static const notArchivedSql =
      "NOT (lower(n.folder) = 'archive' OR lower(n.folder) LIKE 'archive/%')";

  static const _lower = 'archive';
}
