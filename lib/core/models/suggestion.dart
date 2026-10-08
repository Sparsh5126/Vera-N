/// A stored AI suggestion waiting for review (product spec §7, §16).
class Suggestion {
  const Suggestion({
    required this.id,
    required this.kind,
    required this.noteA,
    required this.noteB,
    required this.score,
    required this.chunkA,
    required this.chunkB,
    required this.notSure,
    required this.createdAt,
    required this.expiresAt,
  });

  final int id;

  /// `link` for now.
  final String kind;
  final int noteA;
  final int noteB;
  final double score;

  /// The best-matching chunk of each note, for highlighting.
  final int chunkA;
  final int chunkB;

  /// The user chose "Not sure": it comes back in a later batch.
  final bool notSure;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// The other note of the pair, seen from [note].
  int otherThan(int note) => note == noteA ? noteB : noteA;
}
