import 'dart:ui' show TextRange;

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/search_hit.dart';
import 'package:vera_n/core/storage/repositories/search_repository.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late SearchRepository search;

  setUp(() {
    h = StorageHarness();
    search = SearchRepository(h.db);
  });
  tearDown(() => h.dispose());

  Future<List<int>> refs(String q) async =>
      (await search.search(q)).map((hit) => hit.ref).toList();

  test('prefix match on each word, Hindi and English', () async {
    final a = await h.repo.create('आज की बात\nmessages at night');
    final b = await h.repo.create('कहानी\nmessages cause it');
    expect((await refs('mess')).toSet(), {a, b});
    expect(await refs('कहा'), [b]);
    expect(await refs('mess night'), [a]);
  });

  test('follows edits and trash; odd input is safe', () async {
    final a = await h.repo.create('alpha');
    await h.repo.updateBody(a, 'beta');
    expect(await refs('alpha'), isEmpty);
    expect(await refs('beta'), [a]);
    await h.repo.trash(a);
    expect(await refs('beta'), isEmpty);
    expect(await refs('  '), isEmpty);
    expect(await refs('"a" OR (b* NEAR'), isEmpty);
  });

  test('results carry the matched words for highlighting', () async {
    await h.repo.create('Future Self\nMaybe the messages are causing it.');
    final hit = (await search.search('mess')).single;
    expect(hit.title.text, 'Future Self');
    expect(hit.title.matches, isEmpty);
    final snippet = hit.snippet;
    expect(snippet.text, contains('messages'));
    final match = snippet.matches.single;
    expect(snippet.text.substring(match.start, match.end), 'messages');
  });

  test('title matches are marked too', () async {
    await h.repo.create('Time Loop\nnothing else');
    final title = (await search.search('loop')).single.title;
    expect(title.text.substring(title.matches.single.start), 'Loop');
  });

  test('marked text parsing', () {
    final m = MarkedText.parse('a ${searchMatchStart}bc$searchMatchEnd d');
    expect(m.text, 'a bc d');
    expect(m.matches.single, const TextRange(start: 2, end: 4));
  });

  group('recent searches', () {
    late SettingsRepository settings;
    setUp(() => settings = SettingsRepository(h.db));

    test('newest first, no duplicates, capped', () async {
      await settings.addRecentSearch('commute');
      await settings.addRecentSearch('loop');
      await settings.addRecentSearch(' Commute ');
      expect(await settings.recentSearches(), ['Commute', 'loop']);
      for (var i = 0; i < 20; i++) {
        await settings.addRecentSearch('q$i');
      }
      expect(
        await settings.recentSearches(),
        hasLength(SettingsRepository.recentSearchLimit),
      );
    });

    test('can be removed one by one', () async {
      await settings.addRecentSearch('a');
      await settings.addRecentSearch('b');
      await settings.removeRecentSearch('a');
      expect(await settings.recentSearches(), ['b']);
    });
  });
}
