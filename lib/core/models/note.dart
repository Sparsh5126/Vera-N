import 'package:flutter/foundation.dart';

/// A note as the app shows it. Built from the index database.
@immutable
class Note {
  const Note({
    required this.ref,
    required this.path,
    required this.folder,
    required this.title,
    required this.body,
    required this.tags,
    required this.pinned,
    required this.created,
    required this.modified,
    this.noteId,
    this.conflict = false,
  });

  /// Database row id: stable while the app runs, used for navigation.
  /// Not written to files; [noteId] or [path] is the lasting identity.
  final int ref;

  /// Header `id`, or null for a headerless note.
  final String? noteId;

  /// Path inside the notes folder.
  final String path;
  final String folder;
  final String title;
  final String body;
  final List<String> tags;
  final bool pinned;
  final DateTime created;
  final DateTime modified;

  /// The file changed elsewhere while this note had an unsaved edit.
  final bool conflict;

  /// Lasting identity: header `id` when present, otherwise the path.
  String get identity => noteId ?? path;
}
