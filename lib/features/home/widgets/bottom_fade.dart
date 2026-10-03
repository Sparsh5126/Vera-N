import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';

/// Fades scrolling cards into the background behind the floating button.
class BottomFade extends StatelessWidget {
  const BottomFade({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = context.colors.background;
    return IgnorePointer(
      child: Container(
        height: AppSize.bottomFade,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bg.withValues(alpha: 0), bg],
          ),
        ),
      ),
    );
  }
}
