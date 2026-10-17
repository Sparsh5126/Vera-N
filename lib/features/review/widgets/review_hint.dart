import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// The first time Review opens, under the card while it nudges itself to
/// show the swipe (UI spec §6): the four gestures in one quiet strip, and
/// "Got it". The first decision also puts it away.
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
    final quiet = context.colors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppCopy.reviewHintTitle, style: styles.label),
        const SizedBox(height: AppSpace.xs),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpace.m,
          runSpacing: AppSpace.xs,
          children: [
            for (final (icon, label) in _gestures)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppSize.iconSmall, color: quiet),
                  const SizedBox(width: AppSpace.xs),
                  Text(label, style: styles.small),
                ],
              ),
          ],
        ),
        TextButton(onPressed: onDismiss, child: const Text(AppCopy.gotIt)),
      ],
    );
  }
}
