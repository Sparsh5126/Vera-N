import 'dart:convert';
import 'dart:typed_data';

import '../../models/attachment_usage.dart';
import '../db/app_database.dart';
import '../files/attachment_name.dart';
import '../files/note_file_store.dart';
import '../files/note_markup.dart';

/// Photos, drawings and voice notes in `MyNotes/Attachments/` (product
/// spec §3). The note embeds each one by name; the files are the user's,
/// like the notes, and other apps can open them.
class AttachmentsRepository {
  AttachmentsRepository(this._db, this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  /// The automatic clean-up removes files unused this long.
  static const unusedFor = Duration(days: 30);

  final AppDatabase _db;
  final NoteFileStore _store;
  final DateTime Function() _clock;

  /// Saves [bytes] as a new attachment; returns its file name.
  Future<String> add(Uint8List bytes, String extension) async {
    final name = await _freeName(extension);
    await _store.writeAttachment(name, bytes);
    return name;
  }

  /// Saves a new drawing (SVG text); returns its name.
  Future<String> addDrawing(String svg) async {
    final name = await _freeName(AttachmentName.drawingExtension);
    await saveDrawing(name, svg);
    return name;
  }

  /// Writes drawing [name] again after more drawing.
  Future<void> saveDrawing(String name, String svg) =>
      _store.writeAttachment(name, utf8.encode(svg));

  Future<Uint8List?> read(String name) => _store.readAttachment(name);

  /// The room attachments take and which no note uses.
  Future<AttachmentUsage> usage() async {
    final files = await _store.listAttachments();
    final used = await _usedNames();
    final unused = [
      for (final f in files)
        if (!used.contains(f.path)) f,
    ];
    return AttachmentUsage(
      count: files.length,
      bytes: files.fold(0, (sum, f) => sum + f.size),
      unused: [for (final f in unused) f.path],
      unusedBytes: unused.fold(0, (sum, f) => sum + f.size),
    );
  }

  /// Deletes [names], unless a note embeds one again by now.
  Future<void> delete(Iterable<String> names) async {
    final used = await _usedNames();
    for (final name in names) {
      if (!used.contains(name)) await _store.deleteAttachment(name);
    }
  }

  /// The automatic clean-up (Settings, off by default): files unused for
  /// [unusedFor] are deleted. [since] says when each was first seen
  /// unused; returns it updated, for the next run.
  Future<Map<String, DateTime>> sweep(Map<String, DateTime> since) async {
    final now = _clock();
    final unused = (await usage()).unused;
    final next = {for (final n in unused) n: since[n] ?? now};
    final due = [
      for (final e in next.entries)
        if (now.difference(e.value) >= unusedFor) e.key,
    ];
    await delete(due);
    return next..removeWhere((name, _) => due.contains(name));
  }

  /// Names any note embeds: the trash and the archive count, so restoring
  /// a note brings its attachments back.
  Future<Set<String>> _usedNames() async {
    final rows = await _db
        .customSelect(
          "SELECT body FROM notes WHERE body LIKE '%](Attachments/%'",
          readsFrom: {_db.notes},
        )
        .get();
    return {for (final r in rows) ...NoteMarkup.embeds(r.read<String>('body'))};
  }

  Future<String> _freeName(String extension) async {
    while (true) {
      final name = AttachmentName.generate(_clock(), extension);
      if (await _store.readAttachment(name) == null) return name;
    }
  }
}
