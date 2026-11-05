import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/matching/same_title.dart';
import 'package:vera_n/core/ai/scheduler/analysis_run.dart';
import 'package:vera_n/core/ai/suggestions/suggestion_actions.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/links_repository.dart';
import 'package:vera_n/core/storage/repositories/rejections_repository.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/fake_embedder.dart';
import '../../support/storage_harness.dart';

/// Notes with the same title are offered as a link even when their words
/// don't match (user, 2026-11-05: two notes named "Quotes").
const love = 'Quotes\nLove is patient and kind, it keeps no record of wrongs.';
const sea = 'quotes\nThe sea is calm tonight; the tide is full, the moon lies.';
const garden = 'Garden\nTomatoes need water and sun in the morning hours.';

void main() {
  late StorageHarness h;
  late SuggestionsRepository suggestions;
  late SettingsRepository settings;

  AnalysisRun run({bool sweep = false}) => AnalysisRun(
    analysis: AnalysisRepository(h.db),
    suggestions: suggestions,
    embedder: FakeEmbedder(),
    clock: () => h.now,
    sweepSameTitles: sweep,
  );

  SuggestionActions actions() => SuggestionActions(
    notes: h.repo,
    links: LinksRepository(h.db),
    suggestions: suggestions,
    rejections: RejectionsRepository(h.db, h.store),
    settings: settings,
  );

  setUp(() {
    h = StorageHarness();
    suggestions = SuggestionsRepository(h.db);
    settings = SettingsRepository(h.db);
  });
  tearDown(() => h.dispose());

  group('SameTitle', () {
    test('as shown, trimmed, case ignored; empty never matches', () {
      expect(SameTitle.alike('Quotes', ' quotes '), isTrue);
      expect(SameTitle.alike('**Quotes**', 'Quotes'), isTrue);
      expect(SameTitle.alike('Quotes', 'Quote'), isFalse);
      expect(SameTitle.alike('', ''), isFalse);
    });

    test('groups only titles more than one note has', () {
      final groups = SameTitle.groups({1: 'Quotes', 2: 'QUOTES', 3: 'Garden'});
      expect(groups, {
        'quotes': [1, 2],
      });
      expect(SameTitle.notesLike(2, groups), [1]);
      expect(SameTitle.notesLike(3, groups), isEmpty);
    });
  });

  test('two notes with the same title become a link', () async {
    final a = await h.repo.create(love);
    final b = await h.repo.create(sea);
    await h.repo.create(garden);
    await run().run();

    final pending = await suggestions.pending();
    expect(pending, hasLength(1));
    expect({pending.single.noteA, pending.single.noteB}, {a, b});
    expect(pending.single.isLink, isTrue);
  });

  test(
    'a rejected same-title pair stays away, and the bar is not moved',
    () async {
      final a = await h.repo.create(love);
      await h.repo.create(sea);
      await run().run();
      final before = await settings.learning('link');
      await actions().reject((await suggestions.pending()).single);
      expect(await settings.learning('link'), before);

      await h.repo.updateBody(a, '$love\nOne more line.');
      await run().run();
      expect(await suggestions.pending(), isEmpty);
    },
  );

  test('the one-time sweep pairs notes analysed earlier', () async {
    await h.repo.create(love);
    await h.repo.create(sea);
    await run().run();
    await suggestions.remove((await suggestions.pending()).single.id);

    await run().run();
    expect(await suggestions.pending(), isEmpty);
    await run(sweep: true).run();
    expect(await suggestions.pending(), hasLength(1));
  });
}
