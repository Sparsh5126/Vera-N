import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show OrderingTerm;

import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../indexer/note_writer.dart';

/// "Export notes" (UI spec §11): every note as its Markdown file, in its
/// folders, in one .zip (decided 2026-10-08). The trash and the app's own
/// data (suggestions, rejections, analysis) are left out.
///
/// The text comes from the database, which matches the files (unsaved
/// typing is written first, and outside changes are picked up on every
/// start and resume). Reading each file back through Android's folder
/// access would be far slower for large libraries.
class NotesExporter {
  NotesExporter(this._db, this._writer);

  final AppDatabase _db;
  final NoteWriter _writer;

  /// The .zip's bytes. Paths inside are the notes' own paths.
  Future<Uint8List> zip() async {
    await _writer.flush();
    final rows =
        await (_db.select(_db.notes)
              ..where((n) => n.trashedAt.isNull())
              ..orderBy([(n) => OrderingTerm(expression: n.path)]))
            .get();
    final archive = Archive();
    for (final row in rows) {
      final bytes = utf8.encode(NoteRows.fileText(row));
      archive.addFile(ArchiveFile.bytes(row.path, bytes));
    }
    return ZipEncoder().encodeBytes(archive);
  }

  /// The suggested file name, e.g. `Vera N notes 2026-10-08.zip`.
  static String fileName(String appName, DateTime day) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '$appName notes ${day.year}-${two(day.month)}-${two(day.day)}.zip';
  }
}
