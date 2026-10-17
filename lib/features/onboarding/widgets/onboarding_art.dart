import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import 'onboarding_art_kind.dart';
import 'onboarding_art_painter.dart';

/// A page's line illustration, above its words (UI spec §4). Drawn, not a
/// picture file, so it is sharp at any size and follows light and dark.
/// It says nothing the text doesn't, so screen readers skip it. On a short
/// screen it shrinks to leave the words in view.
class OnboardingArt extends StatelessWidget {
  const OnboardingArt(this.kind, {super.key});

  final OnboardingArtKind kind;

  /// The most of the screen's height it may take.
  static const _maxShare = 0.22;

  @override
  Widget build(BuildContext context) {
    final height = math.min(
      AppSize.onboardingArtHeight,
      MediaQuery.sizeOf(context).height * _maxShare,
    );
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: OnboardingArtPainter(kind: kind, colors: context.colors),
        ),
      ),
    );
  }
}
