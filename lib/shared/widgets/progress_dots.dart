import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// Progress as small dots, never a number on screen (Review batches,
/// onboarding pages). Screen readers hear [label], e.g. the position.
class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.done,
    required this.total,
    required this.label,
  });

  final int done;
  final int total;
  final String label;

  static const _dot = AppSpace.s;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: label,
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
