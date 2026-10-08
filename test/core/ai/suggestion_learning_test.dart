import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/suggestions/suggestion_learning.dart';
import 'package:vera_n/core/models/kind_learning.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  const base = 0.60;

  KindLearning decide(KindLearning start, List<bool> decisions) {
    var learned = start;
    for (final d in decisions) {
      learned = SuggestionLearning.record(learned, d, base: base);
    }
    return learned;
  }

  double bar(KindLearning l) => SuggestionLearning.thresholdFor(l, base);

  test('mostly rejected: the bar rises one step, and counting restarts', () {
    final learned = decide(const KindLearning(), [
      ...List.filled(8, false),
      true,
      true,
    ]);
    expect(bar(learned), closeTo(0.62, 1e-9));
    expect(learned.recent, isEmpty);
  });

  test('mostly accepted: the bar eases down, never below the floor', () {
    var learned = const KindLearning();
    for (var round = 0; round < 5; round++) {
      learned = decide(learned, List.filled(10, true));
    }
    expect(bar(learned), closeTo(base - SuggestionLearning.maxLower, 1e-9));
  });

  test('never above the ceiling; mixed decisions keep the bar', () {
    var learned = const KindLearning();
    for (var round = 0; round < 10; round++) {
      learned = decide(learned, List.filled(10, false));
    }
    expect(bar(learned), closeTo(base + SuggestionLearning.maxRaise, 1e-9));
    final mixed = decide(const KindLearning(), [
      for (var i = 0; i < 10; i++) i.isEven,
    ]);
    expect(bar(mixed), base);
    expect(mixed.recent, hasLength(10));
  });

  test('fewer than 10 decisions: nothing moves; undo takes the last back', () {
    final learned = decide(const KindLearning(), List.filled(9, false));
    expect(bar(learned), base);
    expect(SuggestionLearning.undoLast(learned).recent, hasLength(8));
  });

  test('settings keep what was learned per kind', () async {
    final h = StorageHarness();
    final settings = SettingsRepository(h.db);
    await settings.saveLearning(
      'link',
      const KindLearning(recent: [true, false], threshold: 0.62),
    );
    final back = await settings.learning('link');
    expect(back.recent, [true, false]);
    expect(back.threshold, 0.62);
    expect((await settings.learning('tag')).threshold, isNull);
    await h.dispose();
  });
}
