import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/files/note_footer.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// An older and a newer note, suggested as a pair. Returns their refs.
  Future<(int, int)> pair() async {
    final older = await app.storage.notes.create('Time loop\nEvery day.');
    final newer = await app.storage.notes.create('Piano\nPractice daily.');
    await app.storage.suggestions.add(
      [
        SuggestionDraft(
          kind: 'link',
          noteA: older,
          noteB: newer,
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      DateTime.now(),
      const Duration(days: 30),
    );
    return (older, newer);
  }

  Future<void> openNote(WidgetTester tester, String title) async {
    await app.pump(tester);
    await tester.tap(find.text(title).first);
    await tester.pumpAndSettle();
  }

  Future<void> tapChip(WidgetTester tester, String title) async {
    await tester.tap(find.bySemanticsLabel('Suggested link: $title'));
    await tester.pumpAndSettle();
  }

  testWidgets('Home cards of both notes show the dot', (tester) async {
    await pair();
    await app.pump(tester);
    expect(find.bySemanticsLabel(RegExp('Has suggestions')), findsNWidgets(2));
    await app.finish(tester);
  });

  testWidgets('accept in the open note adds the link to its text', (
    tester,
  ) async {
    final (_, newer) = await pair();
    await openNote(tester, 'Piano');
    expect(find.text('Suggested links'), findsOneWidget);

    await tapChip(tester, 'Time loop');
    expect(
      find.text('Looks related to your note on Time loop.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Accept'));
    await tester.pumpAndSettle();

    expect(find.text('Suggested links'), findsNothing);
    expect(find.text('Linked'), findsWidgets);
    final body = (await app.storage.notes.getNote(newer))!.body;
    expect(body, contains(NoteFooter.heading));
    // The editor shows the saved text, so the next save keeps the link.
    final editor = tester.widget<EditableText>(find.byType(EditableText));
    expect(editor.controller.text, body);
    await app.finish(tester);
  });

  testWidgets('closing the sheet keeps the chip, as not sure', (tester) async {
    await pair();
    await openNote(tester, 'Time loop');
    await tapChip(tester, 'Piano');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Suggested links'), findsOneWidget);
    final pending = await app.storage.suggestions.pending();
    expect(pending.single.notSure, isTrue);
    await app.finish(tester);
  });

  testWidgets('reject removes the chip; Undo brings it back', (tester) async {
    await pair();
    await openNote(tester, 'Time loop');
    await tapChip(tester, 'Piano');
    await tester.tap(find.byTooltip('Reject'));
    await tester.pumpAndSettle();
    expect(find.text('Suggested links'), findsNothing);
    expect(find.text('Not linked'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Suggested links'), findsOneWidget);
    await app.finish(tester);
  });
}
