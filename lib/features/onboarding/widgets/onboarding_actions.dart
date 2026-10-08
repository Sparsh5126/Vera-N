import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/pill_button.dart';

/// The buttons under an onboarding page, in thumb reach: the main action
/// as a pill and, when there is one, a quiet second choice below it
/// ("Not now", "Skip").
class OnboardingActions extends StatelessWidget {
  const OnboardingActions({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondLabel,
    this.onSecond,
  });

  final String label;

  /// Null disables the main button (e.g. no name typed yet).
  final VoidCallback? onPressed;
  final String? secondLabel;
  final VoidCallback? onSecond;

  @override
  Widget build(BuildContext context) {
    final second = secondLabel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.l,
        AppSpace.m,
        AppSpace.l,
        AppSpace.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PillButton(label: label, onPressed: onPressed),
          if (second != null) ...[
            const SizedBox(height: AppSpace.s),
            TextButton(onPressed: onSecond, child: Text(second)),
          ],
        ],
      ),
    );
  }
}
