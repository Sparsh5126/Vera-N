import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/attachment_capture.dart';
import '../../../core/storage/files/attachment_name.dart';
import '../../../core/storage/repositories/attachments_repository.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import '../../../shared/widgets/option_sheet.dart';
import '../drawing/drawing.dart';
import '../drawing/drawing_painter.dart';
import '../drawing/drawing_screen.dart';
import 'voice_recorder_sheet.dart';

/// The ways to attach (UI spec §7).
enum AttachChoice { gallery, camera, voice, drawing }

/// Attach: pick how, capture it, save it in `Attachments/`, then hand its
/// name to [onAttached] to put in the note. Also reopens a drawing.
class AttachFlow {
  AttachFlow({
    required this.capture,
    required this.attachments,
    required this.onAttached,
    required this.onDrawingSaved,
  });

  final AttachmentCapture capture;
  final AttachmentsRepository attachments;
  final ValueChanged<String> onAttached;

  /// A drawing was drawn on again: its preview should refresh.
  final ValueChanged<String> onDrawingSaved;

  Future<void> choose(BuildContext context) async {
    final picked = await OptionSheet.show<AttachChoice>(
      context,
      selected: null,
      options: const [
        SheetOption(AttachChoice.gallery, AppCopy.attachPhoto),
        SheetOption(AttachChoice.camera, AppCopy.attachCamera),
        SheetOption(AttachChoice.voice, AppCopy.attachVoice),
        SheetOption(AttachChoice.drawing, AppCopy.attachDrawing),
      ],
    );
    final choice = picked?.value;
    if (choice == null || !context.mounted) return;
    await _guarded(context, () => _capture(context, choice));
  }

  Future<String?> _capture(BuildContext context, AttachChoice choice) async {
    switch (choice) {
      case AttachChoice.gallery:
      case AttachChoice.camera:
        final photo = await capture.photo(
          camera: choice == AttachChoice.camera,
        );
        if (photo == null) return null;
        return attachments.add(photo.bytes, photo.extension);
      case AttachChoice.voice:
        final bytes = await VoiceRecorderSheet.show(context, capture);
        if (bytes == null || bytes.isEmpty) return null;
        return attachments.add(bytes, AttachmentName.voiceExtension);
      case AttachChoice.drawing:
        final drawing = await DrawingScreen.open(context);
        if (drawing == null || drawing.isEmpty) return null;
        return attachments.addDrawing(await _png(drawing), drawing.toJson());
    }
  }

  /// Tapping a drawing opens it to keep drawing; Save writes it again.
  Future<void> editDrawing(BuildContext context, String name) async {
    final json = await attachments.strokes(name);
    final initial = json == null ? null : Drawing.fromJson(json);
    if (!context.mounted) return;
    final drawing = await DrawingScreen.open(context, initial: initial);
    if (drawing == null || drawing.isEmpty) return;
    await attachments.saveDrawing(name, await _png(drawing), drawing.toJson());
    onDrawingSaved(name);
  }

  static Future<Uint8List> _png(Drawing d) => DrawingPainter.png(d);

  /// Device trouble (no camera app, storage full) is said plainly.
  Future<void> _guarded(
    BuildContext context,
    Future<String?> Function() attach,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final name = await attach();
      if (name != null) onAttached(name);
    } on PlatformException {
      NoticeSnackBar.show(messenger, AppCopy.attachFailed);
    }
  }
}
