import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/folder_summary.dart';
import '../../../core/styles/app_styles.dart';
import '../state/dragged_notes.dart';

/// Over an opened folder while notes are dragged (UI spec §5): dropping
/// anywhere on its notes moves them into it. A banner at the top says so,
/// in ink while notes hover over it.
class OpenedFolderDrop extends StatelessWidget {
  const OpenedFolderDrop({
    super.key,
    required this.folder,
    required this.onDrop,
  });

  final String folder;
  final ValueChanged<Set<int>> onDrop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DragTarget<DraggedNotes>(
      onAcceptWithDetails: (details) => onDrop(details.data.refs),
      builder: (context, candidates, _) {
        final hover = candidates.isNotEmpty;
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: AppSpace.s),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.m,
              vertical: AppSpace.s,
            ),
            decoration: ShapeDecoration(
              color: hover ? colors.text : colors.card,
              shape: StadiumBorder(
                side: BorderSide(color: colors.border, width: AppBorder.width),
              ),
            ),
            child: Text(
              HomeCopy.dropInto(FolderSummary(folder, 0).name),
              style: context.textStyles.label.copyWith(
                color: hover ? colors.background : colors.text,
              ),
            ),
          ),
        );
      },
    );
  }
}
