import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/feedback/haptics.dart';
import '../../core/navigation/open_note.dart';
import '../../core/navigation/routes.dart';
import '../../core/platform/device_lock.dart';
import '../../core/settings/app_prefs_controller.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/greeting.dart';
import '../../shared/widgets/pill_button.dart';
import '../../shared/widgets/pill_tabs.dart';
import 'state/home_view.dart';
import 'widgets/bottom_fade.dart';
import 'widgets/card_callbacks.dart';
import 'widgets/connections_card.dart';
import 'widgets/folder_view.dart';
import 'widgets/tag_view.dart';
import 'widgets/home_header.dart';
import 'state/home_drag.dart';
import 'state/home_selection.dart';
import 'widgets/home_drop_layer.dart';
import 'widgets/home_selection_actions.dart';
import 'widgets/selection_action_bar.dart';
import 'widgets/selection_top_bar.dart';
import 'widgets/recent_view.dart';

/// Home: greeting, the Recent | Folders | Tags switch, then the notes of
/// that view. "New note" floats in thumb reach at the bottom right.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(homeViewProvider.select((v) => v.view));
    final now = DateTime.now();
    final selected = ref.watch(homeSelectionProvider);
    final selection = ref.read(homeSelectionProvider.notifier);
    final selecting = selected.isNotEmpty;
    // A wide window opens notes beside the list, and "New note" is in the
    // sidebar (docs/LAPTOP_PLAN.md, L1).
    final wide = AppBreakpoints.wide(context);
    final cards = CardCallbacks(
      tap: (note) {
        if (selecting) {
          unawaited(Haptics.play(HapticEvent.select));
          return selection.toggle(note);
        }
        if (wide) return ref.read(openNoteProvider.notifier).open(note.ref);
        unawaited(context.push(Routes.note(note.ref)));
      },
      hold: selection.toggle,
      selected: selected.keys.toSet(),
    );

    // The phone's back gesture stops selecting before anything else.
    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selecting) selection.clear();
      },
      child: _scaffold(context, ref, view, now, cards, wide: wide),
    );
  }

  Widget _scaffold(
    BuildContext context,
    WidgetRef ref,
    HomeView view,
    DateTime now,
    CardCallbacks cards, {
    required bool wide,
  }) {
    final selected = ref.watch(homeSelectionProvider);
    final dragging = ref.watch(homeDragProvider);
    final actions = _actions(ref);
    return Scaffold(
      // Sits just above the floating nav bar, in thumb reach. While notes
      // are selected, their actions take its place; while they are
      // dragged, the folder tray does.
      floatingActionButtonLocation: selected.isEmpty
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
      floatingActionButton: dragging
          ? null
          : selected.isNotEmpty
          ? Padding(
              padding: EdgeInsets.only(
                bottom: wide ? 0 : AppSize.navBarHeight + AppSpace.s,
              ),
              child: _actionBar(context, actions, selected),
            )
          : wide
          ? null
          : Padding(
              padding: const EdgeInsets.only(
                bottom: AppSize.navBarHeight + AppSpace.s,
              ),
              child: PillButton(
                label: AppCopy.newNote,
                icon: Icons.add,
                onPressed: () => context.push(Routes.newNote),
              ),
            ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    greeting: Greeting.of(
                      now,
                      name: ref.watch(appPrefsProvider.select((p) => p.name)),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: ConnectionsCard()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.m),
                    child: PillTabs(
                      labels: const [
                        AppCopy.viewRecent,
                        AppCopy.viewFolders,
                        AppCopy.viewTags,
                      ],
                      selected: view.index,
                      onSelected: (i) => ref
                          .read(homeViewProvider.notifier)
                          .show(HomeView.values[i]),
                    ),
                  ),
                ),
                switch (view) {
                  HomeView.recent => RecentView(now: now, cards: cards),
                  HomeView.folders => FolderView(now: now, cards: cards),
                  HomeView.tags => TagView(now: now, cards: cards),
                },
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSize.floatingClearance),
                ),
              ],
            ),
            const Positioned(left: 0, right: 0, bottom: 0, child: BottomFade()),
            if (selected.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SelectionTopBar(
                  count: selected.length,
                  onClose: ref.read(homeSelectionProvider.notifier).clear,
                ),
              ),
            if (dragging)
              Positioned.fill(child: HomeDropLayer(actions: actions)),
          ],
        ),
      ),
    );
  }

  /// What the selection bar and the folder tray do to notes.
  HomeSelectionActions _actions(WidgetRef ref) => HomeSelectionActions(
    batch: ref.read(noteBatchProvider),
    library: ref.read(searchRepositoryProvider),
    deviceLock: ref.read(deviceLockProvider),
    done: ref.read(homeSelectionProvider.notifier).clear,
  );

  Widget _actionBar(
    BuildContext context,
    HomeSelectionActions actions,
    Map<int, bool> selected,
  ) {
    final refs = selected.keys.toSet();
    final allPinned = selected.values.every((pinned) => pinned);
    final messenger = ScaffoldMessenger.of(context);
    return SelectionActionBar(
      allPinned: allPinned,
      onFolder: () => unawaited(actions.moveToFolder(context, refs)),
      onLock: () => unawaited(actions.lock(messenger, refs)),
      onArchive: () => unawaited(actions.archive(messenger, refs)),
      onPin: () => unawaited(actions.pin(refs, pinned: !allPinned)),
      onDelete: () => unawaited(actions.delete(messenger, refs)),
    );
  }
}
