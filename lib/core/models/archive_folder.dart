import 'special_folder.dart';

/// Archived notes live in `Notes/Archive/`, keeping their folder inside it
/// (`Ideas/x.md` becomes `Archive/Ideas/x.md`), so unarchiving puts a note
/// back exactly where it was and other apps see a plain folder (decided by
/// the user, 2026-10-08). Archived notes leave Home, the Graph and
/// suggestions, and stay in Search and in the Folders view.
abstract final class ArchiveFolder {
  static const folder = SpecialFolder('Archive');
  static const name = 'Archive';

  static bool contains(String f) => folder.contains(f);
  static String into(String f) => folder.into(f);
  static String outOf(String f) => folder.outOf(f);

  /// SQL: true when the note `n` is not archived.
  static String get notArchivedSql => folder.notInSql;
}
