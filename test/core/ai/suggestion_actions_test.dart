import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/suggestions/suggestion_actions.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/files/note_footer.dart';
import 'package:vera_n/core/storage/repositories/links_repository.dart';
import 'package:vera_n/core/storage/repositories/rejections_repository.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late SuggestionsRepository suggestions;
  late LinksRepository links;
  late SuggestionActions actions;

  setUp(() {
    h = StorageHarness();
    suggestions = SuggestionsRepository(h.db);
    links = LinksRepository(h.db);
    actions = SuggestionActions(
      notes: h.repo,
      links: links,
      suggestions: suggestions,
      rejections: RejectionsRepository(h.db, h.store),
      settings: SettingsRepository(h.db),
      clock: () => h.now,
    );
  });
  tearDown(() => h.dispose());

  /// Two notes, the second created a day later, suggested as a pair.
  Future<(int, int)> pair() async {
    final older = await h.repo.create('Time loop\nEvery day repeats.');
    h.now = h.now.add(const Duration(days: 1));
    final newer = await h.repo.create('Piano\nPractice daily.');
    await suggestions.add(
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
      h.now,
      const Duration(days: 30),
    );
    return (older, newer);
  }

  test('accept: the newer note links to the older in its footer', () async {
    final (older, newer) = await pair();
    final s = (await suggestions.pending()).single;
    final body = (await h.row(newer)).body;

    final undo = await actions.accept(s);

    final linked = (await h.row(newer)).body;
    expect(linked, startsWith(body.trimRight()));
    expect(linked, contains('${NoteFooter.heading}\n- [['));
    expect(await links.findNote(_target(linked)), older);
    expect(await suggestions.pending(), isEmpty);

    await undo();
    expect((await h.row(newer)).body, body);
    expect(await suggestions.pending(), hasLength(1));
  });

  test(
    'accept and reject count toward the link bar; undo takes it back',
    () async {
      final settings = SettingsRepository(h.db);
      await pair();
      final undo = await actions.accept((await suggestions.pending()).single);
      expect((await settings.learning('link')).recent, [true]);
      await undo();
      expect((await settings.learning('link')).recent, isEmpty);
      await actions.reject((await suggestions.pending()).single);
      expect((await settings.learning('link')).recent, [false]);
    },
  );

  test('undoing an accept never removes words typed since', () async {
    final (_, newer) = await pair();
    final undo = await actions.accept((await suggestions.pending()).single);
    final edited = '${(await h.row(newer)).body}My own words.';
    await h.repo.updateBody(newer, edited);
    await undo();
    expect((await h.row(newer)).body, edited);
  });

  test(
    'reject: stored with ids and hashes; the file has no note text',
    () async {
      final (older, newer) = await pair();
      final undo = await actions.reject((await suggestions.pending()).single);

      expect((await h.row(older)).noteId, isNotNull);
      final rows = await h.db.select(h.db.rejections).get();
      expect(rows.single.signatureA, isNotNull);
      final file = h.store.appFiles.values.single;
      final line = jsonDecode(file.trim()) as Map<String, dynamic>;
      expect(
        line.keys,
        unorderedEquals([
          'pairKey',
          'noteA',
          'hashA',
          'noteB',
          'hashB',
          'rejectedAt',
          'deviceId',
        ]),
      );
      expect(file, isNot(contains('Piano')));
      expect(file, isNot(contains('Time loop')));
      expect(await suggestions.pending(), isEmpty);
      expect((await h.row(newer)).body, isNot(contains('[[')));

      await undo();
      expect(await h.db.select(h.db.rejections).get(), isEmpty);
      expect(h.store.appFiles.values.single, isEmpty);
      expect(await suggestions.pending(), hasLength(1));
    },
  );

  test('not sure keeps it; batches show fresh ones first', () async {
    await pair();
    final first = (await suggestions.pending()).single;
    final a = await h.repo.create('Third note here.');
    final b = await h.repo.create('Fourth note here.');
    await suggestions.add(
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
      h.now,
      const Duration(days: 30),
    );

    final undo = await actions.notSure(first);
    final batch = await suggestions.batch(size: 5);
    expect(batch.map((s) => s.noteA), [a, first.noteA]);
    expect(batch.last.notSure, isTrue);

    await undo();
    expect((await suggestions.batch(size: 5)).first.id, first.id);
  });

  test('pairs with a note in the trash are not shown', () async {
    final (_, newer) = await pair();
    await h.repo.trash(newer);
    expect(await suggestions.batch(size: 5), isEmpty);
  });
}

/// The link target written in the footer's last line.
String _target(String body) {
  final m = RegExp(r'\[\[([^|\]]+)').allMatches(body).last;
  return m.group(1)!;
}
