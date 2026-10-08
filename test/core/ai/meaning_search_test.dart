import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/scheduler/analysis_run.dart';
import 'package:vera_n/core/ai/search/meaning_search.dart';
import 'package:vera_n/core/models/search_filters.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/fake_embedder.dart';
import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late FakeEmbedder embedder;
  late MeaningSearch search;
  late int piano;
  late int scales;
  late int pasta;

  setUp(() async {
    h = StorageHarness();
    embedder = FakeEmbedder();
    search = MeaningSearch(
      AnalysisRepository(h.db),
      h.repo,
      embedder: () => embedder,
    );
    piano = await h.repo.create(
      'Piano\npractice piano scales slowly every morning',
    );
    scales = await h.repo.create(
      'Scales\npiano scales practice every morning helps',
      folder: 'Music',
    );
    pasta = await h.repo.create('Pasta\nboil pasta with garlic and tomatoes');
    // Store passage vectors the way background analysis does.
    await AnalysisRun(
      analysis: AnalysisRepository(h.db),
      suggestions: SuggestionsRepository(h.db),
      embedder: embedder,
      clock: () => h.now,
      stopRequested: () => false,
    ).run();
  });
  tearDown(() => h.dispose());

  test(
    'finds notes close in meaning, best first; unrelated ones stay out',
    () async {
      final hits = await search.search('piano scales practice morning');
      expect(hits.map((h) => h.ref), containsAll([piano, scales]));
      expect(hits.map((h) => h.ref), isNot(contains(pasta)));
      expect(hits.first.snippet.text, contains('scales'));
    },
  );

  test('leaves out keyword matches and notes the filters rule out', () async {
    final hits = await search.search(
      'piano scales practice morning',
      exclude: {piano},
    );
    expect(hits.map((h) => h.ref), [scales]);
    final inMusic = await search.search(
      'piano scales practice morning',
      filters: const SearchFilters(folder: 'Music'),
    );
    expect(inMusic.map((h) => h.ref), [scales]);
  });

  test('loads the model once for many searches; close releases it', () async {
    final loadsBefore = embedder.loads;
    final closesBefore = embedder.closes;
    await search.search('piano');
    await search.search('pasta');
    expect(embedder.loads - loadsBefore, 1);
    await search.close();
    expect(embedder.closes - closesBefore, 1);
    expect(await search.search('   '), isEmpty);
  });
}
