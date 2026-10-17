import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/styles/app_styles.dart';
import 'package:vera_n/features/home/widgets/folder_drop_tray.dart';

import '../../support/app_harness.dart';
import '../../support/haptics_spy.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// Holds [title]'s card and starts moving it: the tray shows.
  Future<TestGesture> lift(WidgetTester tester, String title) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(title).first),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, 30));
    // The tray's folder list arrives from the database a frame or two later.
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    return gesture;
  }

  Finder chip(String label) => find.descendant(
    of: find.byType(FolderDropTray),
    matching: find.text(label),
  );

  Future<String> folderOf(int ref) async =>
      (await app.storage.notes.getNote(ref))!.folder;

  testWidgets('holding without moving selects; the tray never shows', (
    tester,
  ) async {
    await app.storage.notes.create('Loose');
    await app.pump(tester);
    await tester.longPress(find.text('Loose'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text(HomeCopy.dropOnFolder), findsNothing);
    await app.finish(tester);
  });

  testWidgets('dropping on a folder chip moves the note, with Undo', (
    tester,
  ) async {
    await app.storage.notes.create('Plan', folder: 'Ideas');
    final a = await app.storage.notes.create('Loose');
    await app.pump(tester);

    final gesture = await lift(tester, 'Loose');
    expect(find.text(HomeCopy.dropOnFolder), findsOneWidget);
    await gesture.moveTo(tester.getCenter(chip('Ideas')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(await folderOf(a), 'Ideas');
    expect(find.text(AppCopy.movedTo('Ideas')), findsOneWidget);
    expect(find.text(HomeCopy.dropOnFolder), findsNothing);
    await app.finish(tester);
  });

  testWidgets('resting on a chip opens the folder; dropping inside moves it', (
    tester,
  ) async {
    await app.storage.notes.create('Plan', folder: 'Ideas');
    final a = await app.storage.notes.create('Loose');
    await app.pump(tester);

    final gesture = await lift(tester, 'Loose');
    await gesture.moveTo(tester.getCenter(chip('Ideas')));
    await tester.pump(AppMotion.springOpen + const Duration(milliseconds: 50));
    await tester.pump();
    // Home now shows the folder under the finger.
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text(HomeCopy.dropInto('Ideas')), findsOneWidget);

    await gesture.moveTo(tester.getCenter(find.text('Plan')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(await folderOf(a), 'Ideas');
    expect(find.text('Loose'), findsOneWidget);
    // The held card left the screen when the folder opened; the tray must
    // still go when the finger lifts (found on the phone, 2026-10-17).
    expect(find.text(HomeCopy.dropOnFolder), findsNothing);
    expect(find.text(HomeCopy.dropInto('Ideas')), findsNothing);
    await app.finish(tester);
  });

  testWidgets('dragging a selected note carries every selected note', (
    tester,
  ) async {
    await app.storage.notes.create('Plan', folder: 'Ideas');
    final a = await app.storage.notes.create('Loose one');
    final b = await app.storage.notes.create('Loose two');
    await app.pump(tester);
    await tester.longPress(find.text('Loose one'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Loose two'));
    await tester.pumpAndSettle();

    final gesture = await lift(tester, 'Loose two');
    expect(find.text('2'), findsOneWidget);
    await gesture.moveTo(tester.getCenter(chip('Ideas')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect([await folderOf(a), await folderOf(b)], ['Ideas', 'Ideas']);
    expect(find.text('2 notes moved to Ideas'), findsOneWidget);
    expect(find.textContaining('selected'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('a drag ticks once, as the hold registers', (tester) async {
    final spy = HapticsSpy()..attach(tester);
    await app.storage.notes.create('Plan', folder: 'Ideas');
    await app.storage.notes.create('Loose');
    await app.pump(tester);
    final gesture = await lift(tester, 'Loose');
    await gesture.moveTo(tester.getCenter(chip('Ideas')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(spy.played, [HapticsSpy.selectionClick]);
    await app.finish(tester);
  });

  testWidgets('dropping on Locked locks the note', (tester) async {
    final a = await app.storage.notes.create('Secret');
    await app.pump(tester);
    final gesture = await lift(tester, 'Secret');
    await gesture.moveTo(tester.getCenter(chip(AppCopy.lockedFolder)));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(await folderOf(a), 'Locked');
    expect(find.text('Secret'), findsNothing);
    await app.finish(tester);
  });
}
