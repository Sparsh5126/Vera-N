import 'package:flutter/foundation.dart';

/// One Markdown file in the notes folder.
@immutable
class NoteFileEntry {
  const NoteFileEntry({
    required this.path,
    required this.modified,
    required this.size,
  });

  /// Relative to the notes folder, `/`-separated, e.g. `Ideas/20261003-153228-a7f3.md`.
  final String path;
  final DateTime modified;
  final int size;
}

/// Raw file access to the notes folder (`MyNotes/Notes/`).
///
/// Implemented by the Android folder picker bridge and by plain files (the
/// app-private holding folder, desktop, and tests). Only the indexer and
/// repositories use this; the UI reads the database.
///
/// Paths are relative and `/`-separated. Folders and files whose names start
/// with `.` (for example `.obsidian`, `.trash`) are never listed.
abstract interface class NoteFileStore {
  /// Every `.md` file, in all subfolders.
  Future<List<NoteFileEntry>> listNotes();

  Future<bool> exists(String path);

  /// Time and size of one file, or null if it doesn't exist.
  Future<NoteFileEntry?> stat(String path);

  Future<String> read(String path);

  /// Writes the whole file, creating parent folders. Returns the new entry.
  Future<NoteFileEntry> write(String path, String content);

  Future<void> move(String from, String to);

  Future<void> delete(String path);

  /// `MyNotes/.app/[name]`: the little app data that must survive
  /// uninstall and reach other devices (ARCHITECTURE.md §8), such as the
  /// rejections file. Null if it doesn't exist.
  Future<String?> readAppFile(String name);

  Future<void> writeAppFile(String name, String content);

  /// Names of the files in `MyNotes/.app/` (empty if there is none), for
  /// example every device's rejections file.
  Future<List<String>> listAppFiles();
}

/// Checks that [name] is a plain file name for `.app/`.
String checkAppFileName(String name) {
  if (name.isEmpty ||
      name.contains('/') ||
      name.contains(r'\') ||
      name.startsWith('.')) {
    throw ArgumentError.value(name, 'name', 'not a safe app file name');
  }
  return name;
}

/// Checks that [path] stays inside the notes folder and returns its
/// segments. Throws [ArgumentError] for absolute paths, `..`, backslashes,
/// or empty segments.
List<String> checkNotePath(String path) {
  final segments = path.split('/');
  final unsafe =
      path.isEmpty ||
      path.startsWith('/') ||
      path.contains(r'\') ||
      segments.any((s) => s.isEmpty || s == '.' || s == '..');
  if (unsafe) throw ArgumentError.value(path, 'path', 'not a safe note path');
  return segments;
}
