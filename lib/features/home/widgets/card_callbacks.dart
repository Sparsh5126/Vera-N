import 'package:flutter/foundation.dart';

import '../../../core/models/note_summary.dart';

/// What a note card on Home does (UI spec §5): a tap opens the note, or,
/// while notes are selected, adds or removes it; holding it selects it.
@immutable
class CardCallbacks {
  const CardCallbacks({
    required this.tap,
    required this.hold,
    this.selected = const {},
  });

  final ValueChanged<NoteSummary> tap;
  final ValueChanged<NoteSummary> hold;

  /// The selected notes' refs.
  final Set<int> selected;

  bool isSelected(int ref) => selected.contains(ref);
}
