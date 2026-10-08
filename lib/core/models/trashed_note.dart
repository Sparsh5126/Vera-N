import 'package:flutter/foundation.dart';

/// A note in the trash, for the Trash screen.
@immutable
class TrashedNote {
  const TrashedNote({
    required this.ref,
    required this.title,
    required this.preview,
    required this.trashedAt,
    this.locked = false,
  });

  final int ref;
  final String title;
  final String preview;
  final DateTime trashedAt;

  /// From the Locked folder: shown without its title or text.
  final bool locked;
}
