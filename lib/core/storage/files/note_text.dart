import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'note_links.dart';

/// Values derived from a note's body text.
abstract final class NoteText {
  static final _heading = RegExp(r'^#{1,6}\s+');

  /// The title is the first non-empty line, without Markdown heading marks,
  /// with links shown as their titles.
  /// Empty when the note has no text.
  static String title(String body) {
    for (final line in const LineSplitter().convert(body)) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        return NoteLinks.displayText(trimmed.replaceFirst(_heading, ''));
      }
    }
    return '';
  }

  /// The body after the title line, for card previews, with links shown
  /// as their titles.
  static String preview(String body) {
    final lines = const LineSplitter().convert(body);
    final titleAt = lines.indexWhere((l) => l.trim().isNotEmpty);
    if (titleAt == -1) return '';
    return NoteLinks.displayText(lines.skip(titleAt + 1).join('\n').trim());
  }

  /// SHA-256 of the body with line endings normalized, so the same text
  /// saved on Windows and Android hashes the same. Header changes (pin,
  /// tags) don't change it, so they never trigger re-analysis.
  static String contentHash(String body) {
    final normalized = body.replaceAll('\r\n', '\n');
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}
