import 'package:flutter/material.dart';

import '../../../core/models/note_summary.dart';
import '../../../core/styles/app_styles.dart';
import '../../../core/utils/date_label.dart';
import '../../../shared/widgets/note_card.dart';

/// A two-column grid of note cards (the default layout).
/// Built lazily, so long libraries scroll smoothly.
class NotesGrid extends StatelessWidget {
  const NotesGrid({
    super.key,
    required this.notes,
    required this.now,
    required this.onOpen,
  });

  static const columns = 2;

  final List<NoteSummary> notes;
  final DateTime now;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.textScalerOf(context)
        .scale(AppSize.noteCardHeight);
    return SliverPadding(
      padding: AppSpace.screen,
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: AppSpace.s,
          crossAxisSpacing: AppSpace.s,
          mainAxisExtent: height,
        ),
        itemCount: notes.length,
        itemBuilder: (context, i) {
          final note = notes[i];
          return NoteCard(
            title: note.title,
            preview: note.preview,
            dateLabel: DateLabel.of(note.modified, now),
            pinned: note.pinned,
            onTap: () => onOpen(note.ref),
          );
        },
      ),
    );
  }
}
