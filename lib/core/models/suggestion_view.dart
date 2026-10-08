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
  const SuggestionView(this.suggestion, this.newer, this.older);

  final Suggestion suggestion;
  final SuggestedNote newer;
  final SuggestedNote older;
}
