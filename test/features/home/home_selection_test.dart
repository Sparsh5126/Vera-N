import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';

import '../../support/app_harness.dart';
import '../../support/haptics_spy.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  Future<void> hold(WidgetTester tester, String title) async {
    await tester.longPress(find.text(title).first);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  testWidgets('holding selects; taps add and remove; ✕ stops', (tester) async {
    await app.storage.notes.create('First');
    await app.storage.notes.create('Second');
    await app.pump(tester);

    await hold(tester, 'First');
    expect(find.text('1 selected'), findsOneWidget);
    // The card reads out its date, "Selected", then its text.
    expect(
      find.bySemanticsLabel(RegExp(HomeCopy.selectedNote)),
      findsOneWidget,
    );
    expect(find.text(AppCopy.newNote), findsNothing);

    await tapText(tester, 'Second');
    expect(find.text('2 selected'), findsOneWidget);
    await tapText(tester, 'First');
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byTooltip(HomeCopy.stopSelecting));
    await tester.pumpAndSettle();
    expect(find.textContaining('selected'), findsNothing);
    expect(find.text(AppCopy.newNote), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets("a screen reader's long press on the card selects it", (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await app.storage.notes.create('First');
    await app.pump(tester);
    final card = tester.getSemantics(find.text('First'));
    expect(
      card.getSemanticsData().hasAction(SemanticsAction.longPress),
      isTrue,
    );
    card.owner!.performAction(card.id, SemanticsAction.longPress);
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    semantics.dispose();
    await app.finish(tester);
  });

  testWidgets('selecting ticks: once for the hold, once per tap after', (
    tester,
  ) async {
    final spy = HapticsSpy()..attach(tester);
    await app.storage.notes.create('First');
    await app.storage.notes.create('Second');
    await app.pump(tester);
    await hold(tester, 'First');
    expect(spy.played, [HapticsSpy.selectionClick]);
    await tapText(tester, 'Second');
    await tapText(tester, 'Second');
    expect(spy.played, List.filled(3, HapticsSpy.selectionClick));
    await app.finish(tester);
  });

  testWidgets('a selected card has an ink wash behind it', (tester) async {
    await app.storage.notes.create('First');
    await app.storage.notes.create('Second');
    await app.pump(tester);
    Color? cardColor(String title) => tester
        .widget<Card>(
          find.ancestor(of: find.text(title), matching: find.byType(Card)),
        )
        .color;
    expect(cardColor('First'), isNull);
    await hold(tester, 'First');
    expect(cardColor('First'), isNotNull);
    expect(cardColor('Second'), isNull);
    await app.finish(tester);
  });

  testWidgets('while selecting, a tap selects instead of opening', (
    tester,
  ) async {
    await app.storage.notes.create('First');
    await app.storage.notes.create('Second');
    await app.pump(tester);
    await hold(tester, 'First');
    await tapText(tester, 'Second');
    expect(find.text('2 selected'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    await app.finish(tester);
  });

  testWidgets("the phone's back gesture stops selecting", (tester) async {
    await app.storage.notes.create('First');
    await app.pump(tester);
    await hold(tester, 'First');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.textContaining('selected'), findsNothing);
    expect(find.text('First'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Delete: both notes leave; one Undo brings both back', (
    tester,
  ) async {
    final a = await app.storage.notes.create('Old thought');
    final b = await app.storage.notes.create('Older thought');
    await app.storage.notes.create('Keep me');
    await app.pump(tester);

    await hold(tester, 'Old thought');
    await tapText(tester, 'Older thought');
    await tapText(tester, AppCopy.delete);
    expect(find.text('Old thought'), findsNothing);
    expect(find.text('Older thought'), findsNothing);
    expect(find.text('Keep me'), findsOneWidget);
    expect(find.text('2 notes moved to trash'), findsOneWidget);

    await tapText(tester, 'Undo');
    expect(find.text('Old thought'), findsOneWidget);
    expect(find.text('Older thought'), findsOneWidget);
    for (final ref in [a, b]) {
      expect(
        (await app.storage.notes.getNote(ref))!.path,
        isNot(startsWith('.trash')),
      );
    }
    await app.finish(tester);
  });

  testWidgets('Folder: both move; one Undo puts both back', (tester) async {
    await app.storage.notes.create('Plan', folder: 'Ideas');
    final a = await app.storage.notes.create('Loose one');
    final b = await app.storage.notes.create('Loose two');
    await app.pump(tester);

    await hold(tester, 'Loose one');
    await tapText(tester, 'Loose two');
    await tapText(tester, HomeCopy.actionFolder);
    await tapText(tester, 'Ideas');
    expect(find.text('2 notes moved to Ideas'), findsOneWidget);
    for (final ref in [a, b]) {
      expect((await app.storage.notes.getNote(ref))!.folder, 'Ideas');
    }

    await tapText(tester, 'Undo');
    for (final ref in [a, b]) {
      expect((await app.storage.notes.getNote(ref))!.folder, '');
    }
    await app.finish(tester);
  });

  testWidgets('Archive and Lock take notes off Home, with Undo', (
    tester,
  ) async {
    final a = await app.storage.notes.create('To archive');
    final b = await app.storage.notes.create('To lock');
    await app.pump(tester);

    await hold(tester, 'To archive');
    await tapText(tester, HomeCopy.actionArchive);
    expect(find.text('To archive'), findsNothing);
    expect(find.text(AppCopy.archived), findsOneWidget);
    expect((await app.storage.notes.getNote(a))!.folder, 'Archive');

    await hold(tester, 'To lock');
    await tapText(tester, HomeCopy.actionLock);
    expect(find.text('To lock'), findsNothing);
    expect(find.text(AppCopy.movedToLocked), findsOneWidget);
    expect((await app.storage.notes.getNote(b))!.folder, 'Locked');
    await tapText(tester, 'Undo');
    expect(find.text('To lock'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Lock without a screen lock says so and moves nothing', (
    tester,
  ) async {
    app.lock.screenLock = false;
    final a = await app.storage.notes.create('Secret');
    await app.pump(tester);
    await hold(tester, 'Secret');
    await tapText(tester, HomeCopy.actionLock);
    expect(find.text(AppCopy.needScreenLock), findsOneWidget);
    expect((await app.storage.notes.getNote(a))!.folder, '');
    await app.finish(tester);
  });

  testWidgets('Pin pins them all; with all pinned it offers Unpin', (
    tester,
  ) async {
    final a = await app.storage.notes.create('Important');
    final b = await app.storage.notes.create('Also important');
    await app.pump(tester);

    await hold(tester, 'Important');
    await tapText(tester, 'Also important');
    await tapText(tester, AppCopy.pin);
    expect(find.text('Pinned'), findsOneWidget);
    for (final ref in [a, b]) {
      expect((await app.storage.notes.getNote(ref))!.pinned, isTrue);
    }

    await hold(tester, 'Important');
    expect(find.text(AppCopy.unpin), findsOneWidget);
    await app.finish(tester);
  });
}
