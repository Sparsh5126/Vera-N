/// A new suggestion found by analysis, before it is stored.
class SuggestionDraft {
  const SuggestionDraft({
    required this.kind,
    required this.noteA,
    required this.noteB,
    required this.score,
    required this.chunkA,
    required this.chunkB,
    this.tag = '',
  });

  /// `link` or `tag` (product spec §16: link / tag / topic / resurface).
  final String kind;

  /// A link joins [noteA] and [noteB]. A tag is suggested for [noteA];
  /// [noteB] is the closest note that already has it.
  final int noteA;
  final int noteB;

  /// The suggested tag, without `#`; empty for links.
  final String tag;
  final double score;

  /// The best-matching chunk of each note, for "why related".
  final int chunkA;
  final int chunkB;
}
