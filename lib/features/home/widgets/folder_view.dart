import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/folder_summary.dart';
import '../../../core/models/locked_folder.dart';
import '../../../core/models/search_filters.dart';
import '../../../core/platform/device_lock.dart';
import '../../../core/security/locked_session.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/locked_gate.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import '../state/home_selection.dart';
import '../state/home_view.dart';
import 'card_callbacks.dart';
import 'folder_cards.dart';
import 'folder_header.dart';
import 'note_cards.dart';

/// Home's Folders view (UI spec §5): a card per folder; opening one shows
/// its notes, subfolders included, under a back arrow. The phone's back
/// gesture also returns to the cards. Locked opens with the phone's lock.
class FolderView extends ConsumerWidget {
  const FolderView({super.key, required this.now, required this.cards});

  final DateTime now;
  final CardCallbacks cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(homeFolderSummariesProvider);
    final locked = ref.watch(hasLockedNotesProvider).value ?? false;
    final picked = ref.watch(homeViewProvider).folder;
    final list = folders.value ?? const <FolderSummary>[];
    final open =
        picked != null &&
        (list.any((f) => f.path == picked) ||
            (locked && picked == LockedFolder.name));
    final controller = ref.read(homeViewProvider.notifier);
    return PopScope(
      canPop: !open,
      onPopInvokedWithResult: (didPop, _) {
        // While notes are selected, back stops selecting first (Home).
        if (!didPop && ref.read(homeSelectionProvider).isEmpty) {
          controller.closeFolder();
        }
      },
      child: SliverMainAxisGroup(
        slivers: folders.when(
          loading: () => const [],
          error: (_, _) => const [
            SliverToBoxAdapter(child: EmptyState(message: AppCopy.loadError)),
          ],
          data: (list) => open
              ? _opened(context, ref, picked)
              : _cards(context, ref, list, locked),
        ),
      ),
    );
  }

  List<Widget> _cards(
    BuildContext context,
    WidgetRef ref,
    List<FolderSummary> list,
    bool locked,
  ) {
    if (list.isEmpty && !locked) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(message: AppCopy.noFoldersYet),
        ),
      ];
    }
    return [
      FolderCards(
        folders: list,
        locked: locked,
        onOpen: ref.read(homeViewProvider.notifier).pickFolder,
        onOpenLocked: () => unawaited(_openLocked(context, ref)),
      ),
    ];
  }

  List<Widget> _opened(BuildContext context, WidgetRef ref, String path) {
    final isLocked = path == LockedFolder.name;
    final session = ref.read(lockedSessionProvider.notifier);
    final unlocked = !isLocked || ref.watch(lockedSessionProvider);
    return [
      SliverToBoxAdapter(
        child: FolderHeader(
          path: path,
          onBack: ref.read(homeViewProvider.notifier).closeFolder,
          trailing: isLocked && unlocked
              ? TextButton.icon(
                  onPressed: session.close,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text(AppCopy.lockNow),
                )
              : null,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpace.s)),
      if (unlocked)
        NoteCards(
          notes:
              ref
                  .watch(groupNotesProvider(SearchFilters(folder: path)))
                  .value ??
              const [],
          now: now,
          cards: cards,
        )
      else
        SliverToBoxAdapter(
          child: LockedGate(
            message: AppCopy.lockedFolderHint,
            onUnlock: () => unawaited(session.open()),
          ),
        ),
    ];
  }

  /// Opening Locked asks for the phone's lock first.
  Future<void> _openLocked(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(lockedSessionProvider.notifier).open();
    if (result == UnlockResult.noScreenLock) {
      NoticeSnackBar.show(messenger, AppCopy.needScreenLock, long: true);
    }
    if (result == UnlockResult.unlocked) {
      ref.read(homeViewProvider.notifier).pickFolder(LockedFolder.name);
    }
  }
}
