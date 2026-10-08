import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// The one-time card showing the four Review gestures (UI spec §6).
class ReviewHint extends StatelessWidget {
  const ReviewHint({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  static const _gestures = [
    (Icons.arrow_forward, AppCopy.reviewHintRight),
    (Icons.arrow_back, AppCopy.reviewHintLeft),
    (Icons.arrow_upward, AppCopy.reviewHintUp),
    (Icons.arrow_downward, AppCopy.reviewHintDown),
  ];

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Card(
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppCopy.reviewHintTitle, style: styles.cardTitle),
            const SizedBox(height: AppSpace.s),
            for (final (icon, label) in _gestures)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                child: Row(
                  children: [
                    Icon(icon, size: AppSize.iconSmall),
                    const SizedBox(width: AppSpace.s),
                    Text(label, style: styles.body),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDismiss,
                child: const Text(AppCopy.gotIt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
