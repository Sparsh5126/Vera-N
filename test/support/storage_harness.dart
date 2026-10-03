import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:vera_n/core/storage/db/app_database.dart';
import 'package:vera_n/core/storage/indexer/note_indexer.dart';
import 'package:vera_n/core/storage/indexer/note_writer.dart';
import 'package:vera_n/core/storage/repositories/notes_repository.dart';

import 'memory_note_file_store.dart';

/// An in-memory database, fake files, and the storage classes wired up.
class StorageHarness {
  StorageHarness() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    writer = NoteWriter(db, store);
    indexer = NoteIndexer(db, store);
    repo = NotesRepository(
      db,
      store,
      writer,
      clock: () => now,
      random: Random(42),
    );
  }

  final store = MemoryNoteFileStore();
  late final AppDatabase db;
  late final NoteWriter writer;
  late final NoteIndexer indexer;
  late final NotesRepository repo;
  DateTime now = DateTime(2026, 10, 3, 15, 32, 28);

  Future<NoteRow> row(int ref) =>
      (db.select(db.notes)..where((n) => n.id.equals(ref))).getSingle();

  Future<List<String>> tags(int ref) async {
    final rows = await (db.select(
      db.noteTags,
    )..where((t) => t.note.equals(ref))).get();
    return rows.map((r) => r.tag).toList()..sort();
  }

  Future<void> dispose() async {
    writer.dispose();
    await db.close();
  }
}
