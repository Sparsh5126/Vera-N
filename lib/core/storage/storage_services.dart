import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'db/app_database.dart';
import 'files/io_note_file_store.dart';
import 'files/note_file_store.dart';
import 'indexer/note_indexer.dart';
import 'indexer/note_writer.dart';
import 'repositories/notes_repository.dart';

/// The storage objects the app shares, wired together once at start.
class StorageServices {
  StorageServices(this.db, this.store)
    : writer = NoteWriter(db, store),
      indexer = NoteIndexer(db, store) {
    notes = NotesRepository(db, store, writer);
  }

  /// Opens storage on the device.
  ///
  /// Until the folder picker exists, notes live in the app-private holding
  /// folder (`<app support>/MyNotes/Notes`), the "Not now" path of
  /// ARCHITECTURE.md §8.
  static Future<StorageServices> open() async {
    final support = await getApplicationSupportDirectory();
    final notesDir = Directory(p.join(support.path, 'MyNotes', 'Notes'));
    return StorageServices(AppDatabase.open(), IoNoteFileStore(notesDir));
  }

  final AppDatabase db;
  final NoteFileStore store;
  final NoteWriter writer;
  final NoteIndexer indexer;
  late final NotesRepository notes;

  Future<void>? _reconciling;

  /// Picks up changes made outside the app. Never runs twice at once.
  Future<void> reconcile() {
    return _reconciling ??= indexer.reconcile().whenComplete(
      () => _reconciling = null,
    );
  }

  /// App going to the background: get unsaved text into files now.
  Future<void> onPause() => writer.flush();

  /// App back in front: pick up outside changes.
  void onResume() => unawaited(reconcile());
}
