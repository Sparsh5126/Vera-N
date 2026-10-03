import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(storageProvider).db),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => ref.watch(storageProvider).settings,
);
