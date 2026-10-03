import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/note.dart';
import '../../../core/storage/storage_providers.dart';

/// One note, kept up to date (pin state, outside changes).
final noteProvider = StreamProvider.autoDispose.family<Note?, int>(
  (ref, noteRef) => ref.watch(notesRepositoryProvider).watchNote(noteRef),
);
