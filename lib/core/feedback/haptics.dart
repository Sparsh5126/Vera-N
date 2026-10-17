import 'package:flutter/services.dart';

/// Named haptic moments (CLAUDE.md §7). Widgets call these, never the
/// platform directly. Rejecting has no haptic, by design. Android skips
/// them when the user turned touch feedback off.
///
/// [select]: a note card is selected or unselected on Home (felt when the
/// hold registers, so a drag that follows needs no second one), or a dot
/// is picked in the Graph. The lightest tick there is, the one Android
/// itself uses for "selection changed".
enum HapticEvent { accept, notSure, undo, select }

abstract final class Haptics {
  static Future<void> play(HapticEvent event) => switch (event) {
    HapticEvent.accept => HapticFeedback.lightImpact(),
    HapticEvent.notSure ||
    HapticEvent.undo ||
    HapticEvent.select => HapticFeedback.selectionClick(),
  };
}
