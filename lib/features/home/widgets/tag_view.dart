import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/search_filters.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/filter_pill.dart';
import '../state/home_view.dart';
import 'card_callbacks.dart';
import 'note_cards.dart';

/// Home's Tags view: a pill per tag; tapping one shows its notes below,
/// tapping it again clears the choice.
class TagView extends ConsumerWidget {
  const TagView({super.key, required this.now, required this.cards});

  final DateTime now;
  final CardCallbacks cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(homeTagsProvider);
    final picked = ref.watch(homeViewProvider).tag;
    final controller = ref.read(homeViewProvider.notifier);
    return SliverMainAxisGroup(
      slivers: tags.when(
        loading: () => const [],
        error: (_, _) => const [
          SliverToBoxAdapter(child: EmptyState(message: AppCopy.loadError)),
        ],
        data: (names) => [
          if (names.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(message: AppCopy.noTagsYet),
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
                        label: AppCopy.tagLabel(name),
                        active: name == picked,
                        showArrow: false,
                        onTap: () => controller.pickTag(name),
                      ),
                  ],
                ),
              ),
            ),
          if (picked != null && names.contains(picked)) ...[
            const SliverToBoxAdapter(child: SizedBox(height: AppSpace.l)),
            NoteCards(
              notes:
                  ref
                      .watch(groupNotesProvider(SearchFilters(tag: picked)))
                      .value ??
                  const [],
              now: now,
              cards: cards,
            ),
          ],
        ],
      ),
    );
  }
}
