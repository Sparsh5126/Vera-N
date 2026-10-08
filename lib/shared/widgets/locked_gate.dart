import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/styles/app_styles.dart';
import 'pill_button.dart';

/// Shown in place of locked notes until the phone's lock opens them: a
/// lock, one line saying why, and Unlock.
class LockedGate extends StatelessWidget {
  const LockedGate({super.key, required this.message, required this.onUnlock});

  final String message;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: AppSpace.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: AppSize.minTapTarget,
              color: colors.textSecondary,
              semanticLabel: AppCopy.lockedFolder,
            ),
            const SizedBox(height: AppSpace.m),
            Text(
              message,
              style: context.textStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.l),
            PillButton(
              label: AppCopy.unlock,
              icon: Icons.lock_open,
              onPressed: onUnlock,
            ),
          ],
        ),
      ),
    );
  }
}
