import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// Text that fills the space it's given and fades out at the bottom
/// instead of cutting off mid-line.
class FadingText extends StatelessWidget {
  const FadingText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final solid = context.colors.text;
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [AppSize.previewFadeStart, 1],
        colors: [solid, solid.withValues(alpha: 0)],
      ).createShader(bounds),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxHeight: double.infinity,
          child: Text(text, style: style),
        ),
      ),
    );
  }
}
