import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/archive_folder.dart';
import '../../../core/models/locked_folder.dart';
import '../../../core/models/note.dart';
import '../../../core/storage/files/note_markup.dart';
import '../../../core/storage/repositories/links_repository.dart';
import '../../../core/storage/repositories/notes_repository.dart';
import '../../../core/storage/repositories/search_repository.dart';
import '../../../core/utils/names.dart';
import '../../../shared/widgets/folder_picker.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import '../../../shared/widgets/option_sheet.dart';
import '../../../shared/widgets/text_entry_sheet.dart';
import '../../../shared/widgets/undo_snack_bar.dart';
import '../state/note_editor_controller.dart';
import 'note_picker_sheet.dart';

/// The Note screen's actions: copy, link to a note, add or remove a tag,
/// move to a folder. Changes offer Undo instead of asking for confirmation first.
class NoteActions {
  NoteActions(this._editor, this._library, this._links, this._notes);

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
    // Locked notes can be linked only from a note that is locked too.
    final current = currentRef == null
        ? null
        : await _notes.getNote(currentRef);
    final notes = await _notes.allNotes(
      includeLocked: current != null && LockedFolder.contains(current.folder),
    );
    if (!context.mounted) return null;
    final picked = await NotePickerSheet.show(context, [
      for (final n in notes)
        if (n.ref != currentRef) n,
    ]);
    return picked == null ? null : _links.linkTextFor(picked, label: label);
  }

  /// Copies the whole note as the user sees it: links as their titles,
  /// checklists as ☐ / ☑, no Markdown symbols.
  Future<void> copy(BuildContext context, String body) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(text: NoteMarkup.display(body, keepUrls: true)),
    );
    NoticeSnackBar.show(messenger, AppCopy.copied);
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
    final folder = await FolderPicker.pick(
      context,
      folders: folders,
      cleanName: Names.folder,
      current: note.folder,
    );
    if (folder == null || folder == note.folder) return;
    final old = await _editor.moveToFolder(folder);
    if (old == null) return;
    final message = folder.isEmpty
        ? AppCopy.movedOutOfFolder
        : AppCopy.movedTo(folder);
    _undo(messenger, message, () => _editor.moveToFolder(old));
  }

  /// Archive moves the note into `Archive/` (keeping its folder inside)
  /// and leaves it; Unarchive puts it back. Both offer Undo.
  Future<void> toggleArchive(
    BuildContext context,
    Note note, {
    required VoidCallback leave,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final archiving = !ArchiveFolder.contains(note.folder);
    final target = archiving
        ? ArchiveFolder.into(note.folder)
        : ArchiveFolder.outOf(note.folder);
    final old = await _editor.moveToFolder(target);
    if (old == null) return;
    if (archiving) leave();
    _undo(
      messenger,
      archiving ? AppCopy.archived : AppCopy.unarchived,
      () => _editor.moveToFolder(old),
    );
  }

  /// Locking moves the note into `Locked/` (keeping its folder inside),
  /// forgets what the AI stored about it, and leaves it; taking it out
  /// puts it back (the AI may read it again). Both offer Undo. Locking
  /// needs a screen lock on the phone, or the note couldn't be opened.
  Future<void> toggleLock(
    BuildContext context,
    Note note, {
    required Future<bool> Function() hasScreenLock,
    required Future<void> Function() forgetLocked,
    required VoidCallback leave,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final locking = !LockedFolder.contains(note.folder);
    if (locking && !await hasScreenLock()) {
      NoticeSnackBar.show(messenger, AppCopy.needScreenLock, long: true);
      return;
    }
    final target = locking
        ? LockedFolder.into(note.folder)
        : LockedFolder.outOf(note.folder);
    final old = await _editor.moveToFolder(target);
    if (old == null) return;
    if (locking) {
      await forgetLocked();
      leave();
    }
    _undo(
      messenger,
      locking ? AppCopy.movedToLocked : AppCopy.movedOutOfLocked,
      () async {
        await _editor.moveToFolder(old);
        if (!locking) await forgetLocked();
        return null;
      },
    );
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
