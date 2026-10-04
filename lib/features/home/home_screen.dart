import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/navigation/routes.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/greeting.dart';
import '../../shared/widgets/pill_button.dart';
import '../../shared/widgets/pill_tabs.dart';
import 'state/home_view.dart';
import 'widgets/bottom_fade.dart';
import 'widgets/card_callbacks.dart';
import 'widgets/group_view.dart';
import 'widgets/home_header.dart';
import 'widgets/home_note_menu.dart';
import 'widgets/recent_view.dart';

/// Home: greeting, the Recent | Folders | Tags switch, then the notes of
/// that view. "New note" floats in thumb reach at the bottom right.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(homeViewProvider.select((v) => v.view));
    final now = DateTime.now();
    final menu = HomeNoteMenu(ref.read(notesRepositoryProvider));
    final cards = CardCallbacks(
      open: (noteRef) => context.push(Routes.note(noteRef)),
      menu: (note) => unawaited(menu.show(context, note)),
    );

    return Scaffold(
      // Sits just above the floating nav bar, in thumb reach.
      floatingActionButton: Padding(
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
                  child: HomeHeader(greeting: Greeting.of(now)),
                ),
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
                  HomeView.folders => GroupView(
                    byTag: false,
                    now: now,
                    cards: cards,
                  ),
                  HomeView.tags => GroupView(
                    byTag: true,
                    now: now,
                    cards: cards,
                  ),
                },
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSize.floatingClearance),
                ),
              ],
            ),
            const Positioned(left: 0, right: 0, bottom: 0, child: BottomFade()),
          ],
        ),
      ),
    );
  }
}
