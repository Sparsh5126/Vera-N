import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_prefs.dart';
import '../../../core/models/note_summary.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/styles/app_styles.dart';
import '../../../core/utils/date_label.dart';
import '../../../shared/widgets/note_card.dart';
import 'card_callbacks.dart';

/// Home's note cards, as a two-column grid (the default) or a list, as
/// chosen in Settings. Built lazily, so long libraries scroll smoothly.
class NoteCards extends ConsumerWidget {
  const NoteCards({
    super.key,
    required this.notes,
    required this.now,
    required this.cards,
  });

  static const columns = 2;

  final List<NoteSummary> notes;
  final DateTime now;
  final CardCallbacks cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(appPrefsProvider.select((p) => p.layout));
    final showSuggested = ref.watch(suggestionsOnProvider);
    final scaler = MediaQuery.textScalerOf(context);
    Widget card(BuildContext context, int i) {
      final note = notes[i];
      return NoteCard(
        title: note.title,
        preview: note.preview,
        dateLabel: DateLabel.of(note.modified, now),
        pinned: note.pinned,
        suggested: showSuggested && note.suggested,
        conflict: note.conflict,
        onTap: () => cards.open(note.ref),
        onLongPress: () => cards.menu(note),
      );
    }

    return SliverPadding(
      padding: AppSpace.screen,
      sliver: switch (layout) {
        NotesLayout.grid => SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpace.s,
            crossAxisSpacing: AppSpace.s,
            mainAxisExtent: scaler.scale(AppSize.noteCardHeight),
          ),
          itemCount: notes.length,
          itemBuilder: card,
        ),
        NotesLayout.list => SliverList.separated(
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s),
          itemBuilder: (context, i) => SizedBox(
            height: scaler.scale(AppSize.noteRowHeight),
            child: card(context, i),
          ),
        ),
      },
    );
  }
}
