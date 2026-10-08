import 'dart:convert';
import 'dart:typed_data';

import '../files/attachment_name.dart';
import '../files/note_file_store.dart';

/// Photos, drawings and voice notes in `MyNotes/Attachments/` (product
/// spec §3). The note embeds each one by name; the files are the user's,
/// like the notes, and other apps can open them.
class AttachmentsRepository {
  AttachmentsRepository(this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

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

  Future<String> _freeName(String extension) async {
    while (true) {
      final name = AttachmentName.generate(_clock(), extension);
      if (await _store.readAttachment(name) == null) return name;
    }
  }
}
