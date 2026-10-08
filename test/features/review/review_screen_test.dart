import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/files/note_footer.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// [count] suggested pairs; returns the newer note of the first pair.
  Future<int> suggest({int count = 1, bool hintSeen = true}) async {
    int? firstNewer;
    for (var i = 0; i < count; i++) {
      final older = await app.storage.notes.create('Older $i\nEvery day.');
      final newer = await app.storage.notes.create('Newer $i\nPiano daily.');
      firstNewer ??= newer;
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
    }
    if (hintSeen) await app.storage.settings.setReviewHintSeen();
    return firstNewer!;
  }

  Future<void> openReview(WidgetTester tester) async {
    await app.pump(tester);
    await tester.tap(find.text(AppCopy.newConnections));
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('no suggestions: no card on Home', (tester) async {
    await app.storage.notes.create('Just a note');
    await app.pump(tester);
    expect(find.text(AppCopy.newConnections), findsNothing);
    await app.finish(tester);
  });

  testWidgets('Home shows no count, however many wait', (tester) async {
    await suggest(count: 7);
    await app.pump(tester);
    expect(find.text(AppCopy.newConnections), findsOneWidget);
    expect(find.textContaining('7'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('accept links the notes; Linked with Undo; Undo restores', (
    tester,
  ) async {
    final newer = await suggest();
    await openReview(tester);
    expect(find.text('Newer 0'), findsOneWidget);
    expect(find.text('Looks related to your note on Older 0.'), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Accept'));
    expect(find.text('All caught up.'), findsOneWidget);
    expect(find.text('Linked'), findsOneWidget);
    final linked = await app.storage.notes.getNote(newer);
    expect(linked!.body, contains(NoteFooter.heading));

    await tapAndSettle(tester, find.text('Undo'));
    expect(find.text('Newer 0'), findsOneWidget);
    final restored = await app.storage.notes.getNote(newer);
    expect(restored!.body, isNot(contains(NoteFooter.heading)));
    await app.finish(tester);
  });

  testWidgets('swiping left rejects; the batch ends quietly', (tester) async {
    await suggest();
    await openReview(tester);
    await tester.drag(find.text('Newer 0'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('All caught up.'), findsOneWidget);
    expect(find.textContaining('Review'), findsNothing);
    expect(await app.storage.suggestions.pending(), isEmpty);
    await app.finish(tester);
  });

  testWidgets('one batch per visit, no "more" button; the rest come on '
      'the next visit', (tester) async {
    await suggest(count: 6);
    await openReview(tester);
    for (var i = 0; i < 5; i++) {
      await tapAndSettle(tester, find.text('Not sure'));
    }
    expect(find.text('All caught up.'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(await app.storage.suggestions.pending(), hasLength(6));
    await tapAndSettle(tester, find.byTooltip(AppCopy.close));
    await tapAndSettle(tester, find.text(AppCopy.newConnections));
    expect(find.text('Newer 5'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('the gesture hint shows once', (tester) async {
    await suggest(hintSeen: false);
    await openReview(tester);
    expect(find.text('Swipe to decide'), findsOneWidget);
    await tapAndSettle(tester, find.text('Got it'));
    expect(find.text('Swipe to decide'), findsNothing);
    expect(await app.storage.settings.reviewHintSeen(), isTrue);
    await app.finish(tester);
  });

  testWidgets('tapping a note on the card opens it', (tester) async {
    await suggest();
    await openReview(tester);
    await tapAndSettle(tester, find.text('Older 0'));
    expect(find.byType(EditableText), findsOneWidget);
    await app.finish(tester);
  });
}
