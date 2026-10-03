import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_header_codec.dart';
import 'package:vera_n/core/storage/files/note_id.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;

  setUp(() => h = StorageHarness());
  tearDown(() => h.dispose());

  group('create and edit', () {
    test('new note is in the database at once, file follows', () async {
      final ref = await h.repo.create('Future Self\nThey cause it.');
      final row = await h.row(ref);
      expect(row.title, 'Future Self');
      expect(row.pendingWrite, isTrue);
      expect(NoteId.isGenerated(row.noteId!), isTrue);
      expect(row.path, '${row.noteId}.md');
      expect(h.store.files, isEmpty);

      await h.writer.flush();
      final created = NoteHeaderCodec.formatDate(h.now);
      expect(
        h.store.text(row.path),
        '---\nid: ${row.noteId}\ncreated: $created\n---\n'
        'Future Self\nThey cause it.',
      );
      expect((await h.row(ref)).pendingWrite, isFalse);
    });

    test('notes in a folder live in that subfolder', () async {
      final ref = await h.repo.create('x', folder: 'Ideas/Story');
      final row = await h.row(ref);
      expect(row.path, startsWith('Ideas/Story/'));
      expect(row.folder, 'Ideas/Story');
    });

    test('editing updates title, hash and file; header untouched', () async {
      final ref = await h.repo.create('One');
      await h.writer.flush();
      final before = await h.row(ref);
      h.now = h.now.add(const Duration(minutes: 5));
      await h.repo.updateBody(ref, 'Two\nmore');
      await h.writer.flush();
      final after = await h.row(ref);
      expect(after.title, 'Two');
      expect(after.contentHash, isNot(before.contentHash));
      expect(after.headerRaw, before.headerRaw);
      expect(h.store.text(after.path), endsWith('---\nTwo\nmore'));
    });

    test('an edit during a file write is not lost', () async {
      final ref = await h.repo.create('One');
      final writing = h.writer.flush();
      await h.repo.updateBody(ref, 'Two');
      await writing;
      expect((await h.row(ref)).pendingWrite, isTrue);
      await h.writer.flush();
      expect(h.store.text((await h.row(ref)).path), endsWith('Two'));
    });

    test('watchNotes lists newest first and leaves trash out', () async {
      final a = await h.repo.create('A');
      h.now = h.now.add(const Duration(minutes: 1));
      final b = await h.repo.create('B');
      expect((await h.repo.watchNotes().first).map((n) => n.ref), [b, a]);
      await h.repo.trash(b);
      expect((await h.repo.watchNotes().first).map((n) => n.ref), [a]);
    });
  });

  group('headerless notes', () {
    Future<int> importNote(String path, String text) async {
      h.store.put(path, text);
      await h.indexer.reconcile();
      final rows = await h.db.select(h.db.notes).get();
      return rows.singleWhere((r) => r.path == path).id;
    }

    test('editing text adds no header', () async {
      final ref = await importNote('Keep/idea.md', 'Old idea');
      await h.repo.updateBody(ref, 'Old idea, revised');
      await h.writer.flush();
      expect(h.store.text('Keep/idea.md'), 'Old idea, revised');
      expect((await h.row(ref)).noteId, isNull);
    });

    test('first pin adds an id header; the file is not renamed', () async {
      final ref = await importNote('Keep/idea.md', 'Old idea');
      await h.repo.setPinned(ref, true);
      await h.writer.flush();
      final row = await h.row(ref);
      expect(NoteId.isGenerated(row.noteId!), isTrue);
      expect(row.path, 'Keep/idea.md');
      final text = h.store.text('Keep/idea.md')!;
      expect(text, startsWith('---\nid: ${row.noteId}\ncreated: '));
      expect(text, endsWith('pinned: true\n---\nOld idea'));
    });

    test('tags keep unknown header fields', () async {
      final ref = await importNote('a.md', '---\naliases: [Loop]\n---\nBody');
      await h.repo.setTags(ref, ['story', 'कहानी']);
      await h.writer.flush();
      final text = h.store.text('a.md')!;
      expect(text, contains('aliases: [Loop]\n'));
      expect(text, contains('tags: [story, कहानी]\n'));
      expect(await h.tags(ref), ['story', 'कहानी']);
      expect((await h.repo.getNote(ref))!.tags, ['story', 'कहानी']);
    });
  });

  test('never overwrites a file changed elsewhere', () async {
    final ref = await h.repo.create('Mine');
    await h.writer.flush();
    final path = (await h.row(ref)).path;
    h.store.put(path, 'From the laptop');
    await h.repo.updateBody(ref, 'Mine, edited');
    await h.writer.flush();
    expect(h.store.text(path), 'From the laptop');
    final row = await h.row(ref);
    expect(row.conflict, isTrue);
    expect(row.body, 'Mine, edited');
  });

  test('trash moves the file into .trash and keeps it', () async {
    final ref = await h.repo.create('Bye');
    await h.writer.flush();
    final path = (await h.row(ref)).path;
    await h.repo.trash(ref);
    expect(h.store.text(path), isNull);
    expect(h.store.text('.trash/$path'), endsWith('Bye'));
    expect((await h.row(ref)).trashedAt, isNotNull);
  });

  test('restore brings a trashed note back to its place', () async {
    final ref = await h.repo.create('Back again', folder: 'Ideas');
    await h.writer.flush();
    final path = (await h.row(ref)).path;
    await h.repo.trash(ref);
    await h.repo.restore(ref);
    final row = await h.row(ref);
    expect(row.trashedAt, isNull);
    expect(row.path, path);
    expect(row.folder, 'Ideas');
    expect(h.store.text(path), endsWith('Back again'));
    expect((await h.repo.watchNotes().first).map((n) => n.ref), [ref]);
  });

  test('restoring a note whose file is gone writes it again', () async {
    final ref = await h.repo.create('Only in the database');
    await h.writer.flush();
    await h.repo.trash(ref);
    h.store.files.clear();
    await h.repo.restore(ref);
    await h.writer.flush();
    final row = await h.row(ref);
    expect(h.store.text(row.path), endsWith('Only in the database'));
  });

  group('move to folder', () {
    test('moves the file, keeps its name, returns the old folder', () async {
      final ref = await h.repo.create('Move me');
      await h.writer.flush();
      final before = await h.row(ref);
      expect(await h.repo.moveToFolder(ref, 'Ideas/Story'), '');
      final after = await h.row(ref);
      expect(after.path, 'Ideas/Story/${before.path}');
      expect(after.folder, 'Ideas/Story');
      expect(h.store.text(before.path), isNull);
      expect(h.store.text(after.path), endsWith('Move me'));
      expect(after.fileModifiedMs, isNotNull);
    });

    test('undo moves it back', () async {
      final ref = await h.repo.create('x', folder: 'A');
      await h.writer.flush();
      final old = await h.repo.moveToFolder(ref, 'B');
      await h.repo.moveToFolder(ref, old!);
      expect((await h.row(ref)).folder, 'A');
    });

    test('a name clash gets a suffix, nothing is overwritten', () async {
      final ref = await h.repo.create('mine');
      await h.writer.flush();
      final name = (await h.row(ref)).path;
      h.store.put('B/$name', 'already there');
      await h.repo.moveToFolder(ref, 'B');
      final path = (await h.row(ref)).path;
      expect(path, isNot('B/$name'));
      expect(h.store.text('B/$name'), 'already there');
      expect(h.store.text(path), endsWith('mine'));
    });

    test('an unsaved note moves before its file exists', () async {
      final ref = await h.repo.create('not written yet');
      await h.repo.moveToFolder(ref, 'Later');
      await h.writer.flush();
      final row = await h.row(ref);
      expect(row.folder, 'Later');
      expect(h.store.text(row.path), endsWith('not written yet'));
    });

    test('the indexer does not re-read a moved file', () async {
      final ref = await h.repo.create('quiet');
      await h.writer.flush();
      await h.repo.moveToFolder(ref, 'C');
      final reads = h.store.reads;
      final report = await h.indexer.reconcile();
      expect(report.unchanged, 1);
      expect(h.store.reads, reads);
    });
  });

  test(
    'a header change that keeps a stray --- block updates the title',
    () async {
      const text = '---\njust a line\n---\nrest';
      h.store.put('a.md', text);
      await h.indexer.reconcile();
      final ref = (await h.db.select(h.db.notes).get()).single.id;
      // Indexed as a headerless note whose first line is "---".
      expect((await h.row(ref)).title, '---');
      await h.repo.setPinned(ref, true);
      final row = await h.row(ref);
      expect(row.body, text);
      expect(row.title, '---');
      expect(row.contentHash, isNotEmpty);
    },
  );
}
