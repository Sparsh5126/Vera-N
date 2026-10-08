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
    this.moreWaiting = false,
  });

  /// This batch (up to 5), and how many of it are decided.
  final List<SuggestionView> batch;
  final int done;
  final bool loading;

  /// After the batch: more suggestions are waiting ("Review 5 more").
  final bool moreWaiting;

  SuggestionView? get current => done < batch.length ? batch[done] : null;
  bool get finished => !loading && current == null;
  bool get canUndo => done > 0;

  ReviewState copyWith({
    List<SuggestionView>? batch,
    int? done,
    bool? loading,
    bool? moreWaiting,
  }) => ReviewState(
    batch: batch ?? this.batch,
    done: done ?? this.done,
    loading: loading ?? this.loading,
    moreWaiting: moreWaiting ?? this.moreWaiting,
  );
}

/// Goes through one batch of suggestions, with undo for each choice.
class ReviewController extends Notifier<ReviewState> {
  final _undos = <Undo>[];
  bool _busy = false;

  @override
  ReviewState build() {
    Future.microtask(nextBatch);
    return const ReviewState();
  }

  /// Loads the next batch: fresh suggestions first, then "not sure" ones.
  Future<void> nextBatch() async {
    _undos.clear();
    state = const ReviewState();
    final list = await ref
        .read(storageProvider)
        .suggestions
        .batch(size: AiSettings.batchSize);
    final views = await ref.read(suggestionViewsProvider).loadAll(list);
    state = ReviewState(batch: views, loading: false);
    if (views.isEmpty) await _checkMore();
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
      if (state.finished) await _checkMore();
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
      state = state.copyWith(done: state.done - 1, moreWaiting: false);
    } finally {
      _busy = false;
    }
  }

  /// "Not sure" ones from this batch only come back in a later batch, so
  /// "more" means suggestions this batch didn't show.
  Future<void> _checkMore() async {
    final shown = {for (final v in state.batch) v.suggestion.id};
    final pending = await ref.read(storageProvider).suggestions.pending();
    state = state.copyWith(
      moreWaiting: pending.any((s) => !shown.contains(s.id)),
    );
  }
}

final reviewProvider =
    NotifierProvider.autoDispose<ReviewController, ReviewState>(
      ReviewController.new,
    );
