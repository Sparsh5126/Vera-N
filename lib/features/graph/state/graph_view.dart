import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/search_filters.dart';

/// The user's choices on the Graph, kept while the app runs.
@immutable
class GraphViewState {
  const GraphViewState({
    this.showUnlinked = false,
    this.showSuggestions = false,
    this.filters = const SearchFilters(),
    this.selected,
    this.focus,
    this.hops = 1,
    this.centerRequest = 0,
  });

  /// Notes with no links are hidden by default (UI spec §10).
  final bool showUnlinked;

  /// Dimmed dashed lines for waiting suggestions; off by default.
  final bool showSuggestions;

  /// Folder and Tag filters (the Date filter isn't used here).
  final SearchFilters filters;

  /// The dot whose preview card is open.
  final int? selected;

  /// Focus: only this note and its neighbours up to [hops] links away.
  final int? focus;
  final int hops;

  /// Goes up each time the graph should centre on [selected].
  final int centerRequest;

  GraphViewState copyWith({
    bool? showUnlinked,
    bool? showSuggestions,
    SearchFilters? filters,
    ValueGetter<int?>? selected,
    ValueGetter<int?>? focus,
    int? hops,
    int? centerRequest,
  }) {
    return GraphViewState(
      showUnlinked: showUnlinked ?? this.showUnlinked,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      filters: filters ?? this.filters,
      selected: selected == null ? this.selected : selected(),
      focus: focus == null ? this.focus : focus(),
      hops: hops ?? this.hops,
      centerRequest: centerRequest ?? this.centerRequest,
    );
  }
}

final graphViewProvider = NotifierProvider<GraphView, GraphViewState>(
  GraphView.new,
);

class GraphView extends Notifier<GraphViewState> {
  /// Focus reaches at most this many links out (UI spec §10).
  static const maxHops = 3;

  @override
  GraphViewState build() => const GraphViewState();

  void toggleUnlinked() =>
      state = state.copyWith(showUnlinked: !state.showUnlinked);

  void toggleSuggestions() =>
      state = state.copyWith(showSuggestions: !state.showSuggestions);

  void setFilters(SearchFilters filters) =>
      state = state.copyWith(filters: filters, selected: () => null);

  void select(int? ref) => state = state.copyWith(selected: () => ref);

  /// The preview card closes, so it doesn't cover the focused notes.
  void focusOn(int ref) =>
      state = state.copyWith(focus: () => ref, selected: () => null);

  void clearFocus() => state = state.copyWith(focus: () => null);

  void setHops(int hops) => state = state.copyWith(hops: hops);

  /// The search jump: selects [ref] and centres on it. If it is hidden
  /// (unlinked, or outside the focus), it is made visible first.
  void jumpTo(int ref, {required bool hidden}) {
    state = state.copyWith(
      showUnlinked: hidden ? true : null,
      focus: hidden ? () => null : null,
      selected: () => ref,
      centerRequest: state.centerRequest + 1,
    );
  }
}
