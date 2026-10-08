import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_settings.dart';
import '../../../core/ai/suggestions/suggestion_actions.dart';
import '../../../core/ai/suggestions/suggestion_providers.dart';
import '../../../core/models/suggestion_view.dart';
import '../../../core/storage/storage_providers.dart';

/// The three choices on a suggestion (UI spec §6).
enum ReviewChoice { accept, reject, notSure }

@immutable
class ReviewState {
  const ReviewState({
    this.batch = const [],
    this.done = 0,
    this.loading = true,
  });

  /// This batch (up to 5), and how many of it are decided.
  final List<SuggestionView> batch;
  final int done;
  final bool loading;

  SuggestionView? get current => done < batch.length ? batch[done] : null;
  bool get finished => !loading && current == null;
  bool get canUndo => done > 0;

  ReviewState copyWith({
    List<SuggestionView>? batch,
    int? done,
    bool? loading,
  }) => ReviewState(
    batch: batch ?? this.batch,
    done: done ?? this.done,
    loading: loading ?? this.loading,
  );
}

/// Goes through one batch of suggestions, with undo for each choice. One
/// batch per visit: there is no "more" button; the next 5 wait for the
/// next visit from Home (UI spec §6).
class ReviewController extends Notifier<ReviewState> {
  final _undos = <Undo>[];
  bool _busy = false;

  @override
  ReviewState build() {
    Future.microtask(_load);
    return const ReviewState();
  }

  /// Loads the batch: fresh suggestions first, then "not sure" ones.
  Future<void> _load() async {
    final list = await ref
        .read(storageProvider)
        .suggestions
        .batch(size: AiSettings.batchSize);
    final views = await ref.read(suggestionViewsProvider).loadAll(list);
    state = ReviewState(batch: views, loading: false);
  }

  Future<void> choose(ReviewChoice choice) async {
    final current = state.current;
    if (current == null || _busy) return;
    _busy = true;
    try {
      final actions = ref.read(suggestionActionsProvider);
      final s = current.suggestion;
      _undos.add(switch (choice) {
        ReviewChoice.accept => await actions.accept(s),
        ReviewChoice.reject => await actions.reject(s),
        ReviewChoice.notSure => await actions.notSure(s),
      });
      state = state.copyWith(done: state.done + 1);
    } finally {
      _busy = false;
    }
  }

  /// Reverses the last choice and shows that card again.
  Future<void> undo() async {
    if (_undos.isEmpty || _busy) return;
    _busy = true;
    try {
      await _undos.removeLast()();
      state = state.copyWith(done: state.done - 1);
    } finally {
      _busy = false;
    }
  }
}

final reviewProvider =
    NotifierProvider.autoDispose<ReviewController, ReviewState>(
      ReviewController.new,
    );
