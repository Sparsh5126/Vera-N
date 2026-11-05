import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/suggestion.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/storage_harness.dart';

/// "Not sure" rests before Review shows it again (user, 2026-11-05: it
/// came back at once). The rest is compared with the database's clock, so
/// these use real times.
void main() {
  late StorageHarness h;
  late SuggestionsRepository suggestions;
  late Suggestion waiting;

  setUp(() async {
    h = StorageHarness();
    suggestions = SuggestionsRepository(h.db);
    final a = await h.repo.create('One');
    final b = await h.repo.create('Two');
    await suggestions.add(
      [
        SuggestionDraft(
          kind: Suggestion.linkKind,
          noteA: a,
          noteB: b,
          score: .7,
          chunkA: 0,
          chunkB: 0,
        ),
      ],
      h.now,
      const Duration(days: 30),
    );
    waiting = (await suggestions.pending()).single;
  });
  tearDown(() => h.dispose());

  test(
    'while resting it leaves Review and the Home card, not the note',
    () async {
      final later = DateTime.now().add(const Duration(days: 3));
      await suggestions.setNotSure(waiting.id, notSure: true, until: later);

      expect(await suggestions.batch(size: 5), isEmpty);
      expect(await suggestions.reviewable(), isEmpty);
      expect(await suggestions.watchCount().first, 0);
      final kept = (await suggestions.pending()).single;
      expect(kept.notSure, isTrue);
      expect(await suggestions.watchFor(waiting.noteA).first, hasLength(1));
    },
  );

  test('after the rest it is back in Review', () async {
    final past = DateTime.now().subtract(const Duration(minutes: 1));
    await suggestions.setNotSure(waiting.id, notSure: true, until: past);

    expect((await suggestions.batch(size: 5)).single.notSure, isTrue);
    expect(await suggestions.watchCount().first, 1);
  });

  test('undo (fresh again) clears the rest; put back keeps it', () async {
    final later = DateTime.now().add(const Duration(days: 3));
    await suggestions.setNotSure(waiting.id, notSure: true, until: later);
    final resting = (await suggestions.pending()).single;
    expect(resting.returnsAt, isNotNull);

    await suggestions.remove(resting.id);
    await suggestions.putBack(resting);
    expect(await suggestions.batch(size: 5), isEmpty);

    await suggestions.setNotSure(waiting.id, notSure: false);
    final back = (await suggestions.batch(size: 5)).single;
    expect(back.notSure, isFalse);
    expect(back.returnsAt, isNull);
  });
}
