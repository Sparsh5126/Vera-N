import 'package:flutter/foundation.dart';

import 'suggestion.dart';

/// An old note worth another look (product spec §10), and the recent note
/// that made it relevant again.
@immutable
class RevisitItem {
  const RevisitItem({
    required this.suggestion,
    required this.title,
    required this.preview,
    required this.modified,
    required this.recentTitle,
  });

  final Suggestion suggestion;
  int get ref => suggestion.noteA;
  final String title;
  final String preview;

  /// When the old note last changed.
  final DateTime modified;
  final String recentTitle;
}
