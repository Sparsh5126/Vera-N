import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'db/app_database.dart';
import 'files/folder_access.dart';
import 'files/io_note_file_store.dart';
import 'files/note_file_store.dart';
import 'files/switching_note_file_store.dart';
import 'indexer/note_indexer.dart';
import 'indexer/note_writer.dart';
import 'indexer/notes_relocator.dart';
import 'repositories/attachments_repository.dart';
import 'repositories/analysis_repository.dart';
import 'repositories/conflict_resolver.dart';
import 'repositories/notes_exporter.dart';
import 'repositories/notes_repository.dart';
import 'repositories/rejections_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/suggestions_repository.dart';
import 'repositories/trash_repository.dart';

/// What background analysis uses; see [StorageServices.openForAnalysis].
typedef AnalysisStorage = ({
  AnalysisRepository analysis,
  SuggestionsRepository suggestions,
  SettingsRepository settings,
  Future<void> Function() close,
});

/// The storage objects the app shares, wired together once at start.
///
/// Notes live in the folder the user picked, or, until then (or if access
/// is removed), in the app-private holding folder (ARCHITECTURE.md §8).
class StorageServices {
  StorageServices(this.db, NoteFileStore holding, {this.folders})
    : _holding = holding,
      store = SwitchingNoteFileStore(holding),
      settings = SettingsRepository(db),
      suggestions = SuggestionsRepository(db),
      analysis = AnalysisRepository(db) {
    writer = NoteWriter(db, store);
    indexer = NoteIndexer(db, store);
    notes = NotesRepository(db, store, writer);
    rejections = RejectionsRepository(db, store);
    trash = TrashRepository(db, store);
    attachments = AttachmentsRepository(store);
    exporter = NotesExporter(db, writer);
    conflicts = ConflictResolver(db, store, writer, indexer, notes);
  }

  /// Opens storage on the device and reconnects to the picked folder.
  static Future<StorageServices> open() async {
    final support = await getApplicationSupportDirectory();
    final holding = Directory(p.join(support.path, 'MyNotes', 'Notes'));
    final services = StorageServices(
      AppDatabase.open(),
      IoNoteFileStore(holding),
      folders: Platform.isAndroid ? const AndroidFolderAccess() : null,
    );
    await services.reconnectFolder();
    return services;
  }

  /// Storage for the background analysis task: the database only (it
  /// reads note text from there, never from the folder). Close it after.
  static AnalysisStorage openForAnalysis() {
    final db = AppDatabase.open();
    return (
      analysis: AnalysisRepository(db),
      suggestions: SuggestionsRepository(db),
      settings: SettingsRepository(db),
      close: db.close,
    );
  }

  final AppDatabase db;
  final SwitchingNoteFileStore store;
  final SettingsRepository settings;
  final SuggestionsRepository suggestions;
  final AnalysisRepository analysis;

  /// Null where picking a folder isn't supported yet (desktop).
  final FolderAccess? folders;
  final NoteFileStore _holding;
  late final NoteWriter writer;
  late final NoteIndexer indexer;
  late final NotesRepository notes;
  late final RejectionsRepository rejections;
  late final TrashRepository trash;
  late final AttachmentsRepository attachments;
  late final NotesExporter exporter;
  late final ConflictResolver conflicts;
  Future<void>? _reconciling;

  bool get canChooseFolder => folders != null;

  /// Lets the user pick the notes folder and moves the notes there.
  /// Returns false if they backed out of the picker.
  Future<bool> chooseFolder() async {
    final folders = this.folders;
    final folder = await folders?.pick();
    if (folders == null || folder == null) return false;
    await writer.flush();
    final target = folders.storeFor(folder);
    await NotesRelocator(db).relocate(store.current, target);
    store.switchTo(target);
    await settings.setNotesFolder(folder);
    await reconcile();
    // The chosen folder may hold rejections from an earlier install.
    await rejections.importFiles();
    return true;
  }

  /// The picked folder's name, or null when notes are only in the app.
  Future<String?> notesFolderName() async {
    final folder = await settings.notesFolder();
    return folder == null ? null : folders?.displayName(folder);
  }

  /// Picks up changes made outside the app. Never runs twice at once.
  Future<void> reconcile() {
    return _reconciling ??= indexer.reconcile().whenComplete(
      () => _reconciling = null,
    );
  }

  /// After start, never delaying it: reads every device's rejections file
  /// into the database (so rejections survive reinstalling), and removes
  /// notes kept in the trash past 30 days. A failure only means it waits
  /// for the next start.
  Future<void> cleanUp() async {
    try {
      await rejections.importFiles();
    } on Object catch (e) {
      debugPrint('VeraN rejections import failed: $e');
    }
    try {
      await trash.purge(DateTime.now());
    } on Object catch (e) {
      debugPrint('VeraN clean-up failed: $e');
    }
  }

  /// App going to the background: get unsaved text into files now.
  Future<void> onPause() => writer.flush();

  /// App back in front: pick up outside changes.
  void onResume() => unawaited(reconcile());

  /// Uses the picked folder if access is still granted. If access was
  /// removed, notes go back to the holding folder: every note is rewritten
  /// there from the database, so nothing is lost.
  Future<void> reconnectFolder() async {
    final folder = await settings.notesFolder();
    final folders = this.folders;
    if (folder == null || folders == null) return;
    if (await folders.hasAccess(folder)) {
      store.switchTo(folders.storeFor(folder));
      return;
    }
    await settings.setNotesFolder(null);
    store.switchTo(_holding);
    await (db.update(db.notes)..where((n) => n.trashedAt.isNull())).write(
      const NotesCompanion(
        pendingWrite: Value(true),
        fileModifiedMs: Value(null),
        fileSize: Value(null),
      ),
    );
    writer.schedule();
  }
}
