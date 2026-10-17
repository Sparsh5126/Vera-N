import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/styles/app_styles.dart';
import 'fading_text.dart';

/// A note on Home: optional title, date, and a preview that fades out.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.title,
    required this.preview,
    required this.dateLabel,
    required this.pinned,
    required this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSemanticLongPress,
    this.suggested = false,
    this.conflict = false,
    this.selected = false,
  });

  /// Right-click with a mouse; [onLongPress] when not given.
  final VoidCallback? onSecondaryTap;

  /// A screen reader's long press, when the hold gesture itself belongs to
  /// something around the card (Home's drag). It joins the card's own
  /// node, so the card still offers it.
  final VoidCallback? onSemanticLongPress;

  /// Picked on Home to act on with others: an ink outline and a check.
  final bool selected;

  final String title;
  final String preview;
  final String dateLabel;
  final bool pinned;
  final VoidCallback onTap;

  /// Suggestions involving this note are waiting: a small dimmed dot.
  final bool suggested;

  /// Changed in two places: a small mark until the user picks a version.
  final bool conflict;

  /// Holding the card (or right-clicking it): on Home, selects it.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return Card(
      clipBehavior: Clip.antiAlias,
      // Selected: a faint ink wash under the outline, as under a picked
      // Graph dot.
      color: selected
          ? Color.alphaBlend(
              colors.text.withValues(alpha: AppOpacity.selectedWash),
              colors.card,
            )
          : null,
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: BorderSide(color: colors.text, width: AppBorder.selected),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        // Right-click with a mouse does what a long press does.
        onSecondaryTap: onSecondaryTap ?? onLongPress,
        child: Semantics(
          onLongPress: onSemanticLongPress,
          child: Padding(
            padding: AppSpace.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(dateLabel, style: styles.small)),
                    if (selected)
                      Icon(
                        Icons.check_circle,
                        size: AppSize.iconSmall,
                        color: colors.text,
                        semanticLabel: HomeCopy.selectedNote,
                      ),
                    if (suggested) _dot(context),
                    if (conflict)
                      Icon(
                        Icons.sync_problem,
                        size: AppSize.iconSmall,
                        color: context.colors.textSecondary,
                        semanticLabel: AppCopy.changedInTwoPlaces,
                      ),
                    if (pinned)
                      Icon(
                        Icons.push_pin_outlined,
                        size: AppSize.iconSmall,
                        color: context.colors.textSecondary,
                        semanticLabel: AppCopy.pinned,
                      ),
                  ],
                ),
                if (title.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    title,
                    style: styles.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpace.xs),
                Expanded(child: FadingText(preview, style: styles.card)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dimmed like every AI suggestion; read out, never counted.
  Widget _dot(BuildContext context) => Semantics(
    label: AppCopy.hasSuggestions,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
      child: Container(
        width: AppSpace.s,
        height: AppSpace.s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.seal,
        ),
      ),
    ),
  );
}
