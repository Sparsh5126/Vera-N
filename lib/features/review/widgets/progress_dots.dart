import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// Progress through a batch as small dots, never a number on screen
/// (UI spec §6). Screen readers hear the position.
class ProgressDots extends StatelessWidget {
  const ProgressDots({super.key, required this.done, required this.total});

  final int done;
  final int total;

  static const _dot = AppSpace.s;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: AppCopy.reviewProgress(done, total),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < total; i++)
              Container(
                width: _dot,
                height: _dot,
                margin: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= done ? colors.accent : null,
                  border: Border.all(color: colors.border),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
