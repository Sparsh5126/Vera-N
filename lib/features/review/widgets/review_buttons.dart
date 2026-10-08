import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/decision_buttons.dart';

/// ✕, Not sure and ✓, with Undo below: always visible, each doing exactly
/// what its swipe does (UI spec §6). In thumb reach at the bottom.
class ReviewButtons extends StatelessWidget {
  const ReviewButtons({
    super.key,
    required this.onReject,
    required this.onNotSure,
    required this.onAccept,
    required this.onUndo,
  });

  final VoidCallback onReject;
  final VoidCallback onNotSure;
  final VoidCallback onAccept;

  /// Null when there is nothing to undo.
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecisionButtons(
          onReject: onReject,
          onNotSure: onNotSure,
          onAccept: onAccept,
        ),
        const SizedBox(height: AppSpace.s),
        TextButton.icon(
          onPressed: onUndo,
          icon: const Icon(Icons.undo),
          label: const Text(AppCopy.undo),
        ),
      ],
    );
  }
}
