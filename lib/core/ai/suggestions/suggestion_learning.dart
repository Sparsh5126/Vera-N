import '../../models/kind_learning.dart';
import '../ai_settings.dart';

/// Simple learning from decisions (product spec §7–8): no training, just
/// counts. When most recent suggestions of a kind are rejected, its bar
/// rises a step; when most are accepted, it eases back a step, never below
/// a floor. After a step the count starts over, so the bar moves slowly.
abstract final class SuggestionLearning {
  /// Decisions kept per kind.
  static const window = 20;

  /// Decisions needed before the bar may move.
  static const minDecisions = 10;
  static const raiseAtRejectShare = 0.7;
  static const lowerAtAcceptShare = 0.8;
  static const step = 0.02;
  static const maxRaise = 0.10;
  static const maxLower = 0.04;

  /// The bar for a kind starting at [base], given what was learned.
  static double thresholdFor(KindLearning learned, double base) =>
      learned.threshold ?? base;

  /// [learned] after one more decision (accepted or not).
  static KindLearning record(
    KindLearning learned,
    bool accepted, {
    required double base,
  }) {
    final recent = [...learned.recent, accepted];
    final kept = recent.length > window
        ? recent.sublist(recent.length - window)
        : recent;
    final now = thresholdFor(learned, base);
    if (kept.length < minDecisions) {
      return KindLearning(recent: kept, threshold: learned.threshold);
    }
    final accepts = kept.where((a) => a).length / kept.length;
    var next = now;
    if (1 - accepts >= raiseAtRejectShare) {
      next = (now + step).clamp(base - maxLower, base + maxRaise);
    } else if (accepts >= lowerAtAcceptShare) {
      next = (now - step).clamp(base - maxLower, base + maxRaise);
    }
    if (next == now) {
      return KindLearning(recent: kept, threshold: learned.threshold);
    }
    // A step taken: start counting again from here.
    return KindLearning(threshold: _round(next));
  }

  /// [learned] with its newest decision taken back (Undo). A step already
  /// taken stays; the count simply loses its last entry.
  static KindLearning undoLast(KindLearning learned) => KindLearning(
    recent: learned.recent.isEmpty
        ? const []
        : learned.recent.sublist(0, learned.recent.length - 1),
    threshold: learned.threshold,
  );

  /// The starting bar for each kind.
  static double baseFor(String kind) => switch (kind) {
    _ => AiSettings.strongMatch,
  };

  static double _round(double v) => (v * 1000).round() / 1000;
}
