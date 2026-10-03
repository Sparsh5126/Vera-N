import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/io_note_file_store.dart';
import 'package:vera_n/core/storage/files/note_file_store.dart';

void main() {
  late Directory root;
  late IoNoteFileStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('vera_n_store_');
    store = IoNoteFileStore(root);
  });

  tearDown(() => root.delete(recursive: true));

  test('write then read, creating subfolders', () async {
    final entry = await store.write('Ideas/a.md', 'Hello आज');
    expect(entry.path, 'Ideas/a.md');
    expect(entry.size, greaterThan(0));
    expect(await store.read('Ideas/a.md'), 'Hello आज');
    expect(await store.exists('Ideas/a.md'), isTrue);
  });

  test('overwrite replaces content and leaves no temp file', () async {
    await store.write('a.md', 'one');
    await store.write('a.md', 'two');
    expect(await store.read('a.md'), 'two');
    final names = root.listSync().map((e) => e.uri.pathSegments.last);
    expect(names, ['a.md']);
  });

  test('lists .md files in all subfolders, skipping hidden ones', () async {
    await store.write('a.md', 'a');
    await store.write('Ideas/Deep/b.md', 'b');
    await store.write('notes.txt', 'x');
    await File('${root.path}/.obsidian/c.md').create(recursive: true);
    await File('${root.path}/Ideas/.d.md').create();
    final paths = (await store.listNotes()).map((e) => e.path).toSet();
    expect(paths, {'a.md', 'Ideas/Deep/b.md'});
  });

  test('missing root lists nothing', () async {
    final gone = IoNoteFileStore(Directory('${root.path}/missing'));
    expect(await gone.listNotes(), isEmpty);
  });

  test('move and delete', () async {
    await store.write('a.md', 'a');
    await store.move('a.md', 'Archive/a.md');
    expect(await store.exists('a.md'), isFalse);
    expect(await store.read('Archive/a.md'), 'a');
    await store.delete('Archive/a.md');
    expect(await store.exists('Archive/a.md'), isFalse);
  });

  test('names with colons are fine (on systems that allow them)', () {
    expect(checkNotePath('Ideas/2:17 AM.md'), ['Ideas', '2:17 AM.md']);
  });

  test('refuses paths that escape the notes folder', () {
    for (final bad in [
      '../x.md',
      'a/../../x.md',
      '/etc/x.md',
      r'a\b.md',
      '',
      'a//b.md',
    ]) {
      expect(() => store.read(bad), throwsArgumentError, reason: bad);
    }
  });
}
