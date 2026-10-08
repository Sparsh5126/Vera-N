import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/locked_folder.dart';
import '../../../core/security/locked_session.dart';
import '../../../shared/widgets/locked_gate.dart';
import '../state/note_providers.dart';

/// Shows [child] (the editor), or the lock while the note is in the
/// Locked folder and the folder isn't open. Rebuilds only when the note's
/// folder or the lock changes, never while typing.
class LockedNoteGate extends ConsumerWidget {
  const LockedNoteGate({super.key, required this.noteRef, required this.child});

  final int? noteRef;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteRef = this.noteRef;
    if (noteRef == null) return child;
    final folder = ref.watch(
      noteProvider(noteRef).select((n) => n.value?.folder),
    );
    final open = ref.watch(lockedSessionProvider);
    if (folder == null || !LockedFolder.contains(folder) || open) return child;
    return LockedGate(
      message: AppCopy.lockedNoteHint,
      onUnlock: () =>
          unawaited(ref.read(lockedSessionProvider.notifier).open()),
    );
  }
}
