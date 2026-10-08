import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/archive_folder.dart';
import 'package:vera_n/core/models/search_filters.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/repositories/search_repository.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  test('folder rule: into, out of, contains', () {
    expect(ArchiveFolder.into('Ideas/Story'), 'Archive/Ideas/Story');
    expect(ArchiveFolder.into(''), 'Archive');
    expect(ArchiveFolder.outOf('Archive/Ideas/Story'), 'Ideas/Story');
    expect(ArchiveFolder.outOf('archive'), '');
    expect(ArchiveFolder.contains('ARCHIVE/x'), isTrue);
    expect(ArchiveFolder.contains('Archives'), isFalse);
  });

  test('archived notes leave Home, analysis and suggestions; Search and '
      'the Archive folder still find them', () async {
    final s = app.storage;
    final kept = await s.notes.create('Kept\nStill here today.');
    final old = await s.notes.create('Old plan\nPlans for the trip.');
    await s.suggestions.add(
      [
        SuggestionDraft(
          kind: 'link',
          noteA: kept,
          noteB: old,
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      DateTime.now(),
      const Duration(days: 30),
    );
    await s.notes.moveToFolder(old, ArchiveFolder.into(''));

    final home = await s.notes.watchNotes().first;
    expect(home.map((n) => n.ref), [kept]);
    final archive = await s.notes
        .watchNotes(filters: const SearchFilters(folder: 'Archive'))
        .first;
    expect(archive.map((n) => n.ref), [old]);
    final hits = await SearchRepository(s.db).search('trip');
    expect(hits.map((h) => h.ref), [old]);
    expect(await s.suggestions.pending(), isEmpty);
    final stale = await s.analysis.stale('m', limit: 10);
    expect(stale.map((n) => n.ref), [kept]);
    await s.db.close();
  });

  test(
    'archiving keeps the folder inside Archive/; unarchive restores it',
    () async {
      final s = app.storage;
      final ref = await s.notes.create('Trip\nPack.', folder: 'Plans');
      await s.notes.moveToFolder(ref, ArchiveFolder.into('Plans'));
      final archived = (await s.notes.getNote(ref))!;
      expect(archived.folder, 'Archive/Plans');
      expect(archived.path, startsWith('Archive/Plans/'));
      await s.notes.moveToFolder(ref, ArchiveFolder.outOf(archived.folder));
      expect((await s.notes.getNote(ref))!.folder, 'Plans');
      s.writer.dispose();
      await s.db.close();
    },
  );

  testWidgets('Archive from the menu leaves the note; Undo brings it back', (
    tester,
  ) async {
    await app.storage.notes.create('Trip\nPack on Friday.', folder: 'Plans');
    await app.pump(tester);
    await tester.tap(find.text('Trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(AppCopy.moreOptions));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppCopy.archive));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.archived), findsOneWidget);
    expect(find.text('Trip'), findsNothing);

    await tester.tap(find.text(AppCopy.undo));
    await tester.pumpAndSettle();
    expect(find.text('Trip'), findsOneWidget);

    await app.finish(tester);
  });
}
