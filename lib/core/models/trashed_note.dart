import 'package:flutter/foundation.dart';

/// A note in the trash, for the Trash screen.
@immutable
class TrashedNote {
  const TrashedNote({
    required this.ref,
    required this.title,
    required this.preview,
    required this.trashedAt,
  });

  final int ref;
  final String title;
  final String preview;
  final DateTime trashedAt;
}
