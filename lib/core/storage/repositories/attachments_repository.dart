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

  /// Saves a new drawing: the picture and its strokes. Returns its name.
  Future<String> addDrawing(Uint8List png, String strokes) async {
    final name = await _freeName(AttachmentName.drawingExtension);
    await saveDrawing(name, png, strokes);
    return name;
  }

  /// Writes drawing [name] again after more drawing.
  Future<void> saveDrawing(String name, Uint8List png, String strokes) async {
    await _store.writeAttachment(
      AttachmentName.strokesOf(name),
      utf8.encode(strokes),
    );
    await _store.writeAttachment(name, png);
  }

  Future<Uint8List?> read(String name) => _store.readAttachment(name);

  /// The strokes of drawing [name], or null if it has none (a drawing
  /// made elsewhere).
  Future<String?> strokes(String name) async {
    final bytes = await _store.readAttachment(AttachmentName.strokesOf(name));
    return bytes == null ? null : utf8.decode(bytes);
  }

  Future<String> _freeName(String extension) async {
    while (true) {
      final name = AttachmentName.generate(_clock(), extension);
      if (await _store.readAttachment(name) == null) return name;
    }
  }
}
