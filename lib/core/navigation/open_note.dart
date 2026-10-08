import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The note open beside the list on a wide window (docs/LAPTOP_PLAN.md,
/// L1). On a phone notes open full screen instead and this stays empty.
@immutable
class OpenNote {
  const OpenNote.existing(int this.ref, this.serial);
  const OpenNote.fresh(this.serial) : ref = null;

  /// Null for a new, not yet written note.
  final int? ref;

  /// Changes on every open, so opening the same note again (or a second
  /// new note) gives a fresh editor.
  final int serial;
}

final openNoteProvider = NotifierProvider<OpenNoteController, OpenNote?>(
  OpenNoteController.new,
);

class OpenNoteController extends Notifier<OpenNote?> {
  var _serial = 0;

  @override
  OpenNote? build() => null;

  void open(int ref) => state = OpenNote.existing(ref, ++_serial);

  void startNew() => state = OpenNote.fresh(++_serial);

  void close() => state = null;
}
