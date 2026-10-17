import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/folder_summary.dart';
import '../../../core/styles/app_styles.dart';

/// Above an opened folder: back to the cards, then the folder's name with
/// the folders it sits in, and an optional action (Lock now).
class FolderHeader extends StatelessWidget {
  const FolderHeader({
    super.key,
    required this.path,
    required this.onBack,
    this.trailing,
  });

  final String path;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final folder = FolderSummary(path, 0);
    final parent = folder.parent;
    return Padding(
      padding: AppSpace.screen,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            tooltip: HomeCopy.allFolders,
          ),
          const SizedBox(width: AppSpace.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (parent != null)
                  Text(HomeCopy.inFolder(parent), style: styles.small),
                Text(
                  folder.name,
                  style: styles.noteTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
