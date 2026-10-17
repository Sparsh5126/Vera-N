import 'package:flutter/foundation.dart';

/// What a drag on Home carries: the held note, or every selected note
/// when the held one is selected.
@immutable
class DraggedNotes {
  const DraggedNotes(this.refs);

  final Set<int> refs;
}
