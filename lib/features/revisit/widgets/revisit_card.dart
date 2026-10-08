import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/revisit_item.dart';
import '../../../core/styles/app_styles.dart';

/// One old note worth another look, shown on its own like a Review card:
/// when it last changed, its title and the start of its text, and which
/// recent note made it relevant. Tapping it opens the note.
class RevisitCard extends StatelessWidget {
  const RevisitCard({
    super.key,
    required this.item,
    required this.dateLabel,
    required this.onOpen,
  });

  final RevisitItem item;

  /// When the old note last changed, in words.
  final String dateLabel;
  final VoidCallback onOpen;

  static const _previewLines = 8;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: AppSpace.card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(dateLabel, style: styles.small),
              const SizedBox(height: AppSpace.xs),
              if (item.title.isNotEmpty)
                Text(
                  item.title,
                  style: styles.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (item.preview.isNotEmpty)
                Text(
                  item.preview,
                  style: styles.card,
                  maxLines: _previewLines,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppSpace.m),
              const Divider(height: 1),
              const SizedBox(height: AppSpace.m),
              Text(
                AppCopy.relatedToRecent(item.recentTitle),
                style: styles.small,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
