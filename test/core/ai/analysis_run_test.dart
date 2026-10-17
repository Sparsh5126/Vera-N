import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/scheduler/analysis_run.dart';
import 'package:vera_n/core/ai/suggestions/suggestion_actions.dart';
import 'package:vera_n/core/storage/files/note_footer.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/links_repository.dart';
import 'package:vera_n/core/storage/repositories/rejections_repository.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/fake_embedder.dart';
import '../../support/storage_harness.dart';

const piano = 'Time loop\nIf every day repeats I would practice piano daily.';
const piano2 =
    'Piano plan\nIf every day repeats I would practice piano daily too.';
const garden = 'Garden\nTomatoes need water and sun in the morning hours.';

void main() {
  late StorageHarness h;
  late FakeEmbedder embedder;
  late SuggestionsRepository suggestions;
  var stop = false;

  AnalysisRun run() => AnalysisRun(
    analysis: AnalysisRepository(h.db),
    suggestions: suggestions,
    embedder: embedder,
    clock: () => h.now,
    stopRequested: () => stop,
  );

  setUp(() {
    h = StorageHarness();
    embedder = FakeEmbedder();
    suggestions = SuggestionsRepository(h.db);
    stop = false;
  });
  tearDown(() => h.dispose());

  test('related notes become one suggestion; unrelated ones none', () async {
    final a = await h.repo.create(piano);
    final b = await h.repo.create(piano2);
    await h.repo.create(garden);

    expect(await run().run(), isTrue);

    final pending = await suggestions.pending();
    expect(pending, hasLength(1));
    expect((pending.single.noteA, pending.single.noteB), (a, b));
    expect(pending.single.kind, 'link');
    expect(pending.single.notSure, isFalse);
    expect(pending.single.expiresAt, h.now.add(const Duration(days: 30)));
    expect(embedder.closes, embedder.loads);
  });

  test('nothing changed: the model is not even loaded', () async {
    await h.repo.create(piano);
    await run().run();
    embedder = FakeEmbedder();
    await run().run();
    expect(embedder.loads, 0);
  });

  test('an edit re-embeds only the chunks that changed', () async {
    final body = List.generate(
      40,
      (i) => 'Sentence number $i is here.',
    ).join(' ');
    final a = await h.repo.create('Long\n$body');
    await run().run();
    final first = embedder.embedded.length;
    expect(first, greaterThan(1));

    embedder.embedded.clear();
    await h.repo.updateBody(a, 'Long\n$body One more sentence.');
    await run().run();
    expect(embedder.embedded.length, lessThan(first));
    expect(embedder.embedded.last, contains('One more sentence.'));
  });

  test('notes already linked are never suggested', () async {
    final b = await h.repo.create(piano2);
    final link = await LinksRepository(h.db).linkTextFor(b);
    await h.repo.create('$piano $link');
    await run().run();
    expect(await suggestions.pending(), isEmpty);
  });

  test(
    'notes linked to the same notes are not matched on the footer',
    () async {
      // Found 2026-10-17: every note with a "Linked notes" footer was
      // suggested with every other, since the footers listed the same titles.
      final links = LinksRepository(h.db);
      final habits = await h.repo.create(
        'Atomic habits notes\nSmall habits compound into big results.',
      );
      final routine = await h.repo.create(
        'Morning routine plan\nWake early, stretch, then read twenty pages.',
      );
      var withLinks = piano;
      var gardenLinks = garden;
      for (final ref in [habits, routine]) {
        final link = (await links.linkTextFor(ref))!;
        withLinks = NoteFooter.append(withLinks, link);
        gardenLinks = NoteFooter.append(gardenLinks, link);
      }
      final a = await h.repo.create(withLinks);
      final g = await h.repo.create(gardenLinks);

      await run().run();

      final pairs = (await suggestions.pending()).map(
        (s) => {s.noteA, s.noteB},
      );
      expect(pairs, isNot(contains(equals({a, g}))));
    },
  );

  test('very short notes are not matched', () async {
    await h.repo.create('Piano daily');
    await h.repo.create('Piano daily');
    await run().run();
    expect(await suggestions.pending(), isEmpty);
  });

  test('trashed notes are left out', () async {
    await h.repo.create(piano);
    final b = await h.repo.create(piano2);
    await h.repo.trash(b);
    await run().run();
    expect(await suggestions.pending(), isEmpty);
  });

  test('a new model version embeds every note again', () async {
    await h.repo.create(piano);
    await h.repo.create(garden);
    await run().run();
    embedder = FakeEmbedder(model: 'fake@2');
    await run().run();
    expect(embedder.embedded, hasLength(2));
  });

  test('suggestions expire after 30 days unreviewed', () async {
    await h.repo.create(piano);
    await h.repo.create(piano2);
    await run().run();
    h.now = h.now.add(const Duration(days: 31));
    await run().run();
    expect(await suggestions.pending(), isEmpty);
  });

  test('re-matching keeps the first expiry date', () async {
    final a = await h.repo.create(piano);
    await h.repo.create(piano2);
    await run().run();
    final expires = (await suggestions.pending()).single.expiresAt;
    h.now = h.now.add(const Duration(days: 10));
    await h.repo.updateBody(a, '$piano Again.');
    await run().run();
    expect((await suggestions.pending()).single.expiresAt, expires);
  });

  test('stops early when the system ends the work', () async {
    await h.repo.create(piano);
    await h.repo.create(garden);
    stop = true;
    expect(await run().run(), isFalse);
    expect(embedder.embedded, isEmpty);
    expect(embedder.closes, 1);
  });

  group('a rejected pair', () {
    final shared = List.generate(30, (i) => 'shared$i').join(' ');
    final extra = List.generate(40, (i) => 'extra$i').join(' ');

    Future<int> rejectOnly() async {
      final a = await h.repo.create('Alpha $shared');
      await h.repo.create('Beta $shared');
      await run().run();
      final actions = SuggestionActions(
        notes: h.repo,
        links: LinksRepository(h.db),
        suggestions: suggestions,
        rejections: RejectionsRepository(h.db, h.store),
        settings: SettingsRepository(h.db),
      );
      await actions.reject((await suggestions.pending()).single);
      return a;
    }

    test('stays away after a small edit', () async {
      final a = await rejectOnly();
      await h.repo.updateBody(a, 'Alpha $shared typo fixed');
      await run().run();
      expect(await suggestions.pending(), isEmpty);
    });

    test('may return after a big change, if still a strong match', () async {
      final a = await rejectOnly();
      await h.repo.updateBody(a, 'Alpha $shared $extra');
      await run().run();
      expect(await suggestions.pending(), hasLength(1));
    });
  });
}
