import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/trashed_note.dart';
import '../../../core/styles/app_styles.dart';

/// A note in the trash: title, the start of its text, when it was deleted,
/// and Restore / Delete forever as plain buttons.
class TrashCard extends StatelessWidget {
  const TrashCard({
    super.key,
    required this.note,
    required this.dateLabel,
    required this.onRestore,
    required this.onDelete,
  });

  final TrashedNote note;

  /// When it was deleted, in words ("Today", "Oct 4").
  final String dateLabel;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return Material(
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorder,
        side: BorderSide(color: colors.border, width: AppBorder.width),
      ),
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppCopy.deletedOn(dateLabel), style: styles.small),
            const SizedBox(height: AppSpace.xs),
            // A locked note shows neither its title nor its text here.
            if (note.locked)
              Text(AppCopy.lockedTrashNote, style: styles.cardTitle)
            else if (note.title.isNotEmpty)
              Text(
                note.title,
                style: styles.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (note.preview.isNotEmpty)
              Text(
                note.preview,
                style: styles.card,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: AppSpace.s),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: AppSpace.s,
              children: [
                TextButton(
                  onPressed: onDelete,
                  child: Text(
                    AppCopy.deleteForever,
                    style: styles.label.copyWith(color: colors.reject),
                  ),
                ),
                TextButton(
                  onPressed: onRestore,
                  child: const Text(AppCopy.restore),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
