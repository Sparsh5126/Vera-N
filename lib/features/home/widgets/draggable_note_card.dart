import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/feedback/haptics.dart';
import '../../../core/models/note_summary.dart';
import '../../../core/styles/app_styles.dart';
import '../state/dragged_notes.dart';
import '../state/home_drag.dart';
import 'card_callbacks.dart';

/// A note card on Home that is held to select, or held and moved to drag
/// into a folder (UI spec §5). Letting go without moving selects it (the
/// hold). Moving lifts it, with every selected note if it is selected, and
/// shows the folder tray. A screen reader's long press still selects: the
/// card offers it on its own node ([NoteCard.onSemanticLongPress]).
///
/// The drag outlives this card: opening a folder under the finger takes
/// the card off the screen, so its callbacks use nothing it owns after
/// the drag starts.
class DraggableNoteCard extends ConsumerStatefulWidget {
  const DraggableNoteCard({
    super.key,
    required this.note,
    required this.cards,
    required this.card,
  });

  final NoteSummary note;
  final CardCallbacks cards;

  /// The card itself, built with no long press: the drag takes the hold.
  final Widget card;

  @override
  ConsumerState<DraggableNoteCard> createState() => _DraggableNoteCardState();
}

class _DraggableNoteCardState extends ConsumerState<DraggableNoteCard> {
  double _travel = 0;
  bool _moved = false;

  @override
  Widget build(BuildContext context) {
    final drag = ref.read(homeDragProvider.notifier);
    final note = widget.note;
    final cards = widget.cards;
    final refs = cards.isSelected(note.ref) ? cards.selected : {note.ref};
    return LayoutBuilder(
      builder: (context, constraints) => LongPressDraggable<DraggedNotes>(
        data: DraggedNotes(refs),
        // Haptics only through core/feedback (CLAUDE.md §7).
        hapticFeedbackOnStart: false,
        onDragStarted: () {
          _travel = 0;
          _moved = false;
          // Felt as the hold registers: it selects or, if the finger
          // moves on, lifts the card; one tick either way.
          unawaited(Haptics.play(HapticEvent.select));
        },
        onDragUpdate: (d) {
          if (_moved) return;
          _travel += d.delta.distance;
          if (_travel > kTouchSlop) {
            _moved = true;
            drag.start();
          }
        },
        onDraggableCanceled: (_, _) {
          if (!_moved) cards.hold(note);
        },
        onDragEnd: (_) => drag.stop(),
        feedback: _lifted(context, constraints.biggest, refs.length),
        childWhenDragging: Opacity(
          opacity: AppOpacity.dimmed,
          child: widget.card,
        ),
        child: widget.card,
      ),
    );
  }

  /// The card under the finger, with how many notes go with it.
  Widget _lifted(BuildContext context, Size size, int count) {
    final colors = context.colors;
    return Material(
      type: MaterialType.transparency,
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: widget.card),
            if (count > 1)
              Positioned(
                top: -AppSpace.s,
                right: -AppSpace.s,
                child: Container(
                  padding: const EdgeInsets.all(AppSpace.s),
                  decoration: BoxDecoration(
                    color: colors.text,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: context.textStyles.label.copyWith(
                      color: colors.background,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
