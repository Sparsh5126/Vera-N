import 'package:flutter_test/flutter_test.dart';
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

  /// A note edited in the app while its file was changed elsewhere.
  Future<int> conflicted() async {
    final ref = await h.repo.create('Plan\nOriginal text.', folder: 'Ideas');
    await h.writer.flush();
    final path = (await h.row(ref)).path;
    final file = await h.store.read(path);
    // Another app changes the file...
    await h.store.write(
      path,
      file.replaceFirst('Original text.', 'Changed outside.'),
    );
    // ...while the user is still editing here.
    await h.repo.updateBody(ref, 'Plan\nChanged in the app.');
    await h.indexer.reconcile();
    expect((await h.row(ref)).conflict, isTrue);
    return ref;
  }

  Future<String> fileText(int ref) async =>
      h.store.read((await h.row(ref)).path);

  test('a conflict keeps both versions until the user chooses', () async {
    final ref = await conflicted();
    await h.writer.flush();
    expect(await fileText(ref), contains('Changed outside.'));
    expect((await h.row(ref)).body, contains('Changed in the app.'));
    expect(await conflicts.otherVersion(ref), contains('Changed outside.'));
  });

  test('keep this version writes it; undo saves the other as a note', () async {
    final ref = await conflicted();
    final undo = await conflicts.keepThis(ref);
    await h.writer.flush();
    expect((await h.row(ref)).conflict, isFalse);
    expect(await fileText(ref), contains('Changed in the app.'));

    await undo();
    final all = await h.repo.watchNotes().first;
    expect(all, hasLength(2));
    final copy = all.firstWhere((n) => n.ref != ref);
    expect(copy.preview, contains('Changed outside.'));
    expect(copy.folder, 'Ideas');
  });

  test('keep the other version takes the file; undo puts ours back', () async {
    final ref = await conflicted();
    final undo = await conflicts.keepOther(ref);
    final row = await h.row(ref);
    expect(row.conflict, isFalse);
    expect(row.body, contains('Changed outside.'));

    await undo();
    await h.writer.flush();
    expect(await fileText(ref), contains('Changed in the app.'));
  });

  test(
    'keep both: the other version becomes a note in the same folder',
    () async {
      final ref = await conflicted();
      final copy = await conflicts.keepBoth(ref);
      await h.writer.flush();
      expect(await fileText(ref), contains('Changed in the app.'));
      final other = await h.row(copy!);
      expect(other.body, contains('Changed outside.'));
      expect(other.folder, 'Ideas');
      expect((await h.row(ref)).conflict, isFalse);
    },
  );
}
