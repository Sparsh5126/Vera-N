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
    this.suggested = false,
    this.conflict = false,
  });

  final String title;
  final String preview;
  final String dateLabel;
  final bool pinned;
  final VoidCallback onTap;

  /// Suggestions involving this note are waiting: a small dimmed dot.
  final bool suggested;

  /// Changed in two places: a small mark until the user picks a version.
  final bool conflict;

  /// Opens the card's options (Pin, Delete).
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: AppSpace.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(dateLabel, style: styles.small)),
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
