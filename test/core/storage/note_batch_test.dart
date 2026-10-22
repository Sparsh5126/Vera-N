import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/note_batch.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late NoteBatch batch;

  setUp(() {
    h = StorageHarness();
    batch = NoteBatch(h.repo, AnalysisRepository(h.db));
  });
  tearDown(() => h.dispose());

  Future<String> folderOf(int ref) async => (await h.repo.getNote(ref))!.folder;

  test('move returns where each note was; putBack restores them', () async {
    final a = await h.repo.create('One', folder: 'Ideas');
    final b = await h.repo.create('Two');
    final old = await batch.move([a, b], 'Trips');
    expect(old, {a: 'Ideas', b: ''});
    expect([await folderOf(a), await folderOf(b)], ['Trips', 'Trips']);

    await batch.putBack(old);
    expect([await folderOf(a), await folderOf(b)], ['Ideas', '']);
  });

  test('a note already in the folder is left out of the undo', () async {
    final a = await h.repo.create('One', folder: 'Trips');
    expect(await batch.move([a], 'trips'), isEmpty);
  });

  test(
    'archive keeps each folder inside; never takes a note out of Locked',
    () async {
      final a = await h.repo.create('One', folder: 'Ideas');
      final locked = await h.repo.create('Secret', folder: 'Locked/Ideas');
      final old = await batch.archive([a, locked]);
      expect(old, {a: 'Ideas'});
      expect(await folderOf(a), 'Archive/Ideas');
      expect(await folderOf(locked), 'Locked/Ideas');
    },
  );

  test('lock keeps each folder inside Locked', () async {
    final a = await h.repo.create('One', folder: 'Ideas');
    final b = await h.repo.create('Two');
    expect(await batch.lock([a, b]), {a: 'Ideas', b: ''});
    expect([await folderOf(a), await folderOf(b)], ['Locked/Ideas', 'Locked']);
  });

  test('pin, trash and restore act on every note', () async {
    final a = await h.repo.create('One');
    final b = await h.repo.create('Two');
    await batch.pin([a, b], pinned: true);
    expect(
      (await h.repo.getNote(a))!.pinned && (await h.repo.getNote(b))!.pinned,
      isTrue,
    );

    await batch.trash([a, b]);
    expect((await h.repo.getNote(a))!.path, startsWith('.trash'));
    await batch.restore([a, b]);
    expect((await h.repo.getNote(b))!.path, isNot(startsWith('.trash')));
  });

  group('merge (user, 2026-10-22)', () {
    Future<bool> trashed(int ref) async => (await h.row(ref)).trashedAt != null;

    test('the first selected is kept; the others are added in the order '
        'selected, then go to the trash; Undo puts all back', () async {
      final first = await h.repo.create('Trip\nBoots');
      final second = await h.repo.create('Gear\nTorch\nBoots');
      final third = await h.repo.create('Food\nRice');
      final merged = await batch.merge([first, second, third]);
      expect(merged!.title, 'Trip');
      expect(
        (await h.row(first)).body,
        'Trip\nBoots\n\nGear\nTorch\n\nFood\nRice\n',
      );
      expect([await trashed(second), await trashed(third)], [true, true]);

      await merged.undo();
      expect((await h.row(first)).body, 'Trip\nBoots');
      expect([await trashed(second), await trashed(third)], [false, false]);
    });

    test('Undo never touches an edit made after the merge', () async {
      final first = await h.repo.create('Trip');
      final second = await h.repo.create('Gear');
      final merged = await batch.merge([first, second]);
      await h.repo.updateBody(first, 'Trip\nGear\nMy own line');
      await merged!.undo();
      expect((await h.row(first)).body, 'Trip\nGear\nMy own line');
      expect(await trashed(second), isFalse);
    });

    test('a locked note may only be merged into a locked note', () async {
      final open = await h.repo.create('Plain');
      final locked = await h.repo.create('Secret', folder: 'Locked');
      expect(await batch.mergeWouldUnlock([open, locked]), isTrue);
      expect(await batch.mergeWouldUnlock([locked, open]), isFalse);
    });
  });
}
