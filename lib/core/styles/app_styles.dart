/// The one styles file for Vera N (CLAUDE.md §4).
///
/// Every color, font, spacing, radius, size, opacity, duration and curve in
/// the app comes from here. Token groups live in `part` files so each stays
/// small, but this is the only import point.
library;

import 'package:flutter/material.dart';

part 'app_palette.dart';
part 'app_chip_look.dart';
part 'app_text_styles.dart';
part 'app_layout.dart';
part 'app_motion.dart';
part 'app_theme.dart';

/// Shorthand for reading the active theme's tokens from a widget.
extension AppStylesContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>()!;
  AppTextStyles get textStyles => Theme.of(this).extension<AppTextStyles>()!;
}
