/// Tunable values for on-device analysis, in one place (product spec §4,
/// §7; ARCHITECTURE.md §7–8). Thresholds are tuned later from accept rates.
abstract final class AiSettings {
  /// A "strong" match: cosine similarity of two chunks (decided 2026-10-04).
  static const strongMatch = 0.60;

  /// "Similar in meaning" in Search: a short query against a passage
  /// scores lower than two passages do, so the bar is lower than
  /// [strongMatch]; [similarResults] caps the list. Tuned from use.
  static const similarSearch = 0.40;
  static const similarResults = 5;

  /// Pause after the last keystroke before Search asks the model, so
  /// keyword results never wait and typing never stutters.
  static const similarDelay = Duration(milliseconds: 400);

  /// Tokens per chunk: the model reads 128, two of which are `<s>`, `</s>`.
  static const chunkTokens = 126;

  /// Notes shorter than this many words aren't matched: too little meaning
  /// to judge, and they produce chance matches.
  static const minWords = 4;

  /// A rejected pair may come back only when a note's words changed a lot:
  /// less than this share of them still the same (decided 2026-10-04).
  static const sameNoteWords = 2 / 3;

  /// Two strongly matching notes are copies, offered to merge instead of
  /// link, when at least this share of their words is the same (user,
  /// 2026-10-22). Copies made by sync share all of them; a related note
  /// written separately shares far fewer (0.69 in the tests' closest pair).
  static const copyWords = 0.8;

  /// Review batches hold this many suggestions (UI spec §6).
  static const batchSize = 5;

  /// At most this many new suggestions per changed note, strongest first.
  static const suggestionsPerNote = 3;

  /// Tag suggestions: the closest notes looked at, and at most this many
  /// tags suggested per changed note.
  static const tagNeighbours = 10;
  static const tagsPerNote = 2;

  /// Revisit (product spec §10; decided 2026-10-08): a note untouched for
  /// [revisitAfter] that strongly matches a note changed within
  /// [recentWindow]. At most [revisitShown] at a time; "Not now" hides one
  /// for [revisitAfter].
  static const revisitAfter = Duration(days: 30);
  static const recentWindow = Duration(days: 7);
  static const revisitShown = 5;

  /// Unreviewed suggestions disappear after this (product spec §7).
  static const suggestionLifetime = Duration(days: 30);

  /// Notes analyzed per run; the rest wait for the next run.
  static const notesPerRun = 200;

  /// Wait after the app is left before analysis may start, so a quick
  /// return to the note doesn't run it mid-thought.
  static const startDelay = Duration(minutes: 1);

  /// A run stops starting new notes after this, well inside the 10 minutes
  /// Android gives background work.
  static const runBudget = Duration(minutes: 8);
}
