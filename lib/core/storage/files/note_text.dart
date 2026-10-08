import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'note_markup.dart';

/// Values derived from a note's body text.
abstract final class NoteText {
  static final _heading = RegExp(r'^#{1,6}\s+');

  /// The title is the first line with words, without Markdown heading
  /// marks, as a reader sees it (see [NoteMarkup.display]); an attachment
  /// on its own line is skipped. Empty when the note has no text.
  static String title(String body) {
    for (final line in const LineSplitter().convert(body)) {
      final shown = NoteMarkup.display(line.trim().replaceFirst(_heading, ''))
          .trim();
      if (shown.isNotEmpty) return shown;
    }
    return '';
  }

  /// The body after the title line, for card previews, as a reader sees it.
  static String preview(String body) {
    final lines = const LineSplitter().convert(body);
    final titleAt = lines.indexWhere(
      (l) => NoteMarkup.display(l).trim().isNotEmpty,
    );
    if (titleAt == -1) return '';
    return NoteMarkup.display(
      lines.skip(titleAt + 1).join('\n').trim(),
      forScreen: true,
    );
  }

  /// SHA-256 of the body with line endings normalized, so the same text
  /// saved on Windows and Android hashes the same. Header changes (pin,
  /// tags) don't change it, so they never trigger re-analysis.
  static String contentHash(String body) {
    final normalized = body.replaceAll('\r\n', '\n');
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}
