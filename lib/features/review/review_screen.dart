import 'dart:async';

import 'package:flutter/material.dart';
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
import '../../shared/widgets/suggestion_card.dart';
import '../../shared/widgets/undo_snack_bar.dart';
import 'state/review_controller.dart';
import 'widgets/progress_dots.dart';
import 'widgets/review_buttons.dart';
import 'widgets/review_done.dart';
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
    final messenger = ScaffoldMessenger.of(context);
    final review = ref.read(reviewProvider.notifier);
    // Haptics: light on accept, soft on not sure, none on reject.
    final haptic = switch (choice) {
      ReviewChoice.accept => HapticEvent.accept,
      ReviewChoice.notSure => HapticEvent.notSure,
      ReviewChoice.reject => null,
    };
    if (haptic != null) unawaited(Haptics.play(haptic));
    await review.choose(choice);
    if (choice == ReviewChoice.accept) {
      UndoSnackBar.show(messenger, message: AppCopy.linked, onUndo: _undo);
    } else {
      messenger.hideCurrentSnackBar();
    }
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpace.screen,
          child: Column(
            children: [
              _topBar(state),
              Expanded(child: _body(state, current)),
              if (current != null)
                ReviewButtons(
                  onReject: () => unawaited(_choose(ReviewChoice.reject)),
                  onNotSure: () => unawaited(_choose(ReviewChoice.notSure)),
                  onAccept: () => unawaited(_choose(ReviewChoice.accept)),
                  onUndo: state.canUndo ? _undo : null,
                ),
              const SizedBox(height: AppSpace.m),
            ],
          ),
        ),
      ),
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
            ProgressDots(done: state.done, total: state.batch.length),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedSwitcher(
          duration: Motion.of(context),
          child: SwipeCard(
            key: ValueKey(current.suggestion.id),
            onSwipe: _onSwipe,
            child: _card(current),
          ),
        ),
        if (_showHint) ReviewHint(onDismiss: _dismissHint),
      ],
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
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SuggestionCard(
          newer: side(AppCopy.reviewNewLabel, view.newer),
          older: side(AppCopy.reviewOlderLabel, view.older),
          reason: AppCopy.suggestionReason(view.older.title),
        ),
      ),
    );
  }
}
