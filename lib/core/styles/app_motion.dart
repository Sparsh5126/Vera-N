part of 'app_styles.dart';

/// Motion tokens. Short and purposeful; no decorative or looping motion.
///
/// When the system asks to reduce motion, use [reduced] (instant) instead
/// of [standard].
abstract final class AppMotion {
  /// Default transition.
  static const Duration standard = Duration(milliseconds: 200);
  static const Curve standardCurve = Curves.easeOut;

  /// Used when "reduce motion" is on.
  static const Duration reduced = Duration.zero;

  /// How long the note's "saved" tick stays before fading out.
  static const Duration savedTickHold = Duration(milliseconds: 1200);

  /// A short notice with nothing to tap (e.g. "Copied").
  static const Duration briefNotice = Duration(seconds: 2);

  /// Snackbars with Undo stay long enough to reach the button.
  static const Duration undoWindow = Duration(seconds: 5);

  /// Review card swipe: springy settle back or fly-out.
  static const SpringDescription cardSpring = SpringDescription(
    mass: 1,
    stiffness: 400,
    damping: 28,
  );

  /// Card tilt in radians at a full-width drag.
  static const double cardTiltMax = 0.14;
}
