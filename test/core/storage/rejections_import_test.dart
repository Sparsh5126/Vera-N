import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/rejection.dart';
import 'package:vera_n/core/storage/repositories/rejections_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late RejectionsRepository rejections;

  setUp(() {
    h = StorageHarness();
    rejections = RejectionsRepository(h.db, h.store);
  });
  tearDown(() => h.dispose());

  Rejection rejection(String a, String b, {Uint8List? sig}) => Rejection(
    noteA: a,
    hashA: 'h-$a',
    noteB: b,
    hashB: 'h-$b',
    rejectedAt: DateTime.utc(2026, 10, 8),
    deviceId: 'phone1',
    signatureA: sig,
    signatureB: sig,
  );

  Future<List<String>> keys() async =>
      (await rejections.all()).map((r) => r.pairKey).toList()..sort();

  test('a reinstall reads this device\'s file back', () async {
    // The old install wrote its file; the new install has an empty database.
    h.store.appFiles[RejectionsRepository.fileName('phone1')] = [
      jsonEncode(rejection('a1', 'b1').toFileJson()),
      jsonEncode(rejection('a2', 'b2').toFileJson()),
    ].map((l) => '$l\n').join();
    expect(await rejections.importFiles(), 2);
    expect(await keys(), ['a1|b1', 'a2|b2']);
  });

  test('other devices\' files are read; damaged lines and other files are '
      'skipped; reading again adds nothing', () async {
    h.store.appFiles['rejections-laptop2.jsonl'] =
        '${jsonEncode(rejection('c', 'd').toFileJson())}\n'
        'not json\n'
        '{"noteA": "x"}\n';
    h.store.appFiles['notes.txt'] = jsonEncode(
      rejection('e', 'f').toFileJson(),
    );
    expect(await rejections.importFiles(), 1);
    expect(await rejections.importFiles(), 0);
    expect(await keys(), ['c|d']);
  });

  test('a pair already known keeps its word fingerprints', () async {
    final sig = Uint8List.fromList(List.filled(128, 7));
    await rejections.add(rejection('a', 'b', sig: sig));
    expect(await rejections.importFiles(), 0);
    final kept = (await rejections.all()).single;
    expect(kept.signatureA, sig);
  });

  test('a line written in the other note order reads the same pair', () {
    final r = Rejection.fromFileJson({
      'noteA': 'z',
      'hashA': 'hz',
      'noteB': 'a',
      'hashB': 'ha',
      'rejectedAt': '2026-10-08T00:00:00Z',
      'deviceId': 'p',
    })!;
    expect((r.noteA, r.hashA, r.noteB, r.hashB), ('a', 'ha', 'z', 'hz'));
  });
}
