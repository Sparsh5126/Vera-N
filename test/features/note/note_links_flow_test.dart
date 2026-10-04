import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/shared/widgets/note_chip.dart';
import 'package:vera_n/shared/widgets/text_link.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  Future<void> openFromHome(WidgetTester tester, String title) async {
    await tester.tap(find.text(title).first);
    await tester.pumpAndSettle();
  }

  Future<void> back(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
  }

  testWidgets('typing [[ picks a note; both notes then show the link', (
    tester,
  ) async {
    await app.storage.notes.create('Time Loop\nold idea');
    await app.pump(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();

    final editor = find.byType(TextField);
    await tester.enterText(editor, 'Future Self\nsee [');
    await tester.enterText(editor, 'Future Self\nsee [[');
    await tester.pumpAndSettle();
    expect(find.text('Link to a note…'), findsOneWidget);
    await tester.tap(find.text('Time Loop').last);
    await tester.pumpAndSettle();

    final text = tester.widget<TextField>(editor).controller!.text;
    expect(
      text,
      matches(RegExp(r'see \[\[\d{8}-\d{6}-[0-9a-f]{4}\|Time Loop\]\]$')),
    );
    await tester.pump(const Duration(seconds: 1));
    await back(tester);

    await openFromHome(tester, 'Time Loop');
    expect(find.text('Mentioned in'), findsOneWidget);
    expect(find.text('Future Self'), findsOneWidget);
    await tester.tap(find.text('Future Self'));
    await tester.pumpAndSettle();
    expect(find.text('Linked'), findsOneWidget);
    expect(find.text('Time Loop'), findsWidgets);
    await app.finish(tester);
  });

  testWidgets('backing out of the picker leaves [[ as typed', (tester) async {
    await app.storage.notes.create('Other');
    await app.pump(tester);
    await tester.tap(find.text('New note'));
    await tester.pumpAndSettle();
    final editor = find.byType(TextField);
    await tester.enterText(editor, 'x [');
    await tester.enterText(editor, 'x [[');
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Link to a note…'), findsNothing);
    expect(tester.widget<TextField>(editor).controller!.text, 'x [[');
    await app.finish(tester);
  });

  testWidgets('the editor shows only the link title', (tester) async {
    final target = await app.storage.notes.create('Time Loop');
    final name = (await app.storage.notes.getNote(target))!.path
        .replaceAll('.md', '');
    await app.storage.notes.create('Self\nsee [[$name|Time Loop]] now');
    await app.pump(tester);
    await openFromHome(tester, 'Self');

    final field = tester.widget<TextField>(find.byType(TextField));
    final span = field.controller!.buildTextSpan(
      context: tester.element(find.byType(TextField)),
      style: const TextStyle(fontSize: 16),
      withComposing: false,
    );
    final visible = StringBuffer();
    span.visitChildren((s) {
      if (s is TextSpan && (s.style?.fontSize ?? 16) > 1) {
        visible.write(s.text ?? '');
      }
      return true;
    });
    expect(visible.toString(), 'Self\nsee Time Loop now');
    await app.finish(tester);
  });

  testWidgets('tags are chips; linked and mentioning notes are text links', (
    tester,
  ) async {
    final target = await app.storage.notes.create('Time Loop');
    await app.storage.notes.setTags(target, ['story']);
    final name = (await app.storage.notes.getNote(target))!.path
        .replaceAll('.md', '');
    // A different label, so Home has only one "Time Loop" to tap.
    await app.storage.notes.create('Self\n[[$name|the loop]]');
    await app.pump(tester);
    await openFromHome(tester, 'Time Loop');

    expect(find.widgetWithText(NoteChip, '#story'), findsOneWidget);
    expect(find.widgetWithText(TextLink, 'Self'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextLink, 'Self'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextLink, 'Time Loop'), findsOneWidget);
    expect(find.widgetWithText(NoteChip, 'Time Loop'), findsNothing);
    await app.finish(tester);
  });
}
