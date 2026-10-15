import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/matching/note_matcher.dart';
import 'package:vera_n/core/ai/matching/tag_suggester.dart';
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
  group('TagSuggester', () {
    NoteMatch n(int note, double score) => NoteMatch(note, score, 0, 0);

    test(
      'a tag two neighbours share is suggested, with the best as reason',
      () {
        final c = TagSuggester.forNote(
          neighbours: [n(2, .9), n(3, .7), n(4, .65)],
          tagsOf: {
            2: {'Music'},
            3: {'music', 'daily'},
            4: {'daily'},
          },
          own: const {},
          rejected: const {},
          limit: 2,
        );
        expect(c.map((t) => t.tag), ['Music', 'daily']);
        expect(c.first.evidence.note, 2);
        expect(c.first.score, closeTo(.8, 1e-9));
      },
    );

    test('one neighbour is enough only when very close (2026-10-15)', () {
      List<String> tags(double score) => [
        for (final t in TagSuggester.forNote(
          neighbours: [n(2, score)],
          tagsOf: {
            2: {'dbms'},
          },
          own: const {},
          rejected: const {},
          limit: 2,
        ))
          t.tag,
      ];
      expect(tags(.69), isEmpty);
      expect(tags(.70), ['dbms']);
    });

    test('own and rejected tags are skipped', () {
      final c = TagSuggester.forNote(
        neighbours: [n(2, .9), n(3, .8)],
        tagsOf: {
          2: {'music', 'plans'},
          3: {'music', 'plans'},
        },
        own: const {'Music'},
        rejected: const {'plans'},
        limit: 2,
      );
      expect(c, isEmpty);
    });
  });

  group('analysis and actions', () {
    late StorageHarness h;
    late SuggestionsRepository suggestions;
    late SuggestionActions actions;

    setUp(() {
      h = StorageHarness();
      suggestions = SuggestionsRepository(h.db);
      actions = SuggestionActions(
        notes: h.repo,
        links: LinksRepository(h.db),
        suggestions: suggestions,
        rejections: RejectionsRepository(h.db, h.store),
        settings: SettingsRepository(h.db),
        clock: () => h.now,
      );
    });
    tearDown(() => h.dispose());

    Future<void> analyse() => AnalysisRun(
      analysis: AnalysisRepository(h.db),
      suggestions: suggestions,
      embedder: FakeEmbedder(),
      clock: () => h.now,
      stopRequested: () => false,
    ).run();

    /// Two tagged piano notes and an untagged one close to both.
    Future<int> untagged() async {
      for (final body in [
        'Scales\npractice piano scales slowly every single morning',
        'Chords\npractice piano chords slowly every single morning',
      ]) {
        final ref = await h.repo.create(body);
        await h.repo.setTags(ref, ['music']);
      }
      return h.repo.create(
        'Arpeggios\npractice piano arpeggios slowly every single morning',
      );
    }

    Future<Suggestion> tagFor(int ref) async => (await suggestions.pending())
        .singleWhere((s) => s.isTag && s.noteA == ref);

    test(
      'suggests the shared tag; accepting adds it, undo removes it',
      () async {
        final ref = await untagged();
        await analyse();
        final s = await tagFor(ref);
        expect(s.tag, 'music');

        final undo = await actions.accept(s);
        expect((await h.repo.getNote(ref))!.tags, ['music']);
        expect((await suggestions.pending()).where((p) => p.isTag), isEmpty);
        await undo();
        expect((await h.repo.getNote(ref))!.tags, isEmpty);
      },
    );

    test('a rejected tag is not suggested again', () async {
      final ref = await untagged();
      await analyse();
      await actions.reject(await tagFor(ref));
      // The note changes, so it is analysed again.
      await h.repo.updateBody(
        ref,
        'Arpeggios\npractice piano arpeggios slowly every single morning too',
      );
      await analyse();
      expect(
        (await suggestions.pending()).where((s) => s.isTag && s.noteA == ref),
        isEmpty,
      );
    });
  });
}
