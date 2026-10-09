import 'note_footer.dart';

/// "Merge" for two notes that say the same thing (docs/LAPTOP_PLAN.md,
/// decided 2026-10-09): the kept note gains only the lines it doesn't
/// already have, so lines in both appear once. Its own text is never
/// changed or reordered; new lines go after it, above its "Linked notes",
/// and the other note's links join that footer.
abstract final class NoteMerge {
  static String merge(String kept, String other) {
    final (keptMain, keptLinks) = NoteFooter.split(kept);
    final (otherMain, otherLinks) = NoteFooter.split(other);
    final have = {for (final l in keptMain.split('\n')) l.trim()};
    final added = <String>[];
    for (final line in otherMain.split('\n')) {
      final key = line.trim();
      if (key.isEmpty || have.contains(key)) continue;
      have.add(key);
      added.add(line.trimRight());
    }
    final links = [
      ...keptLinks,
      for (final l in otherLinks)
        if (!keptLinks.contains(l)) l,
    ];
    final parts = [
      if (keptMain.isNotEmpty) keptMain,
      if (added.isNotEmpty) added.join('\n'),
      if (links.isNotEmpty) '${NoteFooter.heading}\n${links.join('\n')}',
    ];
    return '${parts.join('\n\n')}\n';
  }
}
