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

  /// How often the recording time updates while recording a voice note.
  static const Duration clockTick = Duration(seconds: 1);

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

  /// The first-time nudge of a Review card (UI spec §6), once: it leans
  /// this share of its width right, settles, leans left, settles.
  static const double nudgeLean = 0.22;

  /// One lean or settle of the nudge.
  static const Duration nudgeStep = Duration(milliseconds: 450);

  /// The pause at the far point of each lean, so the ✓ or ✕ can be read.
  static const Duration nudgeHold = Duration(milliseconds: 250);

  /// How long a dragged note rests on a folder chip before that folder
  /// opens under it (UI spec §5), as in a desktop file manager.
  static const Duration springOpen = Duration(milliseconds: 700);

  /// Settling back to the middle eases in and out, like a hand letting go.
  static const Curve nudgeSettleCurve = Curves.easeInOut;
}
