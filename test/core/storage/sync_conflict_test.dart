import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/sync_conflict.dart';
import 'package:vera_n/core/storage/repositories/conflict_resolver.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late ConflictResolver conflicts;

  setUp(() {
    h = StorageHarness();
    conflicts = ConflictResolver(h.db, h.store, h.writer, h.indexer, h.repo);
  });
  tearDown(() => h.dispose());

  const copyName = 'Ideas/plan.sync-conflict-20261009-101500-ABCDEF1.md';

  test('the name rule', () {
    expect(SyncConflict.isCopy(copyName), isTrue);
    expect(SyncConflict.originalOf(copyName), 'Ideas/plan.md');
    expect(SyncConflict.isCopy('Ideas/plan.md'), isFalse);
    expect(SyncConflict.isCopy('Ideas/sync-conflict notes.md'), isFalse);
  });

  /// "plan.md" as one device kept it, and Syncthing's copy of the other.
  Future<int> synced() async {
    h.store.put('Ideas/plan.md', 'Plan\nKept on the laptop.');
    h.store.put(copyName, 'Plan\nWritten on the phone.');
    await h.indexer.reconcile();
    final notes = await h.repo.allNotes();
    expect(notes, hasLength(1), reason: 'the copy is not a note of its own');
    final ref = notes.single.ref;
    expect((await h.row(ref)).conflict, isTrue);
    expect(await conflicts.otherVersion(ref), contains('Written on the phone'));
    return ref;
  }

  test('keep the other: its text wins and the copy goes', () async {
    final ref = await synced();
    await conflicts.keepOther(ref);
    await h.writer.flush();
    expect((await h.row(ref)).body, contains('Written on the phone'));
    expect((await h.row(ref)).conflict, isFalse);
    expect(h.store.text(copyName), isNull);
    expect(h.store.text('Ideas/plan.md'), contains('Written on the phone'));
  });

  test('keep both: the copy becomes a note of its own', () async {
    final ref = await synced();
    final other = await conflicts.keepBoth(ref);
    await h.writer.flush();
    expect((await h.row(other!)).body, contains('Written on the phone'));
    expect((await h.row(ref)).body, contains('Kept on the laptop'));
    expect((await h.row(ref)).conflict, isFalse);
    expect(h.store.text(copyName), isNull);
  });

  test(
    'keep this: the copy goes; undo brings its text back as a note',
    () async {
      final ref = await synced();
      final undo = await conflicts.keepThis(ref);
      await h.writer.flush();
      expect(h.store.text(copyName), isNull);
      expect((await h.row(ref)).conflict, isFalse);
      await undo();
      final bodies = [for (final n in await h.repo.allNotes()) n.title];
      expect(bodies, hasLength(2));
    },
  );

  test('a copy whose note is gone is kept as a note', () async {
    h.store.put(copyName, 'Plan\nOnly here.');
    await h.indexer.reconcile();
    final notes = await h.repo.allNotes();
    expect(notes.single.title, 'Plan');
  });
}
