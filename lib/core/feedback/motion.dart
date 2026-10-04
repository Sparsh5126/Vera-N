import 'package:flutter/widgets.dart';

import '../styles/app_styles.dart';

/// Motion that respects the system "reduce motion" setting (CLAUDE.md §7).
abstract final class Motion {
  /// The standard duration, or none when the user asked for less motion.
  static Duration of(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? AppMotion.reduced
      : AppMotion.standard;
}
