import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_id.dart';

void main() {
  final created = DateTime(2026, 10, 3, 15, 32, 28);

  test('creation time plus 4 hex characters', () {
    final id = NoteId.generate(created, random: Random(1));
    expect(id, matches(RegExp(r'^20261003-153228-[0-9a-f]{4}$')));
    expect(NoteId.isGenerated(id), isTrue);
    expect(NoteId.fileName(id), '$id.md');
  });

  test('pads small dates and suffixes', () {
    final id = NoteId.generate(DateTime(2027, 1, 2, 3, 4, 5));
    expect(id.substring(0, 15), '20270102-030405');
  });

  test('same second gives different ids', () {
    final random = Random(7);
    final ids = {
      for (var i = 0; i < 50; i++) NoteId.generate(created, random: random),
    };
    expect(ids.length, greaterThan(45));
  });

  test('imported names are not generated ids', () {
    expect(NoteId.isGenerated('Movie idea'), isFalse);
    expect(NoteId.isGenerated('20261003-153228'), isFalse);
    expect(NoteId.isGenerated('20261003-153228-A7F3'), isFalse);
  });
}
