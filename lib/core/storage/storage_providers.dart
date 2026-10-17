import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories/attachments_repository.dart';
import 'repositories/graph_repository.dart';
import 'repositories/links_repository.dart';
import 'repositories/note_batch.dart';
import 'repositories/notes_repository.dart';
import 'repositories/search_repository.dart';
import 'repositories/settings_repository.dart';
import 'storage_services.dart';

/// Overridden in `main.dart` with the opened [StorageServices]
/// (and in tests with an in-memory one).
final storageProvider = Provider<StorageServices>(
  (ref) => throw UnimplementedError('storageProvider must be overridden'),
);

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => ref.watch(storageProvider).notes,
);

/// Actions on several notes at once (Home's selection, drag and drop).
final noteBatchProvider = Provider<NoteBatch>(
  (ref) => NoteBatch(
    ref.watch(storageProvider).notes,
    ref.watch(storageProvider).analysis,
  ),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(storageProvider).db),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => ref.watch(storageProvider).settings,
);

final linksRepositoryProvider = Provider<LinksRepository>(
  (ref) => LinksRepository(ref.watch(storageProvider).db),
);

final graphRepositoryProvider = Provider<GraphRepository>(
  (ref) => GraphRepository(ref.watch(storageProvider).db),
);

final attachmentsRepositoryProvider = Provider<AttachmentsRepository>(
  (ref) => ref.watch(storageProvider).attachments,
);

/// An attachment's bytes, for its preview in the note. Invalidated after
/// a drawing is saved again.
final attachmentBytesProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>(
      (ref, name) => ref.watch(attachmentsRepositoryProvider).read(name),
    );
