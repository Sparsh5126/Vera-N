import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/features/note/widgets/format_bar.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// A new note with [text] typed, the editor focused.
  Future<TextEditingController> typeNote(
    WidgetTester tester,
    String text,
  ) async {
    await app.pump(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
    return tester.widget<TextField>(find.byType(TextField)).controller!;
  }

  Future<void> select(
    WidgetTester tester,
    TextEditingController c,
    int start,
    int end,
  ) async {
    c.selection = TextSelection(baseOffset: start, extentOffset: end);
    await tester.pump();
  }

  testWidgets('hidden until text is selected', (tester) async {
    final c = await typeNote(tester, 'Title\na big idea');
    expect(find.byType(FormatBar), findsNothing);
    await select(tester, c, 8, 11);
    expect(find.byType(FormatBar), findsOneWidget);
    await select(tester, c, 9, 9);
    expect(find.byType(FormatBar), findsNothing);
    await app.finish(tester);
  });

  testWidgets('bold, then list, change the text and are saved', (tester) async {
    final c = await typeNote(tester, 'Title\na big idea\nmilk');
    await select(tester, c, 8, 11);
    await tester.tap(find.byTooltip('Bold'));
    await tester.pump();
    expect(c.text, 'Title\na **big** idea\nmilk');

    await select(tester, c, 6, c.text.length);
    await tester.tap(find.byTooltip('Checklist'));
    await tester.pump(const Duration(seconds: 1));
    expect(c.text, 'Title\n- [ ] a **big** idea\n- [ ] milk');

    final saved = await app.storage.notes.allNotes();
    final note = await app.storage.notes.getNote(saved.single.ref);
    expect(note!.body, c.text);
    await app.finish(tester);
  });

  testWidgets('link turns the selected words into a link', (tester) async {
    await app.storage.notes.create('Time Loop');
    final c = await typeNote(tester, 'Self\nsee that idea');
    await select(tester, c, 9, 18);
    await tester.tap(find.byTooltip('Link to a note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Time Loop').last);
    await tester.pumpAndSettle();
    expect(
      c.text,
      matches(RegExp(r'^Self\nsee \[\[[0-9a-f-]+\|that idea\]\]$')),
    );
    await app.finish(tester);
  });
}
