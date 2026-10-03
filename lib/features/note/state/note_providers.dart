import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/linked_note.dart';
import '../../../core/models/note.dart';
import '../../../core/storage/storage_providers.dart';

/// One note, kept up to date (pin state, outside changes).
final noteProvider = StreamProvider.autoDispose.family<Note?, int>(
  (ref, noteRef) => ref.watch(notesRepositoryProvider).watchNote(noteRef),
);

/// Notes this note's text links to.
final linkedProvider = StreamProvider.autoDispose.family<List<LinkedNote>, int>(
  (ref, noteRef) => ref.watch(linksRepositoryProvider).watchLinked(noteRef),
);

/// Notes whose text links to this note.
final mentionedInProvider = StreamProvider.autoDispose
    .family<List<LinkedNote>, int>(
      (ref, noteRef) =>
          ref.watch(linksRepositoryProvider).watchMentionedIn(noteRef),
    );
