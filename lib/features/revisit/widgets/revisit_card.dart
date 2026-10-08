import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/revisit_item.dart';
import '../../../core/styles/app_styles.dart';

/// One old note worth another look: its title, the start of its text,
/// which recent note made it relevant, and "Not now". Tapping opens it.
class RevisitCard extends StatelessWidget {
  const RevisitCard({
    super.key,
    required this.item,
    required this.dateLabel,
    required this.onOpen,
    required this.onNotNow,
  });

  final RevisitItem item;

  /// When the old note last changed, in words.
  final String dateLabel;
  final VoidCallback onOpen;
  final VoidCallback onNotNow;

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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppSpace.s),
              Text(
                AppCopy.relatedToRecent(item.recentTitle),
                style: styles.small,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onNotNow,
                  child: const Text(AppCopy.notNow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
