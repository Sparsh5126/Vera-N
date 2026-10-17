import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/feedback/haptics.dart';
import '../../core/feedback/motion.dart';
import '../../core/models/suggestion_view.dart';
import '../../core/navigation/routes.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/date_label.dart';
import '../../shared/widgets/progress_dots.dart';
import '../../shared/widgets/suggestion_card.dart';
import '../../shared/widgets/undo_snack_bar.dart';
import 'state/review_controller.dart';
import 'widgets/review_buttons.dart';
import 'widgets/review_done.dart';
import 'widgets/remove_one_sheet.dart';
import 'widgets/review_hint.dart';
import 'widgets/swipe_card.dart';

/// Review (UI spec §6): one suggestion at a time, swiped or decided with
/// the buttons below; a quiet "All caught up." at the end.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadHint());
  }

  Future<void> _loadHint() async {
    final seen = await ref.read(settingsRepositoryProvider).reviewHintSeen();
    if (!seen && mounted) setState(() => _showHint = true);
  }

  void _dismissHint() {
    setState(() => _showHint = false);
    unawaited(ref.read(settingsRepositoryProvider).setReviewHintSeen());
  }

  Future<void> _choose(ReviewChoice choice) async {
    // A first decision means the gestures are learned.
    if (_showHint) _dismissHint();
    final messenger = ScaffoldMessenger.of(context);
    final review = ref.read(reviewProvider.notifier);
    // Haptics: light on accept, soft on not sure, none on reject.
    final haptic = switch (choice) {
      ReviewChoice.accept => HapticEvent.accept,
      ReviewChoice.notSure => HapticEvent.notSure,
      ReviewChoice.reject => null,
    };
    if (haptic != null) unawaited(Haptics.play(haptic));
    final copies = ref.read(reviewProvider).current?.suggestion.isDuplicate;
    await review.choose(choice);
    if (choice == ReviewChoice.accept) {
      UndoSnackBar.show(
        messenger,
        message: copies == true ? AppCopy.merged : AppCopy.linked,
        onUndo: _undo,
      );
    } else {
      messenger.hideCurrentSnackBar();
    }
  }

  /// Copies: pick which note goes to the trash; Undo brings it back.
  Future<void> _removeOne(SuggestionView view) async {
    final messenger = ScaffoldMessenger.of(context);
    final note = await RemoveOneSheet.show(context, view);
    if (note == null) return;
    await ref.read(reviewProvider.notifier).removeOne(note);
    UndoSnackBar.show(messenger, message: AppCopy.movedToTrash, onUndo: _undo);
  }

  void _undo() {
    unawaited(Haptics.play(HapticEvent.undo));
    unawaited(ref.read(reviewProvider.notifier).undo());
  }

  void _onSwipe(SwipeDirection direction) => switch (direction) {
    SwipeDirection.right => unawaited(_choose(ReviewChoice.accept)),
    SwipeDirection.left => unawaited(_choose(ReviewChoice.reject)),
    SwipeDirection.up => unawaited(_choose(ReviewChoice.notSure)),
    SwipeDirection.down => _undo(),
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);
    final current = state.current;
    // A keyboard (laptop, docs/LAPTOP_PLAN.md L1), beside the buttons:
    // Ctrl+Enter accept, Delete reject, Ctrl+U not sure, Ctrl+Z undo.
    return CallbackShortcuts(
      bindings: current == null
          ? const {}
          : {
              const SingleActivator(
                LogicalKeyboardKey.enter,
                control: true,
              ): () =>
                  unawaited(_choose(ReviewChoice.accept)),
              const SingleActivator(LogicalKeyboardKey.delete): () =>
                  unawaited(_choose(ReviewChoice.reject)),
              const SingleActivator(
                LogicalKeyboardKey.keyU,
                control: true,
              ): () =>
                  unawaited(_choose(ReviewChoice.notSure)),
              const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
                  _undo,
            },
      child: Focus(autofocus: true, child: _screen(state, current)),
    );
  }

  Widget _screen(ReviewState state, SuggestionView? current) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpace.screen,
          child: Column(
            children: [
              _topBar(state),
              Expanded(child: _body(state, current)),
              if (current != null && _showHint)
                ReviewHint(onDismiss: _dismissHint),
              if (current != null) _buttons(state, current),
              const SizedBox(height: AppSpace.m),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttons(ReviewState state, SuggestionView current) {
    final copies = current.suggestion.isDuplicate;
    return ReviewButtons(
      onReject: () => unawaited(_choose(ReviewChoice.reject)),
      onNotSure: () => unawaited(_choose(ReviewChoice.notSure)),
      onAccept: () => unawaited(_choose(ReviewChoice.accept)),
      onUndo: state.canUndo ? _undo : null,
      acceptLabel: copies ? AppCopy.merge : AppCopy.accept,
      rejectLabel: copies ? AppCopy.notCopies : AppCopy.reject,
      onRemoveOne: copies ? () => unawaited(_removeOne(current)) : null,
    );
  }

  Widget _topBar(ReviewState state) {
    return SizedBox(
      height: AppSize.minTapTarget,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close),
              tooltip: AppCopy.close,
            ),
          ),
          if (state.current != null)
            ProgressDots(
              done: state.done,
              total: state.batch.length,
              label: AppCopy.reviewProgress(state.done, state.batch.length),
            ),
        ],
      ),
    );
  }

  Widget _body(ReviewState state, SuggestionView? current) {
    // Everything is on the device: nothing to show while it loads.
    if (state.loading) return const SizedBox.shrink();
    if (current == null) {
      final review = ref.read(reviewProvider.notifier);
      return ReviewDone(
        onMore: state.moreWaiting ? () => unawaited(review.nextBatch()) : null,
      );
    }
    return AnimatedSwitcher(
      duration: Motion.of(context),
      child: SwipeCard(
        key: ValueKey(current.suggestion.id),
        onSwipe: _onSwipe,
        nudge: _showHint,
        child: _card(current),
      ),
    );
  }

  Widget _card(SuggestionView view) {
    final now = DateTime.now();
    SuggestionSide side(String label, SuggestedNote note) => SuggestionSide(
      label: '$label · ${DateLabel.of(note.created, now)}',
      title: note.title,
      passage: note.passage,
      onOpen: () => context.push(Routes.note(note.ref)),
    );
    final words = suggestionWording(view);
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SuggestionCard(
          newer: side(words.first, view.newer),
          older: view.single ? null : side(words.second, view.older),
          reason: words.reason,
          detail: view.suggestion.detail,
          hint: words.hint,
        ),
      ),
    );
  }
}
