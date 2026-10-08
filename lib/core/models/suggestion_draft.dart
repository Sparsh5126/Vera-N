/// A new suggestion found by analysis, before it is stored.
class SuggestionDraft {
  const SuggestionDraft({
    required this.kind,
    required this.noteA,
    required this.noteB,
    required this.score,
    required this.chunkA,
    required this.chunkB,
  });

  /// `link` for now (product spec §16: link / tag / topic / resurface).
  final String kind;
  final int noteA;
  final int noteB;
  final double score;

  /// The best-matching chunk of each note, for "why related".
  final int chunkA;
  final int chunkB;
}
