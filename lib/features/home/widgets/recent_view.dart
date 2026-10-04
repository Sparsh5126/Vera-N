import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../shared/widgets/empty_state.dart';
import '../state/home_providers.dart';
import 'card_callbacks.dart';
import 'notes_grid.dart';
import 'pinned_row.dart';

/// Home's Recent view: pinned notes first, then every other note, newest
/// first. "Write your first thought." when there are none.
class RecentView extends ConsumerWidget {
  const RecentView({super.key, required this.now, required this.cards});

  final DateTime now;
  final CardCallbacks cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(homeNotesProvider);
    return SliverMainAxisGroup(
      slivers: notes.when(
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
              child: PinnedRow(notes: home.pinned, now: now, cards: cards),
            ),
          NotesGrid(notes: home.others, now: now, cards: cards),
        ],
      ),
    );
  }
}
