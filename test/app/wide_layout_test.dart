import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/features/home/home_screen.dart';
import 'package:vera_n/features/note/note_screen.dart';
import 'package:vera_n/features/search/search_screen.dart';
import 'package:vera_n/shared/widgets/pill_nav_bar.dart';
import 'package:vera_n/shared/widgets/side_nav.dart';

import '../support/app_harness.dart';

void main() {
  late AppHarness app;
  setUp(() => app = AppHarness());

  Future<void> wide(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await app.pump(tester);
  }

  Future<void> ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
  }

  testWidgets('a wide window: the sidebar, and a note opens beside the '
      'list; Back closes it there', (tester) async {
    await app.storage.notes.create('Groceries\nMilk and eggs.');
    await wide(tester);
    expect(find.byType(SideNav), findsOneWidget);
    expect(find.byType(PillNavBar), findsNothing);
    expect(find.text(AppCopy.pickANote), findsOneWidget);

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NoteScreen), findsOneWidget);

    await tester.tap(find.byTooltip(AppCopy.back));
    await tester.pumpAndSettle();
    expect(find.byType(NoteScreen), findsNothing);
    expect(find.text(AppCopy.pickANote), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Ctrl+N starts a note beside the list; Ctrl+F goes to Search', (
    tester,
  ) async {
    await wide(tester);
    await ctrl(tester, LogicalKeyboardKey.keyN);
    expect(find.byType(NoteScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(find.text(AppCopy.navSearch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppCopy.navHome));
    await tester.pumpAndSettle();
    await ctrl(tester, LogicalKeyboardKey.keyF);
    expect(find.byType(SearchScreen), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Ctrl+N works while typing in an open note', (tester) async {
    await app.storage.notes.create('Groceries\nMilk and eggs.');
    await wide(tester);
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Milk and eggs.').last);
    await tester.pumpAndSettle();
    await ctrl(tester, LogicalKeyboardKey.keyN);
    expect(find.textContaining('Milk and eggs.'), findsOneWidget);
    expect(find.byType(NoteScreen), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('right-click on a card offers what a long press offers', (
    tester,
  ) async {
    await app.storage.notes.create('Groceries\nMilk and eggs.');
    await wide(tester);
    await tester.tap(find.text('Groceries'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.delete), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Review by keyboard: Ctrl+Enter links the pair', (tester) async {
    final a = await app.storage.notes.create('Piano\nPractice daily.');
    final b = await app.storage.notes.create('Scales\nEvery morning.');
    await app.storage.suggestions.add(
      [
        SuggestionDraft(
          kind: 'link',
          noteA: a,
          noteB: b,
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      DateTime.now(),
      const Duration(days: 30),
    );
    await app.storage.settings.setReviewHintSeen();
    await wide(tester);
    await tester.tap(find.text(AppCopy.newConnections));
    await tester.pumpAndSettle();
    await ctrl(tester, LogicalKeyboardKey.enter);
    expect(find.text(AppCopy.linked), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('a phone-sized window keeps the pill bar', (tester) async {
    await app.pump(tester);
    expect(find.byType(PillNavBar), findsOneWidget);
    expect(find.byType(SideNav), findsNothing);
    await app.finish(tester);
  });
}
