import 'dart:math';

import '../../models/attachment_kind.dart';
import 'note_id.dart';

/// Attachment file names in `MyNotes/Attachments/`: a note id plus the
/// file's extension, e.g. `20261008-183000-a7f3.jpg`, never renamed.
///
/// A drawing is `<id>.drawing.png`, a picture any app can open, with its
/// strokes beside it in `<id>.drawing.json` so the app can reopen it for
/// more drawing.
abstract final class AttachmentName {
  static const photoExtension = '.jpg';
  static const drawingExtension = '.drawing.png';
  static const strokesExtension = '.drawing.json';
  static const voiceExtension = '.m4a';

  static const _photos = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.heic'];
  static const _voices = ['.m4a', '.aac', '.mp3', '.ogg', '.wav', '.opus'];

  /// A new name for a file made at [createdLocal] with [extension].
  static String generate(
    DateTime createdLocal,
    String extension, {
    Random? random,
  }) => '${NoteId.generate(createdLocal, random: random)}$extension';

  /// What [name] holds, from its extension; null for other files.
  static AttachmentKind? kindOf(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith(drawingExtension)) return AttachmentKind.drawing;
    if (_photos.any(lower.endsWith)) return AttachmentKind.photo;
    if (_voices.any(lower.endsWith)) return AttachmentKind.voice;
    return null;
  }

  /// The strokes file of drawing [name].
  static String strokesOf(String name) =>
      '${name.substring(0, name.length - drawingExtension.length)}'
      '$strokesExtension';

  /// [name] and the files that belong with it (a drawing's strokes).
  static List<String> withCompanions(String name) =>
      kindOf(name) == AttachmentKind.drawing ? [name, strokesOf(name)] : [name];
}
