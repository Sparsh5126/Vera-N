import 'dart:math';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/note_rows.dart';
import '../files/note_file_store.dart';
import '../files/note_markup.dart';

/// Moves note files from one notes folder to another, for example from the
/// in-app holding folder into the folder the user picked.
///
/// Notes already in the target (a reinstall, or a synced folder) are kept.
/// A same-named file with different text is never overwritten: the moved
/// note gets a short suffix instead.
class NotesRelocator {
  NotesRelocator(this._db, {Random? random})
    : _random = random ?? Random.secure();

  final AppDatabase _db;
  final Random _random;

  /// Returns how many notes were moved. Call after the writer has flushed.
  Future<int> relocate(NoteFileStore from, NoteFileStore to) async {
    var moved = 0;
    for (final entry in await from.listNotes()) {
      final text = await from.read(entry.path);
      var path = entry.path;
      if (await to.exists(path) && await to.read(path) != text) {
        path = _withSuffix(path);
      }
      await _copyAttachments(text, from, to);
      final written = await to.write(path, text);
      await _pointRowAt(entry.path, written);
      await from.delete(entry.path);
      moved++;
    }
    return moved;
  }

  /// The attachments [text] embeds go along, so the note still shows
  /// them. One already in the target is kept. The originals stay where
  /// they were, in case another note still embeds them there.
  Future<void> _copyAttachments(
    String text,
    NoteFileStore from,
    NoteFileStore to,
  ) async {
    for (final name in NoteMarkup.embeds(text)) {
      if (await to.readAttachment(name) != null) continue;
      final bytes = await from.readAttachment(name);
      if (bytes != null) await to.writeAttachment(name, bytes);
    }
  }

  Future<void> _pointRowAt(String oldPath, NoteFileEntry written) {
    final row = _db.update(_db.notes)
      ..where((n) => n.pathKey.equals(NoteRows.pathKey(oldPath)));
    return row.write(
      NoteRows.placedAt(written.path).copyWith(
        fileModifiedMs: Value(written.modified.millisecondsSinceEpoch),
        fileSize: Value(written.size),
      ),
    );
  }

  String _withSuffix(String path) {
    final hex = _random.nextInt(0x10000).toRadixString(16).padLeft(4, '0');
    return path.replaceFirst(RegExp(r'\.md$'), '-$hex.md');
  }
}
