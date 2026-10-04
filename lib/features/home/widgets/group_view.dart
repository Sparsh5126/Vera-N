import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/search_filters.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/filter_pill.dart';
import '../state/home_view.dart';
import 'notes_grid.dart';

/// Home's Folders or Tags view: a pill per folder or tag; tapping one
/// shows its notes below (a folder includes its subfolders), tapping it
/// again clears the choice.
class GroupView extends ConsumerWidget {
  const GroupView({
    super.key,
    required this.byTag,
    required this.now,
    required this.onOpen,
  });

  /// Tags view when true, Folders view otherwise.
  final bool byTag;
  final DateTime now;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(byTag ? homeTagsProvider : homeFoldersProvider);
    final view = ref.watch(homeViewProvider);
    final controller = ref.read(homeViewProvider.notifier);
    final picked = byTag ? view.tag : view.folder;
    return SliverMainAxisGroup(
      slivers: groups.when(
        loading: () => const [],
        error: (_, _) => const [
          SliverToBoxAdapter(child: EmptyState(message: AppCopy.loadError)),
        ],
        data: (names) => [
          if (names.isEmpty)
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
                  ],
                ),
              ),
            ),
          if (picked != null && names.contains(picked)) ...[
            const SliverToBoxAdapter(child: SizedBox(height: AppSpace.l)),
            _notes(ref, picked),
          ],
        ],
      ),
    );
  }

  Widget _notes(WidgetRef ref, String picked) {
    final filters = byTag
        ? SearchFilters(tag: picked)
        : SearchFilters(folder: picked);
    final notes = ref.watch(groupNotesProvider(filters)).value ?? const [];
    return NotesGrid(notes: notes, now: now, onOpen: onOpen);
  }
}
