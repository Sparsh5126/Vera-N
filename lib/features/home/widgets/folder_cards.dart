import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/app_prefs.dart';
import '../../../core/models/folder_summary.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/folder_card.dart';
import 'note_cards.dart';

/// Every folder as a card (subfolders too, each its own card), as a grid
/// or a list like the note cards. Locked, when it has notes, comes last
/// and shows no count: how many notes are locked stays private.
class FolderCards extends ConsumerWidget {
  const FolderCards({
    super.key,
    required this.folders,
    required this.locked,
    required this.onOpen,
    required this.onOpenLocked,
  });

  final List<FolderSummary> folders;
  final bool locked;
  final ValueChanged<String> onOpen;
  final VoidCallback onOpenLocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(appPrefsProvider.select((p) => p.layout));
    final height = MediaQuery.textScalerOf(context)
        .scale(AppSize.folderCardHeight);
    final count = folders.length + (locked ? 1 : 0);
    Widget card(BuildContext context, int i) {
      if (i == folders.length) {
        return FolderCard(
          name: AppCopy.lockedFolder,
          icon: Icons.lock_outline,
          semanticLabel: AppCopy.lockedFolder,
          onTap: onOpenLocked,
        );
      }
      final f = folders[i];
      final parent = f.parent;
      return FolderCard(
        name: f.name,
        parent: parent == null ? null : HomeCopy.inFolder(parent),
        caption: HomeCopy.noteCount(f.notes),
        icon: Icons.folder_outlined,
        semanticLabel: HomeCopy.folderCard(f.name, parent, f.notes),
        onTap: () => onOpen(f.path),
      );
    }

    return SliverPadding(
      padding: AppSpace.screen,
      sliver: switch (layout) {
        NotesLayout.grid => SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: NoteCards.columns,
            mainAxisSpacing: AppSpace.s,
            crossAxisSpacing: AppSpace.s,
            mainAxisExtent: height,
          ),
          itemCount: count,
          itemBuilder: card,
        ),
        NotesLayout.list => SliverList.separated(
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s),
          itemBuilder: (context, i) =>
              SizedBox(height: height, child: card(context, i)),
        ),
      },
    );
  }
}
