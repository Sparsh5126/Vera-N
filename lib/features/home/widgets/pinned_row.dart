import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/note_summary.dart';
import '../../../core/styles/app_styles.dart';
import '../../../core/utils/date_label.dart';
import '../../../shared/widgets/note_card.dart';
import 'card_callbacks.dart';
import '../../../shared/widgets/section_label.dart';

/// "Pinned" label and a horizontal row of pinned note cards.
class PinnedRow extends StatelessWidget {
  const PinnedRow({
    super.key,
    required this.notes,
    required this.now,
    required this.cards,
    required this.showSuggested,
  });

  final List<NoteSummary> notes;
  final DateTime now;
  final CardCallbacks cards;

  /// Whether the faded "has suggestions" dot may show.
  final bool showSuggested;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: AppSpace.screen,
          child: SectionLabel(AppCopy.pinned),
        ),
        const SizedBox(height: AppSpace.s),
        SizedBox(
          height: scaler.scale(AppSize.noteCardHeight),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpace.screen,
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpace.s),
            itemBuilder: (context, i) => SizedBox(
              width: scaler.scale(AppSize.pinnedCardWidth),
              child: _card(notes[i]),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.l),
      ],
    );
  }

  Widget _card(NoteSummary note) => NoteCard(
    title: note.title,
    preview: note.preview,
    dateLabel: DateLabel.of(note.modified, now),
    pinned: true,
    suggested: showSuggested && note.suggested,
    onTap: () => cards.open(note.ref),
    onLongPress: () => cards.menu(note),
  );
}
