import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/features/note/widgets/checkbox_glyph.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  Future<void> openFromHome(WidgetTester tester, String title) async {
    await tester.tap(find.text(title).first);
    await tester.pumpAndSettle();
  }

  TextEditingController editor(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!;

  testWidgets('a checklist shows checkboxes that tick and are saved', (
    tester,
  ) async {
    final ref = await app.storage.notes.create('Groceries\n- [ ] milk');
    await app.pump(tester);
    await openFromHome(tester, 'Groceries');

    expect(find.byType(CheckboxGlyph), findsOneWidget);
    await tester.tap(find.byType(CheckboxGlyph));
    await tester.pump(const Duration(seconds: 2));
    expect(editor(tester).text, 'Groceries\n- [x] milk');
    expect(
      (await app.storage.notes.getNote(ref))!.body,
      'Groceries\n- [x] milk',
    );
    expect(
      tester.widget<CheckboxGlyph>(find.byType(CheckboxGlyph)).checked,
      isTrue,
    );
    await app.finish(tester);
  });

  testWidgets('bold words are drawn bold without the stars', (tester) async {
    await app.storage.notes.create('Plan\na **big** idea');
    await app.pump(tester);
    await openFromHome(tester, 'Plan');

    final span = editor(tester).buildTextSpan(
      context: tester.element(find.byType(TextField)),
      style: const TextStyle(fontSize: 16),
      withComposing: false,
    );
    TextSpan? big;
    final visible = StringBuffer();
    span.visitChildren((s) {
      if (s is TextSpan && (s.style?.fontSize ?? 16) > 1) {
        visible.write(s.text ?? '');
        if (s.text == 'big') big = s;
      }
      return true;
    });
    expect(visible.toString(), 'Plan\na big idea');
    expect(big!.style!.fontWeight, FontWeight.w700);
    await app.finish(tester);
  });

  testWidgets('tapping a link title opens the linked note', (tester) async {
    final loop = await app.storage.notes.create('Time Loop\nthe loop note');
    final name = (await app.storage.notes.getNote(loop))!.path
        .replaceAll('.md', '');
    await app.storage.notes.create('Self\nsee [[$name|Time Loop]] now');
    await app.pump(tester);
    await openFromHome(tester, 'Self');

    // Put the cursor inside "Time Loop" as a tap would, then report the tap.
    final c = editor(tester);
    final inside = c.text.indexOf('Loop]]') - 2;
    c.selection = TextSelection.collapsed(offset: inside);
    tester.widget<TextField>(find.byType(TextField)).onTap!();
    await tester.pumpAndSettle();

    expect(editor(tester).text, 'Time Loop\nthe loop note');
    await app.finish(tester);
  });

  testWidgets('Home cards show checkboxes and bullets as symbols', (
    tester,
  ) async {
    await app.storage.notes.create('Groceries\n- [ ] milk\n- [x] eggs\n- note');
    await app.pump(tester);
    // Glyphs the app's font has (□ / ✓), never the color-emoji ☑️.
    expect(find.text('□ milk\n✓ eggs\n• note'), findsOneWidget);
    await app.finish(tester);
  });
}
