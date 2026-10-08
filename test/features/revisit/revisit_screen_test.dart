import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/suggestion.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// An old note offered to revisit because of a recent one.
  Future<void> offer() async {
    final old = await app.storage.notes.create('Trip ideas\nThe hills.');
    final recent = await app.storage.notes.create('Spring plan\nBy train.');
    await app.storage.suggestions.add(
      [
        SuggestionDraft(
          kind: Suggestion.resurfaceKind,
          noteA: old,
          noteB: recent,
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      DateTime.now(),
      const Duration(days: 30),
    );
  }

  Future<void> openRevisit(WidgetTester tester) async {
    await app.pump(tester);
    await tester.tap(find.text(AppCopy.revisit));
    await tester.pumpAndSettle();
  }

  testWidgets('nothing to revisit: no Revisit card on Home', (tester) async {
    await app.pump(tester);
    expect(find.text(AppCopy.revisit), findsNothing);
    await app.finish(tester);
  });

  testWidgets('Revisit shows the old note and why; it is no connection', (
    tester,
  ) async {
    await offer();
    await openRevisit(tester);
    expect(find.text('Trip ideas'), findsOneWidget);
    expect(find.text(AppCopy.relatedToRecent('Spring plan')), findsOneWidget);
    expect(find.text(AppCopy.newConnections), findsNothing);
    await app.finish(tester);
  });

  testWidgets('Not now hides it, with Undo', (tester) async {
    await offer();
    await openRevisit(tester);
    await tester.tap(find.text(AppCopy.notNow));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.nothingToRevisit), findsOneWidget);
    await tester.tap(find.text(AppCopy.undo));
    await tester.pumpAndSettle();
    expect(find.text('Trip ideas'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('one at a time; Open opens the note and counts as revisited', (
    tester,
  ) async {
    await offer();
    await offer();
    await openRevisit(tester);
    expect(find.text('Trip ideas'), findsOneWidget);
    await tester.tap(find.text(AppCopy.open));
    await tester.pumpAndSettle();
    final left = await tester.runAsync(
      () => app.storage.suggestions.watchRevisit(limit: 5).first,
    );
    expect(left, hasLength(1));
    await app.finish(tester);
  });
}
