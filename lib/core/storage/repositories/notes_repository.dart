import 'dart:math';

import 'package:drift/drift.dart';

import '../../models/note.dart';
import '../../models/note_header.dart';
import '../../models/note_summary.dart';
import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_document.dart';
import '../files/note_file_store.dart';
import '../files/note_header_codec.dart';
import '../files/note_id.dart';
import '../files/note_links.dart';
import '../files/note_text.dart';
import '../indexer/note_writer.dart';
import 'note_placement.dart';

/// Create, read, update, tag, pin, move and trash notes.
///
/// Every change lands in the database at once (the UI never waits on
/// files); [NoteWriter] writes the file shortly after.
class NotesRepository {
  NotesRepository(
    this._db,
    this._store,
    this._writer, {
    DateTime Function()? clock,
    Random? random,
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? Random.secure() {
    _placement = NotePlacement(
      _db,
      _store,
      _writer,
      clock: _clock,
      random: _random,
    );
  }

  static const trashFolder = NotePlacement.trashFolder;

  final AppDatabase _db;
  final NoteFileStore _store;
  final NoteWriter _writer;
  final DateTime Function() _clock;
  final Random _random;
  late final NotePlacement _placement;

  /// Notes not in the trash, most recently changed first.
  Stream<List<NoteSummary>> watchNotes() {
    final query = _db.select(_db.notes)
      ..where((n) => n.trashedAt.isNull())
      ..orderBy([
        (n) => OrderingTerm.desc(n.modified),
        (n) => OrderingTerm.desc(n.id),
      ]);
    return query.watch().map((rows) => rows.map(NoteRows.toSummary).toList());
  }

  /// Notes not in the trash, most recently changed first (one read).
  Future<List<NoteSummary>> allNotes() async {
    final query = _db.select(_db.notes)
      ..where((n) => n.trashedAt.isNull())
      ..orderBy([(n) => OrderingTerm.desc(n.modified)]);
    return (await query.get()).map(NoteRows.toSummary).toList();
  }

  Future<Note?> getNote(int ref) async {
    final row = await _row(ref).getSingleOrNull();
    return row == null ? null : NoteRows.toNote(row);
  }

  Stream<Note?> watchNote(int ref) =>
      _row(ref)
          .watchSingleOrNull()
          .map((row) => row == null ? null : NoteRows.toNote(row));

  /// Creates a note with a new id and minimal header. Returns its ref.
  Future<int> create(String body, {String folder = ''}) async {
    final now = _clock();
    final id = await _freeId(now, folder);
    final path = folder.isEmpty
        ? NoteId.fileName(id)
        : '$folder/${NoteId.fileName(id)}';
    final doc = NoteHeaderCodec.write(
      NoteDocument(headerLines: null, body: body),
      NoteHeader(id: id, created: now),
    );
    final ref = await _db
        .into(_db.notes)
        .insert(
          NotesCompanion.insert(
            noteId: Value(id),
            path: path,
            pathKey: NoteRows.pathKey(path),
            nameKey: Value(NoteLinks.nameKey(path)),
            folder: folder,
            title: NoteText.title(body),
            body: body,
            headerRaw: Value(doc.headerLines!.join('\n')),
            contentHash: NoteText.contentHash(body),
            created: now,
            modified: now,
            pendingWrite: const Value(true),
          ),
        );
    await NoteRows.replaceLinks(_db, ref, body);
    _writer.schedule();
    return ref;
  }

  /// Saves new text. A headerless note stays headerless.
  Future<void> updateBody(int ref, String body) async {
    final row = await _row(ref).getSingleOrNull();
    if (row == null || row.body == body) return;
    await _change(
      ref,
      NotesCompanion(
        title: Value(NoteText.title(body)),
        body: Value(body),
        contentHash: Value(NoteText.contentHash(body)),
        modified: Value(_clock()),
      ),
    );
    await NoteRows.replaceLinks(_db, ref, body);
  }

  Future<void> setPinned(int ref, bool pinned) => _changeHeader(
    ref,
    (h) => h.copyWith(pinned: pinned),
    extra: NotesCompanion(pinned: Value(pinned)),
  );

  Future<void> setTags(int ref, List<String> tags) async {
    await _changeHeader(ref, (h) => h.copyWith(tags: tags));
    await NoteRows.replaceTags(_db, ref, tags);
  }

  /// Moves the note's file into `.trash/`; the file is kept for undo.
  Future<void> trash(int ref) => _placement.trash(ref);

  /// Undo for [trash].
  Future<void> restore(int ref) => _placement.restore(ref);

  /// Moves the note into [folder] (`''` is the top level). Returns the
  /// folder it was in, for undo.
  Future<String?> moveToFolder(int ref, String folder) =>
      _placement.moveToFolder(ref, folder);

  /// Writes the header with [change] applied. A headerless note gets its
  /// `id` header here, on the first change that must persist.
  Future<void> _changeHeader(
    int ref,
    NoteHeader Function(NoteHeader) change, {
    NotesCompanion extra = const NotesCompanion(),
  }) async {
    final row = await _row(ref).getSingleOrNull();
    if (row == null) return;
    var header = NoteRows.headerOf(row);
    if (row.noteId == null) {
      final id = await _freeAdoptedId(row.created);
      header = header.copyWith(id: id, created: row.created);
    }
    header = change(header);
    final doc = NoteHeaderCodec.write(
      NoteRows.documentOf(row.headerRaw, row.body, row.newline),
      header,
    );
    await _change(
      ref,
      extra.copyWith(
        noteId: Value(header.id),
        headerRaw: Value(doc.headerLines!.join('\n')),
        // Changes only if a leading `---` block wasn't a valid header.
        body: Value(doc.body),
        title: Value(NoteText.title(doc.body)),
        contentHash: Value(NoteText.contentHash(doc.body)),
      ),
    );
    if (doc.body != row.body) await NoteRows.replaceLinks(_db, ref, doc.body);
  }

  /// Applies an in-app change and schedules the file write. The revision
  /// bump happens in the same transaction, so a file write running at the
  /// same time can't clear `pendingWrite` for text it didn't write.
  Future<void> _change(int ref, NotesCompanion values) async {
    await _db.transaction(() async {
      final row = await _row(ref).getSingleOrNull();
      if (row == null) return;
      await _update(ref).write(
        values.copyWith(
          pendingWrite: const Value(true),
          revision: Value(row.revision + 1),
        ),
      );
    });
    _writer.schedule();
  }

  Future<String> _freeId(DateTime now, String folder) async {
    while (true) {
      final id = NoteId.generate(now, random: _random);
      final name = NoteId.fileName(id);
      if (!await _placement.pathTaken(
        folder.isEmpty ? name : '$folder/$name',
      )) {
        return id;
      }
    }
  }

  Future<String> _freeAdoptedId(DateTime created) async {
    while (true) {
      final id = NoteId.generate(created.toLocal(), random: _random);
      final taken =
          await (_db.select(
            _db.notes,
          )..where((n) => n.noteId.equals(id))).getSingleOrNull() !=
          null;
      if (!taken) return id;
    }
  }

  SimpleSelectStatement<$NotesTable, NoteRow> _row(int ref) =>
      _db.select(_db.notes)..where((n) => n.id.equals(ref));

  UpdateStatement<$NotesTable, NoteRow> _update(int ref) =>
      _db.update(_db.notes)..where((n) => n.id.equals(ref));
}
