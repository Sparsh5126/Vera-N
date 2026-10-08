import 'note_matcher.dart';

/// A tag worth suggesting for a note, and the closest note that has it.
class TagCandidate {
  const TagCandidate(this.tag, this.score, this.evidence);

  final String tag;

  /// The average match of the neighbours that have the tag.
  final double score;

  /// The best-matching neighbour with the tag: the reason shown.
  final NoteMatch evidence;
}

/// Tag suggestions on the phone, without a language model (decided
/// 2026-10-08): a tag several notes very close in meaning already share,
/// which this note lacks, is suggested. Only existing tags are reused, so
/// no near-duplicates appear (product spec §11); new tag names come later
/// from the laptop layer.
abstract final class TagSuggester {
  /// Neighbours that must share a tag before it is suggested.
  static const minNeighbours = 2;

  /// [neighbours] are the note's strong matches, best first; [tagsOf] the
  /// tags of each; [own] and [rejected] the tags never to suggest (any
  /// letter case). At most [limit], best first.
  static List<TagCandidate> forNote({
    required List<NoteMatch> neighbours,
    required Map<int, Set<String>> tagsOf,
    required Set<String> own,
    required Set<String> rejected,
    required int limit,
  }) {
    final skip = {
      for (final t in [...own, ...rejected]) t.toLowerCase(),
    };
    final byTag = <String, List<NoteMatch>>{};
    final spelling = <String, String>{};
    for (final n in neighbours) {
      for (final tag in tagsOf[n.note] ?? const <String>{}) {
        final key = tag.toLowerCase();
        if (skip.contains(key)) continue;
        spelling.putIfAbsent(key, () => tag);
        (byTag[key] ??= []).add(n);
      }
    }
    final candidates = [
      for (final MapEntry(key: key, value: notes) in byTag.entries)
        if (notes.length >= minNeighbours)
          TagCandidate(
            spelling[key]!,
            notes.map((n) => n.score).reduce((a, b) => a + b) / notes.length,
            notes.reduce((a, b) => a.score >= b.score ? a : b),
          ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return candidates.take(limit).toList();
  }
}
