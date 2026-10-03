import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/repositories/links_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late LinksRepository links;

  setUp(() {
    h = StorageHarness();
    links = LinksRepository(h.db);
  });
  tearDown(() => h.dispose());

  Future<String> nameOf(int ref) async {
    final path = (await h.row(ref)).path;
    return path.split('/').last.replaceAll('.md', '');
  }

  Future<List<String>> linkedTitles(int ref) async =>
      (await links.watchLinked(ref).first).map((n) => n.title).toList();

  Future<List<String>> mentionTitles(int ref) async =>
      (await links.watchMentionedIn(ref).first).map((n) => n.title).toList();

  test('links by file name show both ways, in text order', () async {
    final loop = await h.repo.create('Time Loop');
    final cause = await h.repo.create('Causality');
    final self = await h.repo.create(
      'Future Self\n[[${await nameOf(cause)}]] then '
      '[[${await nameOf(loop)}|the loop]]',
    );
    expect(await linkedTitles(self), ['Causality', 'Time Loop']);
    expect(await mentionTitles(loop), ['Future Self']);
    expect(await mentionTitles(self), isEmpty);
  });

  test('editing the text updates links', () async {
    final a = await h.repo.create('A');
    final b = await h.repo.create('B');
    await h.repo.updateBody(b, 'B\n[[${await nameOf(a)}]]');
    expect(await mentionTitles(a), ['B']);
    await h.repo.updateBody(b, 'B\nno more link');
    expect(await mentionTitles(a), isEmpty);
  });

  test('links to missing or trashed notes are not shown', () async {
    final a = await h.repo.create('A');
    final b = await h.repo.create('B\n[[nowhere]] [[${await nameOf(a)}]]');
    expect(await linkedTitles(b), ['A']);
    await h.repo.trash(a);
    expect(await linkedTitles(b), isEmpty);
    await h.repo.restore(a);
    expect(await linkedTitles(b), ['A']);
  });

  test('links written in other apps are indexed, path links too', () async {
    h.store.put('Ideas/Old Note.md', 'Old');
    h.store.put('linker.md', 'See [[Ideas/old note]] and [[OLD NOTE.md]]');
    await h.indexer.reconcile();
    final rows = await h.db.select(h.db.notes).get();
    final old = rows.singleWhere((r) => r.path == 'Ideas/Old Note.md').id;
    // Titles show links as text, as readers see them.
    expect(await mentionTitles(old), ['See Ideas/old note and OLD NOTE.md']);
  });

  test('moving a note keeps links by name working', () async {
    final a = await h.repo.create('A');
    final b = await h.repo.create('B\n[[${await nameOf(a)}]]');
    await h.repo.moveToFolder(a, 'Elsewhere');
    expect(await linkedTitles(b), ['A']);
  });

  test('link text: name and title; folder path when names clash', () async {
    final a = await h.repo.create('Time Loop');
    expect(await links.linkTextFor(a), '[[${await nameOf(a)}|Time Loop]]');

    h.store.put('X/idea.md', 'Idea one');
    h.store.put('Y/idea.md', 'Idea two');
    await h.indexer.reconcile();
    final rows = await h.db.select(h.db.notes).get();
    final x = rows.singleWhere((r) => r.path == 'X/idea.md').id;
    expect(await links.linkTextFor(x), '[[X/idea|Idea one]]');
  });
}
