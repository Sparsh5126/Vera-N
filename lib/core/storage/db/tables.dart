import 'package:drift/drift.dart';

/// One row per note file. The database is an index: every column here can
/// be rebuilt from the files, except unsaved edits (`pendingWrite`).
@DataClassName('NoteRow')
@TableIndex(name: 'notes_modified', columns: {#trashedAt, #modified})
@TableIndex(name: 'notes_note_id', columns: {#noteId})
@TableIndex(name: 'notes_folder', columns: {#folder})
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Header `id`; null for headerless notes (identity is then the path).
  TextColumn get noteId => text().nullable()();

  /// Path inside `Notes/`, `/`-separated, as written on disk.
  TextColumn get path => text()();

  /// Lower-cased [path]: paths compare case-insensitively.
  TextColumn get pathKey => text().unique()();

  /// Subfolder path, '' for the top level.
  TextColumn get folder => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  /// Header lines joined with '\n', or null when the file has no header.
  TextColumn get headerRaw => text().nullable()();

  /// Line ending used by the file's header.
  TextColumn get newline => text().withDefault(const Constant('\n'))();
  TextColumn get contentHash => text()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get modified => dateTime()();

  /// File time and size when last read or written, in milliseconds since
  /// epoch; null until the file exists. Used to skip unchanged files.
  IntColumn get fileModifiedMs => integer().nullable()();
  IntColumn get fileSize => integer().nullable()();

  /// The database has text the file doesn't have yet.
  BoolColumn get pendingWrite => boolean().withDefault(const Constant(false))();

  /// Bumped on every change made in the app, so a background file write
  /// only clears [pendingWrite] if no newer change arrived meanwhile.
  IntColumn get revision => integer().withDefault(const Constant(0))();

  /// The file changed elsewhere while this note had an unsaved edit.
  BoolColumn get conflict => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashedAt => dateTime().nullable()();
}

/// Confirmed tags, for filtering and the Tags view.
@DataClassName('NoteTagRow')
@TableIndex(name: 'note_tags_tag', columns: {#tag})
class NoteTags extends Table {
  IntColumn get note =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tag => text()();

  @override
  Set<Column<Object>> get primaryKey => {note, tag};
}

/// Small per-device settings (private storage, never synced).
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
