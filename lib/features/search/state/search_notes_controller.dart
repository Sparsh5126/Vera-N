import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/search_filters.dart';
import '../../../core/models/search_hit.dart';
import '../../../core/storage/storage_providers.dart';

/// What the Search screen shows.
@immutable
class SearchState {
  const SearchState({
    this.query = '',
    this.filters = const SearchFilters(),
    this.hits,
    this.recent = const [],
  });

  final String query;
  final SearchFilters filters;

  /// Null when there is nothing to search for (show recent searches).
  final List<SearchHit>? hits;
  final List<String> recent;

  /// Words typed, or a filter set: results are shown.
  bool get isSearching => query.trim().isNotEmpty || filters.isActive;

  SearchState copyWith({
    String? query,
    SearchFilters? filters,
    List<SearchHit>? Function()? hits,
    List<String>? recent,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      hits: hits == null ? this.hits : hits(),
      recent: recent ?? this.recent,
    );
  }
}

/// Runs keyword search as the user types or changes a filter. Searching
/// is local and fast, so there is no debounce and no spinner; a result
/// that arrives after a newer one is dropped.
class SearchNotesController extends Notifier<SearchState> {
  int _latest = 0;

  @override
  SearchState build() {
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
    if (!state.isSearching) {
      state = state.copyWith(hits: () => null);
      return;
    }
    final hits = await ref
        .read(searchRepositoryProvider)
        .search(state.query, filters: state.filters);
    if (run == _latest && ref.mounted) {
      state = state.copyWith(hits: () => hits);
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
