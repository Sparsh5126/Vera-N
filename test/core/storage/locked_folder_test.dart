import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/scheduler/analysis_run.dart';
import 'package:vera_n/core/models/locked_folder.dart';
import 'package:vera_n/core/models/search_filters.dart';
import 'package:vera_n/core/storage/repositories/links_repository.dart';
import 'package:vera_n/core/storage/repositories/search_repository.dart';

import '../../support/app_harness.dart';
import '../../support/fake_embedder.dart';

void main() {
  late AppHarness app;
  setUp(() => app = AppHarness());
  tearDown(() async {
    app.storage.writer.dispose();
    await app.storage.db.close();
  });

  Future<void> analyse() => AnalysisRun(
    analysis: app.storage.analysis,
    suggestions: app.storage.suggestions,
    embedder: FakeEmbedder(),
    clock: DateTime.now,
    stopRequested: () => false,
  ).run();

  test('folder rule: into, out of, contains', () {
    expect(LockedFolder.into('Ideas'), 'Locked/Ideas');
    expect(LockedFolder.outOf('locked/Ideas'), 'Ideas');
    expect(LockedFolder.contains('Lockedness'), isFalse);
  });

  test('locked notes leave Home, folders, tags and search; the Locked '
      'folder itself still lists them', () async {
    final notes = app.storage.notes;
    final open = await notes.create('Open\nShared plans.');
    await notes.setTags(open, ['trip']);
    final secret = await notes.create('Diary\nPrivate words here.');
    await notes.setTags(secret, ['feelings']);
    await notes.moveToFolder(secret, LockedFolder.into('Personal'));

    final home = await notes.watchNotes().first;
    expect(home.map((n) => n.title), ['Open']);
    final inLocked = await notes
        .watchNotes(filters: SearchFilters(folder: LockedFolder.name))
        .first;
    expect(inLocked.map((n) => n.ref), [secret]);

    final search = SearchRepository(app.storage.db);
    expect(await search.folders(), isEmpty);
    expect(await search.tags(), ['trip']);
    final found = await search.search('private');
    expect(found, isEmpty);
    expect(await notes.watchHasLocked().first, isTrue);
    expect((await notes.allNotes()).map((n) => n.title), ['Open']);
  });

  test('the AI forgets a locked note and never reads it again', () async {
    final notes = app.storage.notes;
    final a = await notes.create(
      'Trip ideas\nvisit the hills by train in the spring season',
    );
    await notes.create(
      'Spring plan\nvisit the hills by train in the spring season soon',
    );
    await analyse();
    expect(await app.storage.suggestions.pending(), isNotEmpty);
    expect(await app.storage.analysis.chunksOf(a, 'fake@1'), isNotEmpty);

    await notes.moveToFolder(a, LockedFolder.into(''));
    // As if moved by another app: the next run forgets it.
    await analyse();
    expect(await app.storage.analysis.chunksOf(a, 'fake@1'), isEmpty);
    expect(await app.storage.suggestions.pending(), isEmpty);
    final stale = await app.storage.analysis.stale('fake@1', limit: 9);
    expect(stale.map((n) => n.ref), isNot(contains(a)));
  });

  test('links to a locked note show only from a locked note', () async {
    final notes = app.storage.notes;
    final links = LinksRepository(app.storage.db);
    final secret = await notes.create('Secret\nHidden.');
    await notes.moveToFolder(secret, LockedFolder.into(''));
    final name = (await notes.getNote(secret))!.path.split('/').last;
    final target = name.replaceAll('.md', '');
    final open = await notes.create('Open\nSee [[$target]].');
    final buddy = await notes.create('Buddy\nAlso [[$target]].');
    await notes.moveToFolder(buddy, LockedFolder.into(''));

    expect(await links.watchLinked(open).first, isEmpty);
    expect((await links.watchLinked(buddy).first).single.ref, secret);
    // A locked note may list the open notes that link to it.
    final mentions = await links.watchMentionedIn(secret).first;
    expect(mentions.map((m) => m.ref).toSet(), {open, buddy});
    // An open note never lists a locked one that links to it.
    final back = await notes.create('Back\nNothing.');
    final backName = (await notes.getNote(back))!.path.split('/').last;
    await notes.updateBody(
      buddy,
      'Buddy\nAlso [[$target]] and [[${backName.replaceAll('.md', '')}]].',
    );
    expect(await links.watchMentionedIn(back).first, isEmpty);
  });

  test('the trash shows a locked note without its words', () async {
    final notes = app.storage.notes;
    final secret = await notes.create('Diary\nPrivate.');
    await notes.moveToFolder(secret, LockedFolder.into(''));
    await notes.trash(secret);
    final trashed = (await app.storage.trash.watch().first).single;
    expect((trashed.locked, trashed.title, trashed.preview), (true, '', ''));
  });
}
