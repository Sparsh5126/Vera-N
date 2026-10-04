import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/note.dart';
import '../../../core/storage/repositories/links_repository.dart';
import '../../../core/storage/repositories/notes_repository.dart';
import '../../../core/storage/repositories/search_repository.dart';
import '../../../core/utils/names.dart';
import '../../../shared/widgets/option_sheet.dart';
import '../../../shared/widgets/text_entry_sheet.dart';
import '../../../shared/widgets/undo_snack_bar.dart';
import '../state/note_editor_controller.dart';
import 'note_picker_sheet.dart';

/// The Note screen's sheets: link to a note, add or remove a tag, move to
/// a folder. Changes offer Undo instead of asking for confirmation first.
class NoteActions {
  NoteActions(this._editor, this._library, this._links, this._notes);

  /// Picked in the folder sheet to type a new folder name.
  static const _newFolder = '\u0000new';

  final NoteEditorController _editor;

  /// Existing folders and tags, offered before inventing new ones.
  final SearchRepository _library;
  final LinksRepository _links;
  final NotesRepository _notes;

  /// Pick a note and get the link text to insert, or null if the user
  /// backed out. With [label], the link shows those words (the selection)
  /// instead of the note's title.
  Future<String?> pickLink(
    BuildContext context,
    int? currentRef, {
    String? label,
  }) async {
    final notes = await _notes.allNotes();
    if (!context.mounted) return null;
    final picked = await NotePickerSheet.show(context, [
      for (final n in notes)
        if (n.ref != currentRef) n,
    ]);
    return picked == null ? null : _links.linkTextFor(picked, label: label);
  }

  Future<void> addTag(BuildContext context, Note note) async {
    final existing = await _library.tags();
    if (!context.mounted) return;
    final typed = await TextEntrySheet.show(
      context,
      hint: AppCopy.tagNameHint,
      labelFor: AppCopy.tagLabel,
      suggestions: [
        for (final t in existing)
          if (!note.tags.any((n) => n.toLowerCase() == t.toLowerCase())) t,
      ],
    );
    if (typed != null) await _editor.addTag(typed, note.tags);
  }

  Future<void> tagTapped(BuildContext context, Note note, String tag) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await OptionSheet.show<String>(
      context,
      selected: null,
      options: [SheetOption(tag, AppCopy.removeTag(tag))],
    );
    if (picked == null) return;
    await _editor.removeTag(tag, note.tags);
    _undo(messenger, AppCopy.tagRemoved, () => _editor.setTags(note.tags));
  }

  Future<void> moveToFolder(BuildContext context, Note note) async {
    final messenger = ScaffoldMessenger.of(context);
    final folders = await _library.folders();
    if (!context.mounted) return;
    final picked = await OptionSheet.show<String>(
      context,
      selected: note.folder,
      options: [
        const SheetOption('', AppCopy.noFolder),
        for (final f in folders) SheetOption(f, f),
        const SheetOption(_newFolder, AppCopy.newFolder),
      ],
    );
    var folder = picked?.value;
    if (folder == _newFolder && context.mounted) {
      final typed = await TextEntrySheet.show(
        context,
        hint: AppCopy.folderNameHint,
      );
      folder = typed == null ? null : Names.folder(typed);
    }
    if (folder == null || folder == note.folder) return;
    final old = await _editor.moveToFolder(folder);
    if (old == null) return;
    final message = folder.isEmpty
        ? AppCopy.movedOutOfFolder
        : AppCopy.movedTo(folder);
    _undo(messenger, message, () => _editor.moveToFolder(old));
  }

  void _undo(
    ScaffoldMessengerState messenger,
    String message,
    Future<Object?> Function() undo,
  ) {
    UndoSnackBar.show(
      messenger,
      message: message,
      onUndo: () => unawaited(undo()),
    );
  }
}
