import 'package:flutter/services.dart';

/// Named haptic moments (CLAUDE.md §7). Widgets call these, never the
/// platform directly. Rejecting has no haptic, by design. Android skips
/// them when the user turned touch feedback off.
enum HapticEvent { accept, notSure, undo }

abstract final class Haptics {
  static Future<void> play(HapticEvent event) => switch (event) {
    HapticEvent.accept => HapticFeedback.lightImpact(),
    HapticEvent.notSure || HapticEvent.undo => HapticFeedback.selectionClick(),
  };
}
