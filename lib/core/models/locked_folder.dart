import 'special_folder.dart';

/// The Locked folder (decided by the user, 2026-10-08): `Notes/Locked/`,
/// keeping each note's folder inside it like Archive.
///
/// Its notes open only after the phone's own lock (fingerprint, face or
/// PIN), and are never touched by the AI: no analysis, no suggestions,
/// no Revisit, and their stored passages are forgotten when they are
/// locked. They also stay out of Home, Search, the Graph, tags and links
/// until the folder is opened. The files stay plain Markdown (an app lock,
/// not encryption), so Obsidian and sync keep working.
abstract final class LockedFolder {
  static const folder = SpecialFolder('Locked');
  static String get name => folder.name;

  /// Once unlocked, the folder stays open while the app is in use, and
  /// closes when the app has been away longer than this.
  static const relockAfter = Duration(seconds: 30);

  static bool contains(String f) => folder.contains(f);
  static String into(String f) => folder.into(f);
  static String outOf(String f) => folder.outOf(f);

  /// SQL: true when note [alias] (default `n`) is not locked.
  static String notLockedSql([String alias = 'n']) => folder.notInSqlFor(alias);
}
