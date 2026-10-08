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
    this.suggested = false,
    this.conflict = false,
  });

  final int ref;
  final String title;

  /// The start of the body, for the card's fading preview.
  final String preview;
  final bool pinned;
  final DateTime modified;
  final String folder;

  /// AI suggestions involving this note are waiting: its card shows a
  /// small dimmed dot, never a number (UI spec §5).
  final bool suggested;

  /// Changed both here and outside the app; the note view offers the
  /// way out (product spec §14).
  final bool conflict;
}
