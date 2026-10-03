import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/search_hit.dart';
import '../../../core/storage/storage_providers.dart';

/// What the Search screen shows.
@immutable
class SearchState {
  const SearchState({this.query = '', this.hits, this.recent = const []});

  final String query;

  /// Null before anything was searched (show recent searches instead).
  final List<SearchHit>? hits;
  final List<String> recent;

  bool get hasQuery => query.trim().isNotEmpty;

  SearchState copyWith({
    String? query,
    List<SearchHit>? Function()? hits,
    List<String>? recent,
  }) {
    return SearchState(
      query: query ?? this.query,
      hits: hits == null ? this.hits : hits(),
      recent: recent ?? this.recent,
    );
  }
}

/// Runs keyword search as the user types. Searching is local and fast, so
/// there is no debounce and no spinner; a result that arrives after a
/// newer query is dropped.
class SearchNotesController extends Notifier<SearchState> {
  int _latest = 0;

  @override
  SearchState build() {
    unawaited(_loadRecent());
    return const SearchState();
  }

  Future<void> setQuery(String query) async {
    final run = ++_latest;
    state = state.copyWith(query: query);
    if (query.trim().isEmpty) {
      state = state.copyWith(hits: () => null);
      return;
    }
    final hits = await ref.read(searchRepositoryProvider).search(query);
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
