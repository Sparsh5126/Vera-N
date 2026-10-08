import 'package:characters/characters.dart';
import 'package:drift/drift.dart';

import '../../models/note.dart';
import '../../models/note_header.dart';
import '../../models/note_summary.dart';
import '../files/note_document.dart';
import '../files/note_header_codec.dart';
import '../files/note_links.dart';
import '../files/note_markup.dart';
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
    final doc = NoteHeaderCodec.normalize(NoteDocument.parse(text));
    final header = NoteHeaderCodec.read(doc);
    return NotesCompanion(
      noteId: Value(header.id),
      path: Value(path),
      pathKey: Value(pathKey(path)),
      nameKey: Value(NoteLinks.nameKey(path)),
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
      // Titles stored before links were shown as titles may hold markup.
      title: NoteMarkup.display(row.title),
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
      // Titles stored before links were shown as titles may hold markup.
      title: NoteMarkup.display(row.title),
      preview: NoteText.preview(
        row.body.characters.take(previewLength).toString(),
      ),
      pinned: row.pinned,
      modified: row.modified,
      folder: row.folder,
    );
  }

  /// A card's data from a row of `id, title, pinned, modified, folder,
  /// body` where body may be only the start of the text.
  static NoteSummary summaryFrom(QueryRow r) {
    return NoteSummary(
      ref: r.read<int>('id'),
      title: NoteMarkup.display(r.read<String>('title')),
      preview: NoteText.preview(r.read<String>('body')),
      pinned: r.read<bool>('pinned'),
      modified: r.read<DateTime>('modified'),
      folder: r.read<String>('folder'),
      suggested: r.data['suggested'] == 1,
      conflict: r.data['conflict'] == 1,
    );
  }

  /// Path columns for a note at [path] (where it lives and how links and
  /// lookups find it).
  static NotesCompanion placedAt(String path) => NotesCompanion(
    path: Value(path),
    pathKey: Value(pathKey(path)),
    nameKey: Value(NoteLinks.nameKey(path)),
    folder: Value(folderOf(path)),
  );

  /// Replaces the link rows of note [ref] with the links in [body].
  static Future<void> replaceLinks(AppDatabase db, int ref, String body) async {
    await (db.delete(db.links)..where((l) => l.source.equals(ref))).go();
    final links = NoteLinks.parse(body);
    await db.batch((b) {
      b.insertAll(db.links, [
        for (var i = 0; i < links.length; i++)
          LinksCompanion.insert(
            source: ref,
            targetKey: links[i].targetKey,
            position: i,
            label: Value(links[i].label),
          ),
      ]);
    });
  }

  /// Schema 3 migration: name keys and links for notes indexed before.
  static Future<void> backfillLinks(AppDatabase db) async {
    for (final row in await db.select(db.notes).get()) {
      await (db.update(db.notes)..where((n) => n.id.equals(row.id))).write(
        NotesCompanion(nameKey: Value(NoteLinks.nameKey(row.path))),
      );
      await replaceLinks(db, row.id, row.body);
    }
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
