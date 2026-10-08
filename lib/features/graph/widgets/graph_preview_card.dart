import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/graph_data.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/pill_button.dart';

/// The card at the bottom after tapping a dot: title, the start of the
/// note, Focus and Open (UI spec §10).
class GraphPreviewCard extends StatelessWidget {
  const GraphPreviewCard({
    super.key,
    required this.node,
    required this.onOpen,
    required this.onFocus,
    required this.onClose,
  });

  final GraphNode node;
  final VoidCallback onOpen;

  /// Shows only this note and its neighbours.
  final VoidCallback onFocus;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorder,
        side: BorderSide(color: context.colors.border, width: AppBorder.width),
      ),
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    node.title,
                    style: styles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  tooltip: AppCopy.close,
                ),
              ],
            ),
            if (node.preview.isNotEmpty)
              Text(
                node.preview,
                style: styles.card,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: AppSpace.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: AppSpace.s,
              children: [
                TextButton(
                  onPressed: onFocus,
                  child: const Text(AppCopy.focus),
                ),
                PillButton(label: AppCopy.open, onPressed: onOpen),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
