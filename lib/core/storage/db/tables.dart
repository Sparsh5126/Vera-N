import 'package:drift/drift.dart';

/// One row per note file. The database is an index: every column here can
/// be rebuilt from the files, except unsaved edits (`pendingWrite`).
@DataClassName('NoteRow')
@TableIndex(name: 'notes_modified', columns: {#trashedAt, #modified})
@TableIndex(name: 'notes_note_id', columns: {#noteId})
@TableIndex(name: 'notes_folder', columns: {#folder})
@TableIndex(name: 'notes_name_key', columns: {#nameKey})
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Header `id`; null for headerless notes (identity is then the path).
  TextColumn get noteId => text().nullable()();

  /// Path inside `Notes/`, `/`-separated, as written on disk.
  TextColumn get path => text()();

  /// Lower-cased [path]: paths compare case-insensitively.
  TextColumn get pathKey => text().unique()();

  /// Lower-cased file name without `.md`: what `[[links]]` point at.
  TextColumn get nameKey => text().withDefault(const Constant(''))();

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

/// `[[links]]` written in each note's text, for Linked, Mentioned in and
/// the graph. Rebuilt from the text whenever it changes.
@DataClassName('LinkRow')
@TableIndex(name: 'links_target', columns: {#targetKey})
@TableIndex(name: 'links_source', columns: {#source})
class Links extends Table {
  IntColumn get source =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();

  /// See `ParsedLink.targetKey`: a file name or a path, lower case.
  TextColumn get targetKey => text()();

  /// Order in the note, so Linked chips follow the text.
  IntColumn get position => integer()();
  TextColumn get label => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {source, targetKey};
}

/// Per note: what the last analysis read, so a note is embedded again only
/// when its text or the model changed (product spec §4). Rebuildable.
@DataClassName('NoteAnalysisRow')
class NoteAnalysis extends Table {
  IntColumn get note =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get contentHash => text()();

  /// Embedding model name and version the chunks were made with.
  TextColumn get model => text()();
  DateTimeColumn get analyzedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {note};
}

/// Chunk embeddings: a note's text split into pieces the model can read,
/// each with an int8 vector (384 bytes). Rebuildable from the notes.
@DataClassName('ChunkRow')
class Chunks extends Table {
  IntColumn get note =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get idx => integer()();

  /// Where the chunk sits in the note's text, for "why related" later.
  IntColumn get start => integer()();
  IntColumn get end => integer()();

  /// Hash of the chunk's text: unchanged chunks keep their vector.
  TextColumn get hash => text()();
  TextColumn get model => text()();
  BlobColumn get vector => blob()();

  @override
  Set<Column<Object>> get primaryKey => {note, idx};
}

/// AI suggestions waiting for review (product spec §7). Never written to
/// files; rebuildable. [noteA] < [noteB], one row per pair and kind.
@DataClassName('SuggestionRow')
@TableIndex(name: 'suggestions_note_a', columns: {#noteA})
@TableIndex(name: 'suggestions_note_b', columns: {#noteB})
@TableIndex(name: 'suggestions_expires', columns: {#expiresAt})
class Suggestions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `link` for now; later `tag`, `topic`, `resurface`.
  TextColumn get kind => text()();
  IntColumn get noteA =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get noteB =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  RealColumn get score => real()();

  /// The best-matching chunk of each note, for "why related".
  IntColumn get chunkA => integer()();
  IntColumn get chunkB => integer()();

  /// `fresh` (not yet reviewed) or `notSure` (comes back in a later batch).
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {kind, noteA, noteB},
  ];
}

/// Rejected suggestions (product spec §8), so a pair doesn't come back.
/// Also appended to `MyNotes/.app/rejections-<deviceid>.jsonl` (ids and
/// hashes only), so they survive uninstall and reach other devices.
@DataClassName('RejectionRow')
class Rejections extends Table {
  /// `idA|idB`, the two note ids in sorted order.
  TextColumn get pairKey => text()();
  TextColumn get noteA => text()();
  TextColumn get hashA => text()();
  TextColumn get noteB => text()();
  TextColumn get hashB => text()();

  /// Word fingerprints (see `WordSignature`) when rejected, kept only in
  /// this private database: a pair returns only after a big change.
  BlobColumn get signatureA => blob().nullable()();
  BlobColumn get signatureB => blob().nullable()();
  DateTimeColumn get rejectedAt => dateTime()();
  TextColumn get deviceId => text()();

  @override
  Set<Column<Object>> get primaryKey => {pairKey};
}
