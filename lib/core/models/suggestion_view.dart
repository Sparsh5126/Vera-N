import 'suggestion.dart';

/// One note of a suggested pair, as the suggestion card shows it.
class SuggestedNote {
  const SuggestedNote({
    required this.ref,
    required this.title,
    required this.created,
    required this.passage,
  });

  final int ref;
  final String title;
  final DateTime created;

  /// The part of the note that matched, as a reader sees it.
  final String passage;
}

/// A suggestion with both notes ready to show: the newer note first.
class SuggestionView {
  const SuggestionView(this.suggestion, this.newer, this.older, {this.keep});

  final Suggestion suggestion;
  final SuggestedNote newer;
  final SuggestedNote older;

  /// For copies: the note Merge keeps.
  final int? keep;

  /// A new tag name from the laptop: no other note has it, so the card
  /// shows only the note to tag.
  bool get single => suggestion.isTag && suggestion.noteA == suggestion.noteB;

  SuggestedNote? noteOf(int ref) => newer.ref == ref
      ? newer
      : older.ref == ref
      ? older
      : null;
}
