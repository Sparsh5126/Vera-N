import 'package:flutter/foundation.dart';

/// The known fields of a note's header (ARCHITECTURE.md §8).
///
/// Any field can be missing: imported notes may have no header at all.
/// There is no modified date; that comes from the file time.
@immutable
class NoteHeader {
  const NoteHeader({
    this.id,
    this.created,
    this.tags = const [],
    this.pinned = false,
  });

  final String? id;
  final DateTime? created;
  final List<String> tags;
  final bool pinned;

  NoteHeader copyWith({
    String? id,
    DateTime? created,
    List<String>? tags,
    bool? pinned,
  }) {
    return NoteHeader(
      id: id ?? this.id,
      created: created ?? this.created,
      tags: tags ?? this.tags,
      pinned: pinned ?? this.pinned,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NoteHeader &&
      other.id == id &&
      other.created == created &&
      listEquals(other.tags, tags) &&
      other.pinned == pinned;

  @override
  int get hashCode => Object.hash(id, created, Object.hashAll(tags), pinned);
}
