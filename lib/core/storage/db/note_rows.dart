import 'package:characters/characters.dart';
import 'package:drift/drift.dart';

import '../../models/note.dart';
import '../../models/note_header.dart';
import '../../models/note_summary.dart';
import '../files/note_document.dart';
import '../files/note_header_codec.dart';
import '../files/note_text.dart';
import 'app_database.dart';

/// Converts between note files, database rows and models.
abstract final class NoteRows {
  /// Characters of body kept for a card preview.
  static const previewLength = 280;

  static String pathKey(String path) => path.toLowerCase();

  static String folderOf(String path) {
    final slash = path.lastIndexOf('/');
    return slash == -1 ? '' : path.substring(0, slash);
  }

  /// Row values for a note whose file text is [text].
  ///
  /// A note with no `created` in its header keeps [knownCreated] (the date
  /// first seen), falling back to the file time.
  static NotesCompanion fromFile({
    required String path,
    required String text,
    required DateTime fileModified,
    required int fileSize,
    DateTime? knownCreated,
  }) {
    final doc = NoteDocument.parse(text);
    final header = NoteHeaderCodec.read(doc);
    return NotesCompanion(
      noteId: Value(header.id),
      path: Value(path),
      pathKey: Value(pathKey(path)),
      folder: Value(folderOf(path)),
      title: Value(NoteText.title(doc.body)),
      body: Value(doc.body),
      headerRaw: Value(doc.headerLines?.join('\n')),
      newline: Value(doc.newline),
      contentHash: Value(NoteText.contentHash(doc.body)),
      pinned: Value(header.pinned),
      created: Value(header.created ?? knownCreated ?? fileModified),
      modified: Value(fileModified),
      fileModifiedMs: Value(fileModified.millisecondsSinceEpoch),
      fileSize: Value(fileSize),
      pendingWrite: const Value(false),
      conflict: const Value(false),
    );
  }

  /// Tags as written in the file's header.
  static List<String> tagsOf(String? headerRaw) =>
      NoteHeaderCodec.read(documentOf(headerRaw, '')).tags;

  static NoteHeader headerOf(NoteRow row) =>
      NoteHeaderCodec.read(documentOf(row.headerRaw, row.body));

  static NoteDocument documentOf(
    String? headerRaw,
    String body, [
    String newline = '\n',
  ]) {
    return NoteDocument(
      headerLines: headerRaw?.split('\n'),
      body: body,
      newline: newline,
    );
  }

  /// The full file text for [row].
  static String fileText(NoteRow row) =>
      documentOf(row.headerRaw, row.body, row.newline).serialize();

  static Note toNote(NoteRow row) {
    return Note(
      ref: row.id,
      noteId: row.noteId,
      path: row.path,
      folder: row.folder,
      title: row.title,
      body: row.body,
      tags: tagsOf(row.headerRaw),
      pinned: row.pinned,
      created: row.created,
      modified: row.modified,
      conflict: row.conflict,
    );
  }

  static NoteSummary toSummary(NoteRow row) {
    return NoteSummary(
      ref: row.id,
      title: row.title,
      preview: NoteText.preview(
        row.body.characters.take(previewLength).toString(),
      ),
      pinned: row.pinned,
      modified: row.modified,
      folder: row.folder,
    );
  }

  /// Replaces the tag rows of note [ref] with [tags].
  static Future<void> replaceTags(
    AppDatabase db,
    int ref,
    List<String> tags,
  ) async {
    await (db.delete(db.noteTags)..where((t) => t.note.equals(ref))).go();
    await db.batch((b) {
      b.insertAll(db.noteTags, [
        for (final tag in tags.toSet())
          NoteTagsCompanion.insert(note: ref, tag: tag),
      ]);
    });
  }
}
