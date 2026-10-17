import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/archive_folder.dart';
import '../../../core/models/folder_summary.dart';
import '../../../core/styles/app_styles.dart';
import '../state/dragged_notes.dart';
import 'folder_drop_chip.dart';

/// While notes are dragged on Home, above the nav bar (UI spec §5): a
/// chip for every folder (resting on one opens it), then No folder,
/// Locked, Archive and New folder. Dropping acts at once, with Undo.
class FolderDropTray extends StatelessWidget {
  const FolderDropTray({
    super.key,
    required this.folders,
    required this.onMove,
    required this.onOpen,
    required this.onLock,
    required this.onArchive,
    required this.onNewFolder,
  });

  final List<FolderSummary> folders;
  final void Function(Set<int> refs, String folder) onMove;
  final ValueChanged<String> onOpen;
  final ValueChanged<Set<int>> onLock;
  final ValueChanged<Set<int>> onArchive;
  final ValueChanged<Set<int>> onNewFolder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    void Function(DraggedNotes) to(ValueChanged<Set<int>> act) =>
        (notes) => act(notes.refs);
    return Container(
      padding: AppSpace.card,
      decoration: ShapeDecoration(
        color: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: colors.border, width: AppBorder.width),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(HomeCopy.dropOnFolder, style: context.textStyles.small),
          const SizedBox(height: AppSpace.s),
          Wrap(
            spacing: AppSpace.s,
            runSpacing: AppSpace.s,
            children: [
              // The Archive chip below stands for every archived folder.
              for (final f in folders)
                if (!ArchiveFolder.contains(f.path))
                  FolderDropChip(
                    label: f.path,
                    icon: Icons.folder_outlined,
                    onDrop: (notes) => onMove(notes.refs, f.path),
                    onSpringOpen: () => onOpen(f.path),
                  ),
              FolderDropChip(
                label: AppCopy.noFolder,
                icon: Icons.notes,
                onDrop: (notes) => onMove(notes.refs, ''),
              ),
              FolderDropChip(
                label: AppCopy.lockedFolder,
                icon: Icons.lock_outline,
                onDrop: to(onLock),
              ),
              FolderDropChip(
                label: HomeCopy.actionArchive,
                icon: Icons.archive_outlined,
                onDrop: to(onArchive),
              ),
              FolderDropChip(
                label: AppCopy.newFolder,
                icon: Icons.create_new_folder_outlined,
                onDrop: to(onNewFolder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
