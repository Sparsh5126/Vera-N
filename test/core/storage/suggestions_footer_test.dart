import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/matching/vectors.dart';
import 'package:vera_n/core/models/chunk_vector.dart';
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

  ChunkVector chunk(int note, int idx, int start, int end) => ChunkVector(
    note: note,
    idx: idx,
    start: start,
    end: end,
    hash: '$note-$idx',
    vector: Vectors.quantize(Float32List(384)),
  );

  SuggestionDraft link(int a, int b, int chunkA, {bool laptop = false}) =>
      SuggestionDraft(
        kind: Suggestion.linkKind,
        noteA: a,
        noteB: b,
        score: 0.9,
        chunkA: chunkA,
        chunkB: 0,
        fromLaptop: laptop,
      );

  test('a suggestion matched in the footer goes; others stay', () async {
    final a = await h.repo.create('Piano practice every morning, then read.');
    final b = await h.repo.create('Garden: tomatoes need water and sun.');
    final c = await h.repo.create('Trek packing list for the winter trail.');
    // Note a: chunk 0 is its own text, chunk 1 reaches into a footer that
    // starts at 40.
    await AnalysisRepository(h.db).save(a, 'hash', 'fake@1', [
      chunk(a, 0, 0, 38),
      chunk(a, 1, 30, 70),
    ], h.now);
    await suggestions.add(
      [link(a, b, 1), link(a, c, 0), link(b, c, 1, laptop: true)],
      h.now,
      const Duration(days: 30),
    );

    expect(await suggestions.dropFooterMatches(a, 40), 1);

    final left = (await suggestions.pending()).map((s) => {s.noteA, s.noteB});
    expect(
      left,
      containsAll([
        {a, c},
        {b, c},
      ]),
    );
    expect(left, isNot(contains(equals({a, b}))));
  });

  test('a note with no footer keeps every suggestion', () async {
    final a = await h.repo.create('Piano practice every morning, then read.');
    final b = await h.repo.create('Garden: tomatoes need water and sun.');
    await AnalysisRepository(h.db)
        .save(a, 'hash', 'fake@1', [chunk(a, 0, 0, 40)], h.now);
    await suggestions.add([link(a, b, 0)], h.now, const Duration(days: 30));

    expect(await suggestions.dropFooterMatches(a, 40), 0);
    expect(await suggestions.pending(), hasLength(1));
  });
}
