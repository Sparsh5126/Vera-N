import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/suggestions/laptop_results_import.dart';
import 'package:vera_n/core/ai/suggestions/suggestion_actions.dart';
import 'package:vera_n/core/models/booster_result.dart';
import 'package:vera_n/core/models/suggestion.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/files/note_merge.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/booster_repository.dart';
import 'package:vera_n/core/storage/repositories/links_repository.dart';
import 'package:vera_n/core/storage/repositories/rejections_repository.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  group('NoteMerge', () {
    test('adds only the lines the kept note lacks, after its text', () {
      expect(
        NoteMerge.merge(
          'Groceries\nMilk\nEggs\n',
          'Groceries\n  Milk\nBread\n\nEggs\nBread\n',
        ),
        'Groceries\nMilk\nEggs\n\nBread\n',
      );
    });

    test('nothing new: the kept note is unchanged', () {
      expect(NoteMerge.merge('A\nB\n', 'B\nA'), 'A\nB\n');
    });

    test('new lines go above "Linked notes"; the footers join', () {
      expect(
        NoteMerge.merge(
          'Trek\nBoots\n\n## Linked notes\n- [[Packing]]\n',
          'Trek\nTorch\n\n## Linked notes\n- [[Packing]]\n- [[Route]]\n',
        ),
        'Trek\nBoots\n\nTorch\n\n## Linked notes\n- [[Packing]]\n- [[Route]]\n',
      );
    });

    test('added paragraphs keep one blank line between them', () {
      expect(
        NoteMerge.merge('Trip\nBoots\n', 'Gear\n\n\nTorch\nBoots\n\nMap\n\n'),
        'Trip\nBoots\n\nGear\n\nTorch\n\nMap\n',
      );
    });

    test('Hindi lines merge the same way', () {
      expect(
        NoteMerge.merge('सामान\nदाल\n', 'सामान\nचावल\nदाल'),
        'सामान\nदाल\n\nचावल\n',
      );
    });
  });

  group('DuplicateActions', () {
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
      );
    });
    tearDown(() => h.dispose());

    Future<(int, int, Suggestion)> copies() async {
      final short = await h.repo.create('Groceries\nMilk\nEggs');
      final long = await h.repo.create('Groceries\nMilk\nEggs\nBread\nRice');
      await suggestions.add(
        [
          SuggestionDraft(
            kind: Suggestion.duplicateKind,
            noteA: short,
            noteB: long,
            score: 1,
            chunkA: 0,
            chunkB: 0,
            detail: 'Both list groceries.',
            fromLaptop: true,
          ),
        ],
        DateTime.now(),
        const Duration(days: 30),
      );
      return (short, long, (await suggestions.pending()).single);
    }

    Future<bool> trashed(int ref) async => (await h.row(ref)).trashedAt != null;

    test(
      'accept is Merge: the longer note is kept and gains what only the '
      'other has; the other goes to the trash; Undo puts both back',
      () async {
        final (short, long, s) = await copies();
        await h.repo.updateBody(short, 'Groceries\nMilk\nEggs\nSalt');
        final undo = await actions.accept(s);
        expect(
          (await h.row(long)).body,
          'Groceries\nMilk\nEggs\nBread\nRice\n\nSalt\n',
        );
        expect(await trashed(short), isTrue);
        expect(await suggestions.pending(), isEmpty);

        await undo();
        expect((await h.row(long)).body, 'Groceries\nMilk\nEggs\nBread\nRice');
        expect(await trashed(short), isFalse);
        expect(await suggestions.pending(), hasLength(1));
      },
    );

    test('Remove one trashes the chosen note only', () async {
      final (short, long, s) = await copies();
      final undo = await actions.duplicates.removeOne(s, long);
      expect(await trashed(long), isTrue);
      expect((await h.row(short)).body, 'Groceries\nMilk\nEggs');
      await undo();
      expect(await trashed(long), isFalse);
    });

    test('"Not copies" is remembered: the laptop\'s result isn\'t offered '
        'again, and the phone\'s learned bars don\'t move', () async {
      final (short, long, s) = await copies();
      final settings = SettingsRepository(h.db);
      final before = await settings.learning(Suggestion.duplicateKind);
      await actions.reject(s);
      expect(await settings.learning(Suggestion.duplicateKind), before);

      final booster = BoosterRepository(h.db, h.store);
      final stamps = await booster.stamps();
      NoteStamp stamp(int ref) {
        final e = stamps.entries.firstWhere((e) => e.value.ref == ref);
        return NoteStamp(e.key, e.value.hash);
      }

      await booster.add('laptop1', [
        BoosterResult(
          kind: BoosterKind.duplicate,
          notes: [stamp(short), stamp(long)],
          values: ['Both list groceries.'],
          model: 'm',
          madeAt: DateTime.now(),
          deviceId: 'laptop1',
        ),
      ]);
      final offered = await LaptopResultsImport(
        booster: booster,
        suggestions: suggestions,
        analysis: AnalysisRepository(h.db),
        rejections: RejectionsRepository(h.db, h.store),
      ).run();
      expect(offered, 0);
    });
  });
}
