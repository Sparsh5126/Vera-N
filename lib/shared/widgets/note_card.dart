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
  });

  final String title;
  final String preview;
  final String dateLabel;
  final bool pinned;
  final VoidCallback onTap;

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
}
