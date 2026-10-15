import 'dart:ui' show TextRange;

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/search_filters.dart';
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

  test(
    'the snippet starts at the line that matched, so the card shows it',
    () async {
      await h.repo.create(
        'Grocery list\n\n- milk\n- bread\n- दाल और चावल\n- salt',
      );
      final snippet = (await search.search('दाल')).single.snippet;
      expect(snippet.text, startsWith('• दाल'));
      expect(
        snippet.text.substring(
          snippet.matches.single.start,
          snippet.matches.single.end,
        ),
        'दाल',
      );
    },
  );

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

  group('filters', () {
    Future<List<int>> filtered(String q, SearchFilters f) async =>
        (await search.search(
          q,
          filters: f,
          now: h.now,
        )).map((hit) => hit.ref).toList();

    test('folder includes its subfolders, any letter case', () async {
      final a = await h.repo.create('a', folder: 'Ideas');
      final b = await h.repo.create('b', folder: 'Ideas/Story');
      await h.repo.create('c', folder: 'Ideasx');
      await h.repo.create('d');
      final f = const SearchFilters(folder: 'ideas');
      expect((await filtered('', f)).toSet(), {a, b});
    });

    test('tag, any letter case', () async {
      final a = await h.repo.create('tagged');
      await h.repo.setTags(a, ['Story']);
      await h.repo.create('plain');
      expect(await filtered('', const SearchFilters(tag: 'story')), [a]);
    });

    test('date counts whole local days back from today', () async {
      final old = await h.repo.create('old');
      h.now = h.now.add(const Duration(days: 10));
      final recent = await h.repo.create('recent');
      expect(
        await filtered('', const SearchFilters(date: DateFilter.last7Days)),
        [recent],
      );
      expect(
        (await filtered(
          '',
          const SearchFilters(date: DateFilter.thisYear),
        )).toSet(),
        {old, recent},
      );
      expect(
        DateFilter.last7Days.startFrom(DateTime(2026, 10, 3, 18)),
        DateTime(2026, 9, 27),
      );
    });

    test('no words: matching notes newest first, with a preview', () async {
      final a = await h.repo.create('First\nbody a', folder: 'X');
      h.now = h.now.add(const Duration(minutes: 1));
      final b = await h.repo.create('Second\nbody b', folder: 'X');
      final hits = await search.search(
        '',
        filters: const SearchFilters(folder: 'X'),
      );
      expect(hits.map((x) => x.ref), [b, a]);
      expect(hits.first.title.text, 'Second');
      expect(hits.first.snippet.text, 'body b');
      expect(hits.first.snippet.matches, isEmpty);
    });

    test('words and filters together', () async {
      final a = await h.repo.create('loop one', folder: 'X');
      await h.repo.create('loop two', folder: 'Y');
      expect(await filtered('loop', const SearchFilters(folder: 'X')), [a]);
    });

    test('no words and no filters: nothing', () async {
      await h.repo.create('a');
      expect(await filtered('', const SearchFilters()), isEmpty);
    });

    test('folder and tag lists for the pickers', () async {
      await h.repo.create('a', folder: 'Ideas/Story');
      await h.repo.create('b', folder: 'Archive');
      final t = await h.repo.create('c');
      await h.repo.setTags(t, ['story', 'Idea']);
      final gone = await h.repo.create('d');
      await h.repo.setTags(gone, ['trashed-only']);
      await h.repo.trash(gone);
      expect(await search.folders(), ['Archive', 'Ideas', 'Ideas/Story']);
      expect(await search.tags(), ['Idea', 'story']);
    });
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
