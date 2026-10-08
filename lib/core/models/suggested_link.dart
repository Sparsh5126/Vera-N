import 'linked_note.dart';
import 'suggestion.dart';

/// A link suggestion seen from one note: the suggestion and the other note.
class SuggestedLink {
  const SuggestedLink(this.suggestion, this.other);

  final Suggestion suggestion;
  final LinkedNote other;
}
