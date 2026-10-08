import 'package:flutter/material.dart';

import '../../../core/models/attachment_kind.dart';
import '../../../core/storage/files/attachment_name.dart';
import 'drawing_embed.dart';
import 'photo_embed.dart';
import 'voice_embed.dart';

/// An attachment drawn inside the note's text, in place of its
/// `![](Attachments/name)` line: a photo, a drawing or a voice note.
class AttachmentEmbed extends StatelessWidget {
  const AttachmentEmbed({
    super.key,
    required this.name,
    required this.onOpenPhoto,
    required this.onEditDrawing,
  });

  final String name;
  final ValueChanged<String> onOpenPhoto;
  final ValueChanged<String> onEditDrawing;

  @override
  Widget build(BuildContext context) {
    return switch (AttachmentName.kindOf(name)) {
      AttachmentKind.drawing => DrawingEmbed(
        name: name,
        onTap: () => onEditDrawing(name),
      ),
      AttachmentKind.voice => VoiceEmbed(name: name),
      // A photo, or any other file: shown as a picture if it is one.
      _ => PhotoEmbed(name: name, onTap: () => onOpenPhoto(name)),
    };
  }
}
