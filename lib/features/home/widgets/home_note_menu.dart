import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/note_summary.dart';
import '../../../core/storage/repositories/notes_repository.dart';
import '../../../shared/widgets/option_sheet.dart';
import '../../../shared/widgets/undo_snack_bar.dart';

enum _CardAction { pin, delete }

/// Long-press on a note card: Pin or Unpin, and Delete. Delete moves the
/// note to the trash and offers Undo, never a confirmation. Both actions
/// are also inside the note (the pin button and the ⋮ menu).
class HomeNoteMenu {
  HomeNoteMenu(this._notes);

  final NotesRepository _notes;

  Future<void> show(BuildContext context, NoteSummary note) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await OptionSheet.show<_CardAction>(
      context,
      selected: null,
      options: [
        SheetOption(_CardAction.pin, note.pinned ? AppCopy.unpin : AppCopy.pin),
        const SheetOption(_CardAction.delete, AppCopy.delete),
      ],
    );
    switch (picked?.value) {
      case _CardAction.pin:
        await _notes.setPinned(note.ref, !note.pinned);
      case _CardAction.delete:
        await _notes.trash(note.ref);
        UndoSnackBar.show(
          messenger,
          message: AppCopy.movedToTrash,
          onUndo: () => unawaited(_notes.restore(note.ref)),
        );
      case null:
        break;
    }
  }
}
