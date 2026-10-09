import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/matching/vectors.dart';
import 'package:vera_n/core/booster/note_groups.dart';
import 'package:vera_n/core/models/chunk_vector.dart';

/// A unit vector pointing mostly along [axis], tilted by [tilt] towards
/// axis 7, so similarity to the plain axis is cos(tilt).
Float32List direction(int axis, {double tilt = 0}) {
  final v = Float32List(16);
  v[axis] = cos(tilt);
  v[7] += sin(tilt);
  return v;
}

ChunkVector chunk(int note, Float32List v, {int idx = 0}) => ChunkVector(
  note: note,
  idx: idx,
  start: 0,
  end: 1,
  hash: 'h',
  vector: Vectors.quantize(v),
);

void main() {
  test('a note\'s meaning is the mean of its chunks', () {
    final m = NoteGroups.meanings([
      chunk(1, direction(0)),
      chunk(1, direction(1), idx: 1),
    ]);
    expect(m[1]![0], closeTo(sqrt1_2, 0.01));
    expect(m[1]![1], closeTo(sqrt1_2, 0.01));
  });

  test('topics: three or more close notes form a group; a pair or a far '
      'note does not', () {
    final m = NoteGroups.meanings([
      chunk(1, direction(0)),
      chunk(2, direction(0, tilt: 0.3)),
      chunk(3, direction(0, tilt: 0.5)),
      chunk(4, direction(1)),
      chunk(5, direction(1, tilt: 0.2)),
      chunk(6, direction(2)),
    ]);
    expect(NoteGroups.topics(m), [
      [1, 2, 3],
    ]);
  });

  test('topics keep only the closest eight', () {
    final m = NoteGroups.meanings([
      for (var i = 1; i <= 12; i++) chunk(i, direction(0, tilt: i * 0.03)),
    ]);
    final groups = NoteGroups.topics(m);
    expect(groups.first, hasLength(8));
    expect(groups.first, contains(1));
  });

  test('duplicate candidates: nearly the same meaning and similar length', () {
    final m = NoteGroups.meanings([
      chunk(1, direction(0)),
      chunk(2, direction(0, tilt: 0.1)),
      chunk(3, direction(0, tilt: 0.05)),
      chunk(4, direction(0, tilt: 0.6)),
    ]);
    final pairs = NoteGroups.duplicateCandidates(m, {
      1: 100,
      2: 90,
      3: 20,
      4: 100,
    });
    // 3 is too short to be a copy of 1 or 2; 4 is only about the same topic.
    expect(pairs, [(1, 2)]);
  });
}
