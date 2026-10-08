import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';

/// The rounded square a photo or drawing is shown in inside a note:
/// [AppSize.embedSize] on a side (smaller on a narrow screen), on a plate
/// with a hairline, so every picture takes the same calm space.
class EmbedSquare extends StatelessWidget {
  const EmbedSquare({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: AppSize.embedSize,
        maxHeight: AppSize.embedSize,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardBorder,
            border: Border.all(color: colors.border),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.cardBorder,
            child: ColoredBox(color: colors.card, child: child),
          ),
        ),
      ),
    );
  }
}
