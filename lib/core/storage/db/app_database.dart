import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'note_rows.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The index database, in app-private storage (ARCHITECTURE.md §8).
@DriftDatabase(
  tables: [
    Notes,
    NoteTags,
    Settings,
    Links,
    NoteAnalysis,
    Chunks,
    Suggestions,
    Rejections,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database on a background isolate.
  factory AppDatabase.open() {
    return AppDatabase(
      driftDatabase(
        name: 'vera_n',
        native: const DriftNativeOptions(
          databaseDirectory: getApplicationSupportDirectory,
          // The background analysis (another isolate) shares the same
          // connection, so the UI's queries see its changes.
          shareAcrossIsolates: true,
        ),
      ),
    );
  }

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final statement in _searchIndex) {
        await customStatement(statement);
      }
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(settings);
      if (from < 3) {
        await m.addColumn(notes, notes.nameKey);
        await m.createIndex(notesNameKey);
        await m.createTable(links);
        await NoteRows.backfillLinks(this);
      }
      if (from < 4) {
        await m.createTable(noteAnalysis);
        await m.createTable(chunks);
        await m.createTable(suggestions);
        await m.createIndex(suggestionsNoteA);
        await m.createIndex(suggestionsNoteB);
        await m.createIndex(suggestionsExpires);
      }
      if (from < 5) await m.createTable(rejections);
      if (from < 6) {
        // Tag suggestions: a tag column, and the unique key now includes
        // it (the table is rebuilt; pending suggestions are kept).
        await m.alterTable(
          TableMigration(suggestions, newColumns: [suggestions.tag]),
        );
      }
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );

  /// Keyword search: an FTS5 index over title and body, kept in sync with
  /// `notes` by triggers. `unicode61` handles Devanagari.
  static const _searchIndex = [
    '''CREATE VIRTUAL TABLE notes_fts USING fts5(
         title, body, content='notes', content_rowid='id',
         tokenize='unicode61')''',
    '''CREATE TRIGGER notes_fts_insert AFTER INSERT ON notes BEGIN
         INSERT INTO notes_fts(rowid, title, body)
         VALUES (new.id, new.title, new.body);
       END''',
    '''CREATE TRIGGER notes_fts_delete AFTER DELETE ON notes BEGIN
         INSERT INTO notes_fts(notes_fts, rowid, title, body)
         VALUES ('delete', old.id, old.title, old.body);
       END''',
    '''CREATE TRIGGER notes_fts_update AFTER UPDATE OF title, body ON notes
       BEGIN
         INSERT INTO notes_fts(notes_fts, rowid, title, body)
         VALUES ('delete', old.id, old.title, old.body);
         INSERT INTO notes_fts(rowid, title, body)
         VALUES (new.id, new.title, new.body);
       END''',
  ];
}
