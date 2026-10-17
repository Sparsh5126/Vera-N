/// Which line illustration an onboarding page shows (UI spec §4).
enum OnboardingArtKind {
  /// "Notes that stay yours.": a note with a padlock on its corner.
  privateNote,

  /// "Just write.": two notes joined by a dashed seal line, the app's mark
  /// for a suggestion.
  connections,

  /// "The thinking happens on your phone.": a phone with a few linked notes.
  onPhone,

  /// The laptop's version of [onPhone].
  onComputer,

  /// Reminders: a note line with a bell.
  reminder,

  /// "Choose where your notes live.": a folder with notes in it.
  folder,

  /// "What should we call you?": a greeting being written.
  name,
}
