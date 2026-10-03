import 'dart:ui' show TextRange;

import 'package:flutter/foundation.dart';

/// Marks the search index puts around matched words (control characters,
/// so they never clash with note text).
const searchMatchStart = '\u0002';
const searchMatchEnd = '\u0003';

/// A piece of text and the parts of it that matched the search.
@immutable
class MarkedText {
  const MarkedText(this.text, this.matches);

  /// Splits text with [searchMatchStart]/[searchMatchEnd] marks into plain
  /// text and the matched ranges.
  factory MarkedText.parse(String marked) {
    final text = StringBuffer();
    final matches = <TextRange>[];
    var start = -1;
    for (final rune in marked.runes) {
      final char = String.fromCharCode(rune);
      if (char == searchMatchStart) {
        start = text.length;
      } else if (char == searchMatchEnd && start >= 0) {
        matches.add(TextRange(start: start, end: text.length));
        start = -1;
      } else {
        text.write(char);
      }
    }
    return MarkedText(text.toString(), matches);
  }

  final String text;
  final List<TextRange> matches;
}

/// One keyword search result.
@immutable
class SearchHit {
  const SearchHit({
    required this.ref,
    required this.title,
    required this.snippet,
    required this.modified,
  });

  final int ref;
  final MarkedText title;

  /// A short passage around the matched words.
  final MarkedText snippet;
  final DateTime modified;
}
