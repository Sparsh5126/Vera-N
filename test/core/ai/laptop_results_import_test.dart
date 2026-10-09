import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/suggestions/laptop_results_import.dart';
import 'package:vera_n/core/models/booster_result.dart';
import 'package:vera_n/core/models/rejection.dart';
import 'package:vera_n/core/models/suggestion.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/booster_repository.dart';
import 'package:vera_n/core/storage/repositories/rejections_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late SuggestionsRepository suggestions;
  late BoosterRepository booster;
  late RejectionsRepository rejections;
  late LaptopResultsImport import;

  setUp(() {
    h = StorageHarness();
    suggestions = SuggestionsRepository(h.db);
    booster = BoosterRepository(h.db, h.store);
    rejections = RejectionsRepository(h.db, h.store);
    import = LaptopResultsImport(
      booster: booster,
      suggestions: suggestions,
      analysis: AnalysisRepository(h.db),
      rejections: rejections,
    );
  });
  tearDown(() => h.dispose());

  Future<NoteStamp> stamp(int ref) async =>
      NoteStamp((await h.repo.ensureId(ref))!, (await h.row(ref)).contentHash);

  Future<void> laptop(
    BoosterKind kind,
    List<int> refs,
    List<String> values,
  ) async {
    await booster.add('laptop1', [
      BoosterResult(
        kind: kind,
        notes: [for (final r in refs) await stamp(r)],
        values: values,
        model: 'gemma-4',
        madeAt: DateTime.utc(2026, 10, 9),
        deviceId: 'laptop1',
      ),
    ]);
  }

  test('a "Why?" goes on the waiting link between the same notes', () async {
    final a = await h.repo.create('Triund\nSpring trek.');
    final b = await h.repo.create('Packing\nFor the trek.');
    await suggestions.add(
      [
        SuggestionDraft(
          kind: 'link',
          noteA: b,
          noteB: a,
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      DateTime.now(),
      const Duration(days: 30),
    );
    await laptop(BoosterKind.why, [a, b], ['Both are about the trek.']);
    await import.run();
    expect(
      (await suggestions.pending()).single.detail,
      'Both are about the trek.',
    );
  });

  test('new tag names and a topic become tag suggestions; tags a note has '
      'are left out', () async {
    final a = await h.repo.create('Triund\nSpring trek.');
    final b = await h.repo.create('Hampta\nSummer trek.');
    final c = await h.repo.create('Kedarkantha\nWinter trek.');
    await h.repo.setTags(c, ['treks']);
    await laptop(BoosterKind.tags, [a], ['packing', 'spring']);
    await laptop(BoosterKind.topic, [a, b, c], ['treks']);
    expect(await import.run(), 4);
    final tags = {
      for (final s in await suggestions.pending()) '${s.noteA}:${s.tag}': s,
    };
    expect(tags.keys.toSet(), {
      '$a:packing',
      '$a:spring',
      '$a:treks',
      '$b:treks',
    });
    // A new name has no other note as its reason; a topic shows another
    // note of the topic.
    expect(tags['$a:packing']!.noteB, a);
    expect(tags['$b:treks']!.noteB, c);
  });

  test('copies become one duplicate suggestion with the laptop\'s sentence; '
      'unless the user said they aren\'t copies', () async {
    final a = await h.repo.create('Groceries\nMilk, eggs.');
    final b = await h.repo.create('Groceries\nMilk, eggs, bread.');
    await laptop(BoosterKind.duplicate, [b, a], ['Both list groceries.']);
    await import.run();
    final s = (await suggestions.pending()).single;
    expect(s.kind, Suggestion.duplicateKind);
    expect((s.noteA, s.noteB), (a, b));
    expect(s.detail, 'Both list groceries.');

    await suggestions.clear();
    await h.db.delete(h.db.importedResults).go();
    final (first, second) = Rejection.duplicateSides(
      (await stamp(a)).key,
      (await stamp(b)).key,
    );
    await rejections.add(
      Rejection(
        noteA: first,
        hashA: 'h',
        noteB: second,
        hashB: 'h',
        rejectedAt: DateTime.now(),
        deviceId: 'phone1',
      ),
    );
    await import.run();
    expect(await suggestions.pending(), isEmpty);
  });

  test('offered once: an expired or rejected suggestion doesn\'t come back; '
      'a "nothing found" or a stale result offers nothing', () async {
    final a = await h.repo.create('Triund\nSpring trek.');
    final b = await h.repo.create('Hampta\nSummer trek.');
    await laptop(BoosterKind.tags, [a], ['packing']);
    await laptop(BoosterKind.tags, [b], []);
    expect(await import.run(), 1);
    await suggestions.clear();
    expect(await import.run(), 0);

    await laptop(BoosterKind.tags, [b], ['summer']);
    await h.repo.updateBody(b, 'Hampta\nSummer trek, changed.');
    expect(await import.run(), 0);
    expect(await suggestions.importedResults(), hasLength(1));
  });

  test('no laptop results: nothing happens', () async {
    await h.repo.create('Alone\nJust a note.');
    expect(await import.run(), 0);
  });
}
