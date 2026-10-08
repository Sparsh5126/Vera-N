import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/locked_folder.dart';
import '../../../core/models/search_filters.dart';
import '../../../core/platform/device_lock.dart';
import '../../../core/security/locked_session.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/filter_pill.dart';
import '../../../shared/widgets/locked_gate.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import '../state/home_view.dart';
import 'card_callbacks.dart';
import 'note_cards.dart';

/// Home's Folders or Tags view: a pill per folder or tag; tapping one
/// shows its notes below (a folder includes its subfolders), tapping it
/// again clears the choice. Folders end with a Locked pill when the
/// Locked folder has notes; it opens with the phone's lock.
class GroupView extends ConsumerWidget {
  const GroupView({
    super.key,
    required this.byTag,
    required this.now,
    required this.cards,
  });

  /// Tags view when true, Folders view otherwise.
  final bool byTag;
  final DateTime now;
  final CardCallbacks cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(byTag ? homeTagsProvider : homeFoldersProvider);
    final view = ref.watch(homeViewProvider);
    final controller = ref.read(homeViewProvider.notifier);
    final picked = byTag ? view.tag : view.folder;
    final locked = !byTag && (ref.watch(hasLockedNotesProvider).value ?? false);
    return SliverMainAxisGroup(
      slivers: groups.when(
        loading: () => const [],
        error: (_, _) => const [
          SliverToBoxAdapter(child: EmptyState(message: AppCopy.loadError)),
        ],
        data: (names) => [
          if (names.isEmpty && !locked)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                message: byTag ? AppCopy.noTagsYet : AppCopy.noFoldersYet,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpace.screen,
                child: Wrap(
                  spacing: AppSpace.s,
                  runSpacing: AppSpace.s,
                  children: [
                    for (final name in names)
                      FilterPill(
                        label: byTag ? AppCopy.tagLabel(name) : name,
                        active: name == picked,
                        showArrow: false,
                        onTap: () => byTag
                            ? controller.pickTag(name)
                            : controller.pickFolder(name),
                      ),
                    if (locked)
                      FilterPill(
                        label: AppCopy.lockedFolder,
                        icon: Icons.lock_outline,
                        active: picked == LockedFolder.name,
                        showArrow: false,
                        onTap: () => unawaited(_pickLocked(context, ref)),
                      ),
                  ],
                ),
              ),
            ),
          if (picked != null &&
              (names.contains(picked) ||
                  (locked && picked == LockedFolder.name))) ...[
            const SliverToBoxAdapter(child: SizedBox(height: AppSpace.l)),
            if (picked == LockedFolder.name)
              ..._lockedNotes(ref)
            else
              _notes(ref, picked),
          ],
        ],
      ),
    );
  }

  /// Picking Locked asks for the phone's lock first (unless open).
  Future<void> _pickLocked(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(homeViewProvider.notifier);
    if (ref.read(homeViewProvider).folder == LockedFolder.name) {
      return controller.pickFolder(LockedFolder.name);
    }
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(lockedSessionProvider.notifier).open();
    if (result == UnlockResult.noScreenLock) {
      NoticeSnackBar.show(messenger, AppCopy.needScreenLock, long: true);
    }
    if (result == UnlockResult.unlocked) {
      controller.pickFolder(LockedFolder.name);
    }
  }

  /// The Locked folder's notes while open, with "Lock now"; the lock
  /// otherwise (it closed while the folder was picked).
  List<Widget> _lockedNotes(WidgetRef ref) {
    final session = ref.read(lockedSessionProvider.notifier);
    if (!ref.watch(lockedSessionProvider)) {
      return [
        SliverToBoxAdapter(
          child: LockedGate(
            message: AppCopy.lockedFolderHint,
            onUnlock: () => unawaited(session.open()),
          ),
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: AppSpace.screen,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: session.close,
              icon: const Icon(Icons.lock_outline),
              label: const Text(AppCopy.lockNow),
            ),
          ),
        ),
      ),
      _notes(ref, LockedFolder.name),
    ];
  }

  Widget _notes(WidgetRef ref, String picked) {
    final filters = byTag
        ? SearchFilters(tag: picked)
        : SearchFilters(folder: picked);
    final notes = ref.watch(groupNotesProvider(filters)).value ?? const [];
    return NoteCards(notes: notes, now: now, cards: cards);
  }
}
