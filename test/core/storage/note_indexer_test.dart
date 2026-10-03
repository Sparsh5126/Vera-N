import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/db/app_database.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;

  setUp(() => h = StorageHarness());
  tearDown(() => h.dispose());

  Future<List<NoteRow>> rows() => h.db.select(h.db.notes).get();

  Future<NoteRow> rowAt(String path) async =>
      (await rows()).singleWhere((r) => r.path == path);

  test('indexes every note, with and without a header', () async {
    h.store.put(
      'a.md',
      '---\nid: 20261003-153228-a7f3\ncreated: 2026-01-02T10:00:00+05:30\n'
          'tags: [story]\npinned: true\n---\nFuture Self\n',
    );
    h.store.put('Ideas/b.md', 'Imported\nfrom Keep');
    h.store.put('Ideas/notes.txt', 'not a note');
    h.store.put('.obsidian/c.md', 'hidden');

    final report = await h.indexer.reconcile();
    expect(report.added, 2);

    final a = await rowAt('a.md');
    expect(a.noteId, '20261003-153228-a7f3');
    expect(a.title, 'Future Self');
    expect(a.pinned, isTrue);
    expect(a.created, DateTime.utc(2026, 1, 2, 4, 30).toLocal());
    expect(await h.tags(a.id), ['story']);

    final b = await rowAt('Ideas/b.md');
    expect(b.noteId, isNull);
    expect(b.folder, 'Ideas');
    expect(b.headerRaw, isNull);
    expect(b.created, h.store.files['Ideas/b.md']!.modified);
  });

  test('unchanged files are not read again', () async {
    h.store.put('a.md', 'A');
    h.store.put('b.md', 'B');
    await h.indexer.reconcile();
    final readsBefore = h.store.reads;
    final report = await h.indexer.reconcile();
    expect(report.unchanged, 2);
    expect(h.store.reads, readsBefore);
  });

  test('outside edits update the note', () async {
    h.store.put('a.md', 'First');
    await h.indexer.reconcile();
    h.store.put('a.md', 'Second');
    final report = await h.indexer.reconcile();
    expect(report.updated, 1);
    expect((await rowAt('a.md')).title, 'Second');
  });

  test('outside move keeps the note, matched by header id', () async {
    h.store.put('a.md', '---\nid: n1\n---\nText');
    await h.indexer.reconcile();
    final ref = (await rowAt('a.md')).id;
    h.store.move('a.md', 'Archive/a.md');
    h.store.put('Archive/a.md', '---\nid: n1\n---\nText, edited');
    final report = await h.indexer.reconcile();
    expect(report.moved, 1);
    final moved = await rowAt('Archive/a.md');
    expect(moved.id, ref);
    expect(moved.title, 'Text, edited');
  });

  test('outside rename of a headerless note: matched by content', () async {
    h.store.put('old name.md', 'Same words');
    await h.indexer.reconcile();
    final before = await rowAt('old name.md');
    await h.store.move('old name.md', 'Ideas/new name.md');
    final report = await h.indexer.reconcile();
    expect(report.moved, 1);
    final after = await rowAt('Ideas/new name.md');
    expect(after.id, before.id);
    expect(after.created, before.created);
    expect(await rows(), hasLength(1));
  });

  test('a rename that only changes letter case is the same note', () async {
    h.store.put('Ideas/Loop.md', 'Loop');
    await h.indexer.reconcile();
    final ref = (await rowAt('Ideas/Loop.md')).id;
    await h.store.move('Ideas/Loop.md', 'ideas/loop.md');
    await h.indexer.reconcile();
    final row = await rowAt('ideas/loop.md');
    expect(row.id, ref);
    expect(row.folder, 'ideas');
  });

  test('deleted files leave the index; unsaved notes stay', () async {
    h.store.put('a.md', 'A');
    await h.indexer.reconcile();
    final unsaved = await h.repo.create('Not written yet');
    await h.store.delete('a.md');
    final report = await h.indexer.reconcile();
    expect(report.removed, 1);
    expect((await rows()).map((r) => r.id), [unsaved]);
  });

  test(
    'outside edit during an unsaved edit: conflict, our text kept',
    () async {
      final ref = await h.repo.create('Mine');
      await h.writer.flush();
      final path = (await h.row(ref)).path;
      await h.repo.updateBody(ref, 'Mine, edited');
      h.store.put(path, 'From the laptop');
      final report = await h.indexer.reconcile();
      expect(report.conflicts, 1);
      final row = await h.row(ref);
      expect(row.conflict, isTrue);
      expect(row.body, 'Mine, edited');
    },
  );
}
