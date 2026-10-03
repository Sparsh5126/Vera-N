import 'package:flutter/foundation.dart';

/// What a note card needs: no full body, so lists stay light.
@immutable
class NoteSummary {
  const NoteSummary({
    required this.ref,
    required this.title,
    required this.preview,
    required this.pinned,
    required this.modified,
    required this.folder,
  });

  final int ref;
  final String title;

  /// The start of the body, for the card's fading preview.
  final String preview;
  final bool pinned;
  final DateTime modified;
  final String folder;
}
