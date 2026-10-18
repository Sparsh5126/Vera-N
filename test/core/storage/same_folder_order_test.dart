import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/suggestion.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late SuggestionsRepository suggestions;

  setUp(() {
    h = StorageHarness();
    suggestions = SuggestionsRepository(h.db);
  });
  tearDown(() => h.dispose());

  SuggestionDraft link(int a, int b) => SuggestionDraft(
    kind: Suggestion.linkKind,
    noteA: a,
    noteB: b,
    score: .7,
    chunkA: 0,
    chunkB: 0,
  );

  Future<void> add(List<SuggestionDraft> drafts) async {
    await suggestions.add(drafts, h.now, const Duration(days: 30));
    h.now = h.now.add(const Duration(minutes: 1));
  }

  test(
    'sameFolderAs: the exact folder, case ignored; no folder is none',
    () async {
      final analysis = AnalysisRepository(h.db);
      final a = await h.repo.create('One', folder: 'Study');
      final b = await h.repo.create('Two', folder: 'study');
      await h.repo.create('Three', folder: 'Study/Exams');
      final loose = await h.repo.create('Four');
      await h.repo.create('Five');
      expect(await analysis.sameFolderAs(a), {b});
      expect(await analysis.sameFolderAs(loose), isEmpty);
    },
  );

  test('a same-folder link comes first in Review, even when newer', () async {
    final a = await h.repo.create('One', folder: 'Study');
    final b = await h.repo.create('Two', folder: 'Study');
    final c = await h.repo.create('Three', folder: 'Trips');
    final d = await h.repo.create('Four');
    final e = await h.repo.create('Five');
    await add([link(a, c)]); // oldest, different folders
    await add([link(d, e)]); // both without a folder: no signal
    await add([link(a, b)]); // newest, same folder

    final order = (await suggestions.batch(size: 5))
        .map((s) => {s.noteA, s.noteB})
        .toList();
    expect(order, [
      {a, b},
      {a, c},
      {d, e},
    ]);
  });

  test('"not sure" ones still come after fresh ones', () async {
    final a = await h.repo.create('One', folder: 'Study');
    final b = await h.repo.create('Two', folder: 'Study');
    final c = await h.repo.create('Three');
    final d = await h.repo.create('Four');
    await add([link(a, b)]);
    await add([link(c, d)]);
    final same = (await suggestions.pending()).first;
    await suggestions.setNotSure(same.id, notSure: true);

    final order = (await suggestions.batch(size: 5))
        .map((s) => {s.noteA, s.noteB})
        .toList();
    expect(order, [
      {c, d},
      {a, b},
    ]);
  });
}
