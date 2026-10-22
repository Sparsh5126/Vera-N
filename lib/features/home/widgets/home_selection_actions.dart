import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/device_lock.dart';
import '../../../core/storage/repositories/note_batch.dart';
import '../../../core/storage/repositories/search_repository.dart';
import '../../../core/utils/names.dart';
import '../../../shared/widgets/folder_picker.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import '../../../shared/widgets/undo_snack_bar.dart';

/// What the selection bar does to the selected notes (UI spec §5). Each
/// action ends selecting, and the ones that move notes offer one Undo for
/// the whole batch, never a confirmation. All are also inside each note.
class HomeSelectionActions {
  HomeSelectionActions({
    required this.batch,
    required this.library,
    required this.deviceLock,
    required this.done,
  });

  final NoteBatch batch;
  final SearchRepository library;
  final DeviceLock deviceLock;

  /// Ends selecting.
  final VoidCallback done;

  Future<void> moveToFolder(BuildContext context, Set<int> refs) async {
    final messenger = ScaffoldMessenger.of(context);
    final folders = await library.folders();
    if (!context.mounted) return;
    final folder = await FolderPicker.pick(
      context,
      folders: folders,
      cleanName: Names.folder,
    );
    if (folder == null) return;
    await moveTo(messenger, refs, folder);
  }

  /// Moves [refs] into [folder]: the Folder button, or a drop on a folder.
  Future<void> moveTo(
    ScaffoldMessengerState messenger,
    Set<int> refs,
    String folder,
  ) async {
    final old = await batch.move(refs, folder);
    done();
    _undo(messenger, HomeCopy.movedNotes(old.length, folder), old);
  }

  /// Locking needs a screen lock on the phone, or the notes couldn't be
  /// opened again.
  Future<void> lock(ScaffoldMessengerState messenger, Set<int> refs) async {
    if (!await deviceLock.hasScreenLock()) {
      NoticeSnackBar.show(messenger, AppCopy.needScreenLock, long: true);
      return;
    }
    final old = await batch.lock(refs);
    done();
    _undo(messenger, HomeCopy.lockedNotes(old.length), old);
  }

  Future<void> archive(ScaffoldMessengerState messenger, Set<int> refs) async {
    final old = await batch.archive(refs);
    done();
    _undo(messenger, HomeCopy.archivedNotes(old.length), old);
  }

  /// Pinning shows at once on Home, so it needs no Undo.
  Future<void> pin(Set<int> refs, {required bool pinned}) async {
    await batch.pin(refs, pinned: pinned);
    done();
  }

  Future<void> delete(ScaffoldMessengerState messenger, Set<int> refs) async {
    await batch.trash(refs);
    done();
    UndoSnackBar.show(
      messenger,
      message: HomeCopy.trashedNotes(refs.length),
      onUndo: () => unawaited(batch.restore(refs)),
    );
  }

  /// Merges [refs], in the order selected, into the first (user,
  /// 2026-10-22), with one Undo.
  Future<void> merge(ScaffoldMessengerState messenger, List<int> refs) async {
    if (await batch.mergeWouldUnlock(refs)) {
      NoticeSnackBar.show(messenger, HomeCopy.mergeLockedFirst, long: true);
      return;
    }
    final merged = await batch.merge(refs);
    done();
    if (merged == null) return;
    UndoSnackBar.show(
      messenger,
      message: HomeCopy.mergedInto(merged.title),
      onUndo: () => unawaited(merged.undo()),
    );
  }

  /// One Undo for every note moved; nothing moved, nothing to say.
  void _undo(
    ScaffoldMessengerState messenger,
    String message,
    Map<int, String> old,
  ) {
    if (old.isEmpty) return;
    UndoSnackBar.show(
      messenger,
      message: message,
      onUndo: () => unawaited(batch.putBack(old)),
    );
  }
}
