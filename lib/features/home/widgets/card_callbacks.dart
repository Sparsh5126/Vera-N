import 'package:flutter/foundation.dart';

import '../../../core/models/note_summary.dart';

/// What a note card on Home does: a tap opens the note, a long press
/// offers Pin and Delete (both also inside the note itself).
@immutable
class CardCallbacks {
  const CardCallbacks({required this.open, required this.menu});

  final ValueChanged<int> open;
  final ValueChanged<NoteSummary> menu;
}
