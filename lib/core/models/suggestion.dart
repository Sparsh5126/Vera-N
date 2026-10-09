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
    this.tag = '',
    this.detail = '',
    this.fromLaptop = false,
  });

  final int id;

  /// `link`, `tag`, `resurface` or `duplicate`.
  final String kind;

  /// A link joins [noteA] and [noteB]. A tag is suggested for [noteA];
  /// [noteB] is the closest note that already has it (the reason).
  final int noteA;
  final int noteB;

  /// The suggested tag, without `#`; empty for links.
  final String tag;

  /// A sentence the laptop wrote (docs/LAPTOP_PLAN.md, L3): why a link
  /// fits, or what two copies share. Empty when there is none.
  final String detail;

  /// Made by the laptop booster; see the `fromLaptop` column.
  final bool fromLaptop;

  bool get isTag => kind == tagKind;
  bool get isLink => kind == linkKind;
  bool get isDuplicate => kind == duplicateKind;

  static const linkKind = 'link';
  static const tagKind = 'tag';

  /// Two notes that say the same thing, found by the laptop: Merge or
  /// Remove one (docs/LAPTOP_PLAN.md, decided 2026-10-09).
  static const duplicateKind = 'duplicate';

  /// Revisit (product spec §10): [noteA] is an old note worth another
  /// look, [noteB] the recent note it relates to. Never reviewed in
  /// batches; it has its own Home card and screen.
  static const resurfaceKind = 'resurface';
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
