import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/styles/app_styles.dart';
import 'package:vera_n/shared/widgets/note_chip.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// Opens the note from Home; it opens showing text, not typing.
  Future<int> openNote(WidgetTester tester, String body) async {
    final ref = await app.storage.notes.create(body);
    await app.pump(tester);
    await tester.tap(find.text(body.split('\n').first));
    await tester.pumpAndSettle();
    return ref;
  }

  Future<void> addTag(WidgetTester tester, String name) async {
    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, name);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('add a tag by typing; it shows as a solid chip', (tester) async {
    final ref = await openNote(tester, 'Time Loop');
    await addTag(tester, '#time loop');
    expect(find.text('#time-loop'), findsOneWidget);
    expect(tester.widget<NoteChip>(find.byType(NoteChip)).dimmed, isFalse);
    expect((await app.storage.notes.getNote(ref))!.tags, ['time-loop']);
    await app.finish(tester);
  });

  testWidgets('existing tags are offered first', (tester) async {
    final other = await app.storage.notes.create('Other');
    await app.storage.notes.setTags(other, ['story']);
    final ref = await openNote(tester, 'Time Loop');
    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('#story'));
    await tester.pumpAndSettle();
    expect((await app.storage.notes.getNote(ref))!.tags, ['story']);
    await app.finish(tester);
  });

  testWidgets('remove a tag, then undo', (tester) async {
    final ref = await openNote(tester, 'Tagged');
    await addTag(tester, 'idea');
    await tester.tap(find.text('#idea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove #idea'));
    await tester.pumpAndSettle();
    expect(find.text('#idea'), findsNothing);
    expect(find.text('Tag removed'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await app.storage.notes.getNote(ref))!.tags, ['idea']);
    await app.finish(tester);
  });

  testWidgets('move to a new folder, then undo', (tester) async {
    final ref = await openNote(tester, 'Wanderer');
    await tester.tap(find.text('Add to folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ideas / Story');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect((await app.storage.notes.getNote(ref))!.folder, 'Ideas/Story');
    expect(find.text('Moved to Ideas/Story'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await app.storage.notes.getNote(ref))!.folder, '');
    await app.finish(tester);
  });

  testWidgets('a new note has nothing to move or tag until it has text', (
    tester,
  ) async {
    await app.pump(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    expect(find.text('Add tag'), findsNothing);
    expect(find.text('Add to folder'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('the ⋮ menu has no Move to folder (it is below the text)', (
    tester,
  ) async {
    await openNote(tester, 'Wanderer');
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Move to folder'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('folder shows below the text like a tag; tap to move', (
    tester,
  ) async {
    final ref = await openNote(tester, 'Wanderer');
    expect(find.text('Add to folder'), findsOneWidget);
    await tester.tap(find.text('Add to folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ideas');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Folder'), findsOneWidget);
    expect(find.widgetWithText(NoteChip, 'Ideas'), findsOneWidget);
    expect(find.text('Add to folder'), findsNothing);
    expect((await app.storage.notes.getNote(ref))!.folder, 'Ideas');
    await app.finish(tester);
  });

  testWidgets('long titles never overflow a chip', (tester) async {
    final long = 'A very long first line that keeps going and going on';
    await openNote(tester, long);
    await tester.tap(find.text('Add to folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, long);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await app.finish(tester);
  });

  testWidgets('the Undo popup goes away on its own', (tester) async {
    await openNote(tester, 'Tagged');
    await addTag(tester, 'idea');
    await tester.tap(find.text('#idea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove #idea'));
    await tester.pumpAndSettle();
    expect(find.text('Tag removed'), findsOneWidget);
    await tester.pump(AppMotion.undoWindow + const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Tag removed'), findsNothing);
    await app.finish(tester);
  });
}
