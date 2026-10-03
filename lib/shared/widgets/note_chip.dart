import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';
import 'dashed_pill_border.dart';

/// A tag or link chip on a note. Solid means confirmed (made or approved
/// by the user); dimmed means an AI suggestion: no fill, dashed outline.
class NoteChip extends StatelessWidget {
  const NoteChip({
    super.key,
    required this.label,
    required this.onTap,
    this.dimmed = false,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback onTap;
  final bool dimmed;
  final IconData? icon;

  /// Read by screen readers instead of [label] (e.g. "Suggested tag …").
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final look = dimmed ? context.colors.dimmedChip : context.colors.solidChip;
    final icon = this.icon;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSize.minTapTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSize.iconSmall, color: look.label),
              const SizedBox(width: AppSpace.xs),
            ],
            Text(
              label,
              style: context.textStyles.label.copyWith(color: look.label),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Material(
        color: look.fill,
        shape: dimmed
            ? AppRadius.pill
            : StadiumBorder(side: BorderSide(color: look.outline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: dimmed
              ? CustomPaint(
                  foregroundPainter: DashedPillBorder(color: look.outline),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
