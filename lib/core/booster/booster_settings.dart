/// Every tunable value of the laptop booster (docs/LAPTOP_PLAN.md, L2), in
/// one place like `ai_settings.dart`.
abstract final class BoosterSettings {
  /// Model calls per idle run; the loop carries on while still idle.
  static const asksPerRun = 12;

  /// Note text sent per note is cut to this many characters.
  static const maxNoteChars = 3000;

  /// Notes shorter than this many words get no tag names.
  static const minWordsForTags = 12;

  /// Existing tag names listed in the tag prompt, at most.
  static const knownTagsInPrompt = 80;

  /// New tag names per note (as today's tag suggestions).
  static const tagsPerNote = 2;

  /// A tag name: 2 to 30 characters.
  static const tagMinLength = 2;
  static const tagMaxLength = 30;

  /// Notes whose average meanings are at least this close form a topic.
  static const topicSimilarity = 0.70;

  /// Notes in a topic: at least 3, at most 8 (the closest are kept).
  static const topicMin = 3;
  static const topicMax = 8;

  /// Notes this close on average are checked as duplicates.
  static const duplicateSimilarity = 0.93;

  /// The shorter of two duplicate candidates is at least this share of
  /// the longer, so a short note isn't a "copy" of a long one.
  static const duplicateLengthRatio = 0.5;

  /// The written "Why?" is cut to this many characters.
  static const sentenceMaxChars = 160;
}
