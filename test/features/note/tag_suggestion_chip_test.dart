import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/suggestion.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// A note with "#music" suggested, because "Scales" has it.
  Future<int> suggested() async {
    final s = app.storage;
    final evidence = await s.notes.create('Scales\nPiano scales daily.');
    await s.notes.setTags(evidence, ['music']);
    final note = await s.notes.create('Arpeggios\nPiano arpeggios daily.');
    await s.suggestions.add(
      [
        SuggestionDraft(
          kind: Suggestion.tagKind,
          noteA: note,
          noteB: evidence,
          tag: 'music',
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      DateTime.now(),
      const Duration(days: 30),
    );
    return note;
  }

  testWidgets('a dimmed tag chip opens the card; accepting adds the tag', (
    tester,
  ) async {
    final note = await suggested();
    await app.pump(tester);
    await tester.tap(find.text('Arpeggios'));
    await tester.pumpAndSettle();

    final chip = find.bySemanticsLabel(AppCopy.suggestedTag('music'));
    expect(chip, findsOneWidget);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.tagReason('music')), findsOneWidget);

    await tester.tap(find.byTooltip(AppCopy.accept));
    await tester.pumpAndSettle();
    expect(chip, findsNothing);
    expect((await app.storage.notes.getNote(note))!.tags, ['music']);
    await app.finish(tester);
  });

  testWidgets('the note that already has the tag shows no suggestion', (
    tester,
  ) async {
    await suggested();
    await app.pump(tester);
    await tester.tap(find.text('Scales'));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.suggestedLinks), findsNothing);
    expect(find.bySemanticsLabel(RegExp('Suggested tag')), findsNothing);
    await app.finish(tester);
  });
}
