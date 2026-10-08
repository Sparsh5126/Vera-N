import 'package:flutter/foundation.dart';

/// What the app has learned about one kind of suggestion (link, tag): its
/// recent accept / reject decisions and its current match bar.
@immutable
class KindLearning {
  const KindLearning({this.recent = const [], this.threshold});

  /// Newest last; true is accepted. "Not sure" never counts.
  final List<bool> recent;

  /// The kind's bar; null means the starting bar.
  final double? threshold;
}
