import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/note_summary.dart';

/// The notes selected on Home (UI spec §5): holding a card and letting go
/// selects it, and while any are selected a tap adds or removes one.
/// Empty means not selecting. Each note's pinned state is kept, so the bar
/// can offer Pin or Unpin.
class HomeSelection extends Notifier<Map<int, bool>> {
  @override
  Map<int, bool> build() => const {};

  void toggle(NoteSummary note) => state = state.containsKey(note.ref)
      ? ({...state}..remove(note.ref))
      : {...state, note.ref: note.pinned};

  void clear() => state = const {};
}

final homeSelectionProvider = NotifierProvider<HomeSelection, Map<int, bool>>(
  HomeSelection.new,
);
