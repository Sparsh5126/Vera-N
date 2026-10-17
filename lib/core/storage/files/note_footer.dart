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

  /// [body] without its footer: the user's own words, which is all the AI
  /// reads. It is a prefix of [body], so positions in it are positions in
  /// the note.
  static String strip(String body) {
    final (main, links) = split(body);
    return links.isEmpty ? body : main;
  }

  /// [body] split into the text above the footer and the footer's link
  /// lines (none when it has no footer).
  static (String, List<String>) split(String body) {
    final lines = body.trimRight().split('\n');
    var i = lines.length;
    while (i > 0 && lines[i - 1].trim().startsWith('- [[')) {
      i--;
    }
    if (i == 0 || lines[i - 1].trim() != heading) {
      return (body.trimRight(), const []);
    }
    return (
      lines.take(i - 1).join('\n').trimRight(),
      [for (final l in lines.skip(i)) l.trim()],
    );
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
