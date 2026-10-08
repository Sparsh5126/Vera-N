import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_settings.dart';
import '../../../core/ai/search/meaning_search.dart';
import '../../../core/ai/search/meaning_search_provider.dart';
import '../../../core/models/search_filters.dart';
import '../../../core/models/search_hit.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/storage/storage_providers.dart';

/// What the Search screen shows.
@immutable
class SearchState {
  const SearchState({
    this.query = '',
    this.filters = const SearchFilters(),
    this.hits,
    this.similar = const [],
    this.recent = const [],
  });

  final String query;
  final SearchFilters filters;

  /// Null when there is nothing to search for (show recent searches).
  final List<SearchHit>? hits;

  /// "Similar in meaning": notes close in meaning that the keywords
  /// missed, filled in a moment after [hits] (UI spec §9).
  final List<SearchHit> similar;
  final List<String> recent;

  /// Words typed, or a filter set: results are shown.
  bool get isSearching => query.trim().isNotEmpty || filters.isActive;

  SearchState copyWith({
    String? query,
    SearchFilters? filters,
    List<SearchHit>? Function()? hits,
    List<SearchHit>? similar,
    List<String>? recent,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      hits: hits == null ? this.hits : hits(),
      similar: similar ?? this.similar,
      recent: recent ?? this.recent,
    );
  }
}

/// Runs keyword search as the user types or changes a filter. Searching
/// is local and fast, so there is no debounce and no spinner; a result
/// that arrives after a newer one is dropped. Meaning search follows a
/// moment after the typing pauses, only while suggestions are on.
class SearchNotesController extends Notifier<SearchState> {
  int _latest = 0;
  Timer? _similarSoon;
  late MeaningSearch _meaning;

  @override
  SearchState build() {
    _meaning = ref.watch(meaningSearchProvider);
    ref.onDispose(() => _similarSoon?.cancel());
    unawaited(_loadRecent());
    return const SearchState();
  }

  Future<void> setQuery(String query) {
    state = state.copyWith(query: query);
    return _run();
  }

  Future<void> setFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
    return _run();
  }

  /// Folders to offer in the Folder filter.
  Future<List<String>> folders() =>
      ref.read(searchRepositoryProvider).folders();

  /// Tags to offer in the Tag filter.
  Future<List<String>> tags() => ref.read(searchRepositoryProvider).tags();

  Future<void> _run() async {
    final run = ++_latest;
    _similarSoon?.cancel();
    if (!state.isSearching) {
      state = state.copyWith(hits: () => null, similar: const []);
      return;
    }
    final hits = await ref
        .read(searchRepositoryProvider)
        .search(state.query, filters: state.filters);
    if (run == _latest && ref.mounted) {
      state = state.copyWith(hits: () => hits, similar: const []);
      _similarSoon = Timer(AiSettings.similarDelay, () {
        unawaited(_findSimilar(run, {for (final h in hits) h.ref}));
      });
    }
  }

  Future<void> _findSimilar(int run, Set<int> keywordHits) async {
    if (state.query.trim().isEmpty || !ref.read(suggestionsOnProvider)) {
      return;
    }
    try {
      final similar = await _meaning.search(
        state.query,
        filters: state.filters,
        exclude: keywordHits,
      );
      if (run == _latest && ref.mounted) {
        state = state.copyWith(similar: similar);
      }
    } on Object catch (e) {
      // The model may be missing or fail to load; keywords still work.
      debugPrint('VeraN meaning search failed: $e');
    }
  }

  /// Keeps [query] in recent searches (when the user opens a result or
  /// presses search on the keyboard).
  Future<void> remember(String query) async {
    await ref.read(settingsRepositoryProvider).addRecentSearch(query);
    await _loadRecent();
  }

  Future<void> forget(String query) async {
    await ref.read(settingsRepositoryProvider).removeRecentSearch(query);
    await _loadRecent();
  }

  Future<void> _loadRecent() async {
    final recent = await ref.read(settingsRepositoryProvider).recentSearches();
    if (ref.mounted) state = state.copyWith(recent: recent);
  }
}

final searchNotesProvider =
    NotifierProvider.autoDispose<SearchNotesController, SearchState>(
      SearchNotesController.new,
    );
