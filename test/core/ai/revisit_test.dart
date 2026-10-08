import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/scheduler/analysis_run.dart';
import 'package:vera_n/core/ai/suggestions/suggestion_actions.dart';
import 'package:vera_n/core/models/suggestion.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/links_repository.dart';
import 'package:vera_n/core/storage/repositories/rejections_repository.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/fake_embedder.dart';
import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late SuggestionsRepository suggestions;

  setUp(() {
    h = StorageHarness();
    suggestions = SuggestionsRepository(h.db);
  });
  tearDown(() => h.dispose());

  Future<void> analyse() => AnalysisRun(
    analysis: AnalysisRepository(h.db),
    suggestions: suggestions,
    embedder: FakeEmbedder(),
    clock: () => h.now,
    stopRequested: () => false,
  ).run();

  /// An old note written [ageDays] ago, and a related note written today.
  Future<(int, int)> oldAndNew({int ageDays = 40}) async {
    final today = h.now;
    h.now = today.subtract(Duration(days: ageDays));
    final old = await h.repo.create(
      'Trip ideas\nvisit the hills by train in the spring season',
    );
    await analyse();
    h.now = today;
    final recent = await h.repo.create(
      'Spring plan\nvisit the hills by train in the spring season soon',
    );
    return (old, recent);
  }

  Future<List<Suggestion>> revisits() =>
      suggestions.watchRevisit(limit: 5).first;

  test('an old note related to a new one is offered to revisit, apart '
      'from the review batches', () async {
    final (old, recent) = await oldAndNew();
    await analyse();
    final r = (await revisits()).single;
    expect((r.kind, r.noteA, r.noteB), (Suggestion.resurfaceKind, old, recent));
    expect(
      (await suggestions.pending()).where((s) => s.kind == 'resurface'),
      isEmpty,
    );
  });

  test('a note changed this month is not "old"', () async {
    await oldAndNew(ageDays: 10);
    await analyse();
    expect(await revisits(), isEmpty);
  });

  test('Not now hides it for a month; undo shows it again', () async {
    await oldAndNew();
    await analyse();
    final actions = SuggestionActions(
      notes: h.repo,
      links: LinksRepository(h.db),
      suggestions: suggestions,
      rejections: RejectionsRepository(h.db, h.store),
      settings: SettingsRepository(h.db),
      clock: () => h.now,
    );
    final r = (await revisits()).single;
    final undo = await actions.putOff(r);
    expect(await revisits(), isEmpty);
    // Still known, so analysis doesn't offer it again meanwhile.
    await analyse();
    expect(await revisits(), isEmpty);
    await undo();
    expect(await revisits(), hasLength(1));
  });
}
