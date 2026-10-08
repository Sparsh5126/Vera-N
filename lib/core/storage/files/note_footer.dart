/// The "Linked notes" block at the end of a note, where links the user
/// accepted from suggestions are written (decided 2026-10-04, product
/// spec §5). Only ever appended to; the user's text above is never touched.
abstract final class NoteFooter {
  static const heading = '## Linked notes';

  /// [body] with `- [link]` added to the footer, starting the footer if
  /// the note doesn't end with one.
  static String append(String body, String link) {
    final line = '- $link';
    final trimmed = body.trimRight();
    if (_endsWithFooter(trimmed)) return '$trimmed\n$line\n';
    final gap = trimmed.isEmpty ? '' : '\n\n';
    return '$trimmed$gap$heading\n$line\n';
  }

  /// Whether the last lines of [text] are the heading and link lines.
  static bool _endsWithFooter(String text) {
    final lines = text.split('\n');
    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].trim();
      if (line == heading) return true;
      if (!line.startsWith('- [[')) return false;
    }
    return false;
  }
}
