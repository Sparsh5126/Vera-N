import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/matching/note_matcher.dart';
import 'package:vera_n/core/ai/matching/vectors.dart';
import 'package:vera_n/core/models/chunk_vector.dart';

ChunkVector chunk(int note, int idx, List<double> v) => ChunkVector(
  note: note,
  idx: idx,
  start: 0,
  end: 1,
  hash: '$note-$idx',
  vector: Vectors.quantize(Vectors.meanPool(v, 1, v.length)),
);

void main() {
  final own = [
    chunk(1, 0, [1, 0, 0]),
    chunk(1, 1, [0, 1, 0]),
  ];
  final others = [
    ...own,
    chunk(2, 0, [0, 0, 1]), // unrelated
    chunk(3, 0, [0.1, 1, 0]), // close to own chunk 1
    chunk(3, 1, [1, 1, 0]), // weaker
    chunk(4, 0, [1, 0.2, 0]), // close to own chunk 0
  ];

  test('keeps strong matches only, best chunk pair per note', () {
    final m = NoteMatcher.strongMatches(own, others, threshold: .9, limit: 5);
    expect(m.map((x) => x.note), unorderedEquals([3, 4]));
    final three = m.firstWhere((x) => x.note == 3);
    expect((three.ownChunk, three.otherChunk), (1, 0));
  });

  test('strongest first, limited, excluded notes skipped', () {
    final m = NoteMatcher.strongMatches(
      own,
      others,
      threshold: .5,
      limit: 1,
      exclude: {3},
    );
    expect(m.single.note, 4);
  });

  test('a note never matches itself', () {
    final m = NoteMatcher.strongMatches(own, own, threshold: 0, limit: 5);
    expect(m, isEmpty);
  });
}
