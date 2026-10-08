import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/locked_folder.dart';
import 'package:vera_n/core/security/locked_session.dart';
import 'package:vera_n/features/note/note_screen.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;
  setUp(() => app = AppHarness());

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> lockFromMenu(WidgetTester tester, String title) async {
    await tapAndSettle(tester, find.text(title));
    await tapAndSettle(tester, find.byTooltip(AppCopy.moreOptions));
    await tapAndSettle(tester, find.text(AppCopy.moveToLocked));
  }

  testWidgets('locking leaves the note; Home hides it; the Locked pill '
      'opens with the phone lock; Lock now closes it', (tester) async {
    await app.storage.notes.create('Diary\nPrivate words.');
    await app.pump(tester);
    await lockFromMenu(tester, 'Diary');
    expect(find.text(AppCopy.movedToLocked), findsOneWidget);
    expect(find.text('Diary'), findsNothing);
    final row = (await tester.runAsync(app.storage.notes.allNotes))!;
    expect(row, isEmpty);

    await tapAndSettle(tester, find.text('Folders'));
    expect(app.lock.prompts, 0);
    await tapAndSettle(tester, find.text(AppCopy.lockedFolder));
    expect(app.lock.prompts, 1);
    expect(find.text('Diary'), findsOneWidget);

    await tapAndSettle(tester, find.text(AppCopy.lockNow));
    expect(find.text('Diary'), findsNothing);
    expect(find.text(AppCopy.lockedFolderHint), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('without a screen lock nothing is locked', (tester) async {
    app.lock.screenLock = false;
    await app.storage.notes.create('Diary\nPrivate words.');
    await app.pump(tester);
    await lockFromMenu(tester, 'Diary');
    expect(find.text(AppCopy.needScreenLock), findsOneWidget);
    final note = (await tester.runAsync(app.storage.notes.allNotes))!.single;
    expect(LockedFolder.contains(note.folder), isFalse);
    await app.finish(tester);
  });

  testWidgets('a locked note shows the lock when the folder closes', (
    tester,
  ) async {
    final ref = await app.storage.notes.create('Diary\nPrivate words.');
    await app.storage.notes.moveToFolder(ref, LockedFolder.into(''));
    await app.pump(tester);
    await tapAndSettle(tester, find.text('Folders'));
    await tapAndSettle(tester, find.text(AppCopy.lockedFolder));
    await tapAndSettle(tester, find.text('Diary'));
    expect(find.byType(TextField), findsOneWidget);

    ProviderScope.containerOf(tester.element(find.byType(NoteScreen)))
        .read(lockedSessionProvider.notifier)
        .close();
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.lockedNoteHint), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tapAndSettle(tester, find.text(AppCopy.unlock));
    expect(find.byType(TextField), findsOneWidget);
    await app.finish(tester);
  });
}
