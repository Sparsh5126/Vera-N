import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/pill_button.dart';

/// "Not now" and "Open", side by side in thumb reach at the bottom.
class RevisitButtons extends StatelessWidget {
  const RevisitButtons({
    super.key,
    required this.onNotNow,
    required this.onOpen,
  });

  final VoidCallback onNotNow;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpace.m,
      children: [
        Expanded(
          child: SizedBox(
            height: AppSize.minTapTarget,
            child: OutlinedButton(
              onPressed: onNotNow,
              child: const Text(AppCopy.notNow),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: AppSize.minTapTarget,
            child: PillButton(label: AppCopy.open, onPressed: onOpen),
          ),
        ),
      ],
    );
  }
}
