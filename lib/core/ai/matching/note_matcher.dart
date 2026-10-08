import '../../models/chunk_vector.dart';
import 'vectors.dart';

/// A note that matches another strongly, and the chunks that matched best.
class NoteMatch {
  const NoteMatch(this.note, this.score, this.ownChunk, this.otherChunk);

  final int note;
  final double score;
  final int ownChunk;
  final int otherChunk;
}

/// Finds strong matches for one note: two notes match as strongly as their
/// best-matching chunks do (product spec §7: strong matches only).
abstract final class NoteMatcher {
  static List<NoteMatch> strongMatches(
    List<ChunkVector> own,
    Iterable<ChunkVector> others, {
    required double threshold,
    required int limit,
    Set<int> exclude = const {},
  }) {
    final best = <int, NoteMatch>{};
    for (final other in others) {
      if (exclude.contains(other.note)) continue;
      for (final mine in own) {
        if (mine.note == other.note) continue;
        final score = Vectors.cosine(mine.vector, other.vector);
        if (score < threshold) continue;
        final current = best[other.note];
        if (current == null || score > current.score) {
          best[other.note] = NoteMatch(other.note, score, mine.idx, other.idx);
        }
      }
    }
    final matches = best.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return matches.take(limit).toList();
  }
}
