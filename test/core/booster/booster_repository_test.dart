import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/booster_result.dart';
import 'package:vera_n/core/storage/repositories/booster_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late BoosterRepository booster;

  setUp(() {
    h = StorageHarness();
    booster = BoosterRepository(h.db, h.store);
  });
  tearDown(() => h.dispose());

  BoosterResult result(
    List<NoteStamp> notes,
    List<String> values, {
    BoosterKind kind = BoosterKind.why,
    String device = 'laptop1',
    int minute = 0,
  }) => BoosterResult(
    kind: kind,
    notes: notes,
    values: values,
    model: 'gemma-4',
    madeAt: DateTime.utc(2026, 10, 9, 12, minute),
    deviceId: device,
  );

  test('stamps: every live note by its id across devices, with its hash; '
      'a note without a header id is known by its path', () async {
    final a = await h.repo.create('Trek\nTriund in spring.');
    final id = await h.repo.ensureId(a);
    final b = await h.repo.create('Loose note');
    // As if the file came from another app, without a header.
    await h.db.customStatement('UPDATE notes SET note_id = NULL WHERE id = ?', [
      b,
    ]);
    final stamps = await booster.stamps();
    expect(stamps[id]!.ref, a);
    expect(stamps[id]!.hash, (await h.row(a)).contentHash);
    final pathKey = (await h.row(b)).path;
    expect(stamps[pathKey]!.ref, b);
  });

  test('results round-trip through the file; the newest per job wins; '
      'other devices\' files are read; damaged lines are skipped', () async {
    const x = NoteStamp('x', 'hx'), y = NoteStamp('y', 'hy');
    await booster.add('laptop1', [
      result([x, y], ['Old sentence.']),
    ]);
    await booster.add('laptop1', [
      result([y, x], ['Both plan a trek.'], minute: 5),
    ]);
    h.store.appFiles['laptop-other.jsonl'] =
        '{broken\n${'{"kind":"later-kind","notes":[]}'}\n';
    h.store.appFiles['rejections-laptop1.jsonl'] = 'not ours\n';
    final all = await booster.readAll();
    expect(all, hasLength(1));
    expect(all.single.values, ['Both plan a trek.']);
    expect(all.single.notes, [y, x]);
  });

  test('freshIn: a result is used only while every note is unchanged', () {
    final r = result(
      [const NoteStamp('x', 'hx'), const NoteStamp('y', 'hy')],
      ['s'],
    );
    expect(r.freshIn({'x': 'hx', 'y': 'hy'}), isTrue);
    expect(r.freshIn({'x': 'hx', 'y': 'changed'}), isFalse);
    expect(r.freshIn({'x': 'hx'}), isFalse);
  });

  test('compact keeps the newest fresh result per job, and only touches '
      'this device\'s file', () async {
    const x = NoteStamp('x', 'hx'), y = NoteStamp('y', 'hy');
    await booster.add('laptop1', [
      result([x], ['trek'], kind: BoosterKind.tags),
      result([x], ['trek', 'spring'], kind: BoosterKind.tags, minute: 1),
      result([y], [], kind: BoosterKind.tags),
    ]);
    await booster.add('laptop2', [
      result([y], [], kind: BoosterKind.tags, device: 'laptop2'),
    ]);
    // y changed since.
    expect(await booster.compact('laptop1', {'x': 'hx', 'y': 'new'}), 2);
    final mine = await booster.readAll();
    expect(mine.where((r) => r.deviceId == 'laptop1').single.values, [
      'trek',
      'spring',
    ]);
    expect(mine.where((r) => r.deviceId == 'laptop2'), hasLength(1));
    expect(await booster.compact('laptop1', {'x': 'hx'}), 0);
  });

  test('an empty result records "nothing found"', () {
    expect(result([const NoteStamp('x', 'h')], []).found, isFalse);
  });
}
