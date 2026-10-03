import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/note_summary.dart';
import '../../../core/storage/storage_providers.dart';

/// Home's notes, split into the pinned row and the rest.
@immutable
class HomeNotes {
  const HomeNotes({required this.pinned, required this.others});

  final List<NoteSummary> pinned;
  final List<NoteSummary> others;

  bool get isEmpty => pinned.isEmpty && others.isEmpty;
}

final homeNotesProvider = StreamProvider.autoDispose<HomeNotes>((ref) {
  final notes = ref.watch(notesRepositoryProvider).watchNotes();
  return notes.map(
    (all) => HomeNotes(
      pinned: [
        for (final n in all)
          if (n.pinned) n,
      ],
      others: [
        for (final n in all)
          if (!n.pinned) n,
      ],
    ),
  );
});
