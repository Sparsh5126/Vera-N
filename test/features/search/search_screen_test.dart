import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/shared/widgets/highlighted_text.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  Future<void> openSearch(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
  }

  Future<void> typeQuery(WidgetTester tester, String q) async {
    await tester.enterText(find.byType(TextField), q);
    await tester.pumpAndSettle();
  }

  testWidgets('the Search tab opens with the keyboard ready', (tester) async {
    await app.pump(tester);
    await openSearch(tester);
    final editor = tester.widget<EditableText>(find.byType(EditableText));
    expect(editor.focusNode.hasFocus, isTrue);
    expect(find.text('Search notes…'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('finds notes as you type and highlights the match', (
    tester,
  ) async {
    await app.storage.notes.create('Future Self\nThe messages cause it.');
    await app.storage.notes.create('Groceries\nmilk');
    await app.pump(tester);
    await openSearch(tester);

    await typeQuery(tester, 'mess');
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Future Self', findRichText: true), findsOneWidget);
    expect(find.text('Groceries', findRichText: true), findsNothing);
    final snippet = tester
        .widgetList<HighlightedText>(find.byType(HighlightedText))
        .firstWhere((t) => t.matches.isNotEmpty);
    final m = snippet.matches.single;
    expect(snippet.text.substring(m.start, m.end), 'messages');
    await app.finish(tester);
  });

  testWidgets('no match shows a quiet message', (tester) async {
    await app.storage.notes.create('Something');
    await app.pump(tester);
    await openSearch(tester);
    await typeQuery(tester, 'zebra');
    expect(find.text('No notes found.'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('opening a result remembers the search', (tester) async {
    await app.storage.notes.create('Time Loop\nagain');
    await app.pump(tester);
    await openSearch(tester);
    await typeQuery(tester, 'loop');
    await tester.tap(find.text('Time Loop', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await typeQuery(tester, '');
    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.text('loop'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Recent searches'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('back from Search goes Home', (tester) async {
    await app.pump(tester);
    await openSearch(tester);
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(find.text('Write your first thought.'), findsOneWidget);
    await app.finish(tester);
  });
}
