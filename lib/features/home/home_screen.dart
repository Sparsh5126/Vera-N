import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/navigation/routes.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/greeting.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/pill_button.dart';
import 'state/home_providers.dart';
import 'widgets/bottom_fade.dart';
import 'widgets/home_header.dart';
import 'widgets/notes_grid.dart';
import 'widgets/pinned_row.dart';

/// Home: greeting, pinned notes, then all notes. "New note" floats in
/// thumb reach at the bottom right.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(homeNotesProvider);
    final now = DateTime.now();
    void open(int noteRef) => context.push(Routes.note(noteRef));

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
                ...notes.when(
                  // Local data arrives at once: no spinner.
                  loading: () => const [],
                  error: (_, _) => const [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(message: AppCopy.loadError),
                    ),
                  ],
                  data: (home) => [
                    if (home.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(message: AppCopy.emptyHome),
                      ),
                    if (home.pinned.isNotEmpty)
                      SliverToBoxAdapter(
                        child: PinnedRow(
                          notes: home.pinned,
                          now: now,
                          onOpen: open,
                        ),
                      ),
                    NotesGrid(notes: home.others, now: now, onOpen: open),
                  ],
                ),
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
