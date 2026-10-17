import 'package:flutter/foundation.dart';

/// A folder on Home's Folders view: its path inside `Notes/` and how many
/// notes it holds, its subfolders' included (what opening it shows).
@immutable
class FolderSummary {
  const FolderSummary(this.path, this.notes);

  /// `/`-separated, as on disk, e.g. `Ideas/Story`.
  final String path;
  final int notes;

  /// The folder's own name: the last part of [path].
  String get name => path.substring(path.lastIndexOf('/') + 1);

  /// The folders it sits in (`Ideas` for `Ideas/Story`), or null at the top.
  String? get parent {
    final cut = path.lastIndexOf('/');
    return cut < 0 ? null : path.substring(0, cut);
  }

  @override
  bool operator ==(Object other) =>
      other is FolderSummary && other.path == path && other.notes == notes;

  @override
  int get hashCode => Object.hash(path, notes);
}
