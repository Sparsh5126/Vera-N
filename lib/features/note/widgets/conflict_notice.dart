import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// Shown above a note changed both here and outside the app (product spec
/// §14): both versions are kept until the user picks one. Plain buttons,
/// no question asked first; every choice offers Undo.
class ConflictNotice extends StatelessWidget {
  const ConflictNotice({
    super.key,
    required this.onCompare,
    required this.onKeepThis,
    required this.onKeepOther,
    required this.onKeepBoth,
  });

  final VoidCallback onCompare;
  final VoidCallback onKeepThis;
  final VoidCallback onKeepOther;
  final VoidCallback onKeepBoth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: AppSpace.screen,
      child: Material(
        color: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: BorderSide(color: colors.border, width: AppBorder.width),
        ),
        child: Padding(
          padding: AppSpace.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sync_problem, color: colors.textSecondary),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: Text(
                      AppCopy.conflictNotice,
                      style: context.textStyles.body,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s),
              Wrap(
                spacing: AppSpace.s,
                children: [
                  TextButton(
                    onPressed: onCompare,
                    child: const Text(AppCopy.compareVersions),
                  ),
                  TextButton(
                    onPressed: onKeepThis,
                    child: const Text(AppCopy.keepThisVersion),
                  ),
                  TextButton(
                    onPressed: onKeepOther,
                    child: const Text(AppCopy.keepOtherVersion),
                  ),
                  TextButton(
                    onPressed: onKeepBoth,
                    child: const Text(AppCopy.keepBothVersions),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
