import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/attachment_capture.dart';
import '../../../core/storage/storage_providers.dart';
import '../state/attachment_insert.dart';
import 'attach_flow.dart';
import 'attachment_embed.dart';
import 'photo_viewer.dart';
import 'titled_text_controller.dart';

/// A note's attachments (UI spec §7): attaching one and putting it in at
/// the cursor, drawing each inside the text, and reopening a drawing.
class NoteAttachments {
  NoteAttachments({
    required this.ref,
    required this.text,
    required this.mounted,
    required this.onEdited,
  });

  final WidgetRef ref;
  final TitledTextController? Function() text;
  final bool Function() mounted;
  final ValueChanged<String> onEdited;

  late final _flow = AttachFlow(
    capture: ref.read(attachmentCaptureProvider),
    attachments: ref.read(attachmentsRepositoryProvider),
    onAttached: _insert,
    // A drawing drawn on again shows its new lines.
    onDrawingSaved: (name) => ref.invalidate(attachmentBytesProvider(name)),
  );

  void choose(BuildContext context) => unawaited(_flow.choose(context));

  Widget embed(BuildContext context, String name) => AttachmentEmbed(
    name: name,
    onOpenPhoto: (n) => unawaited(PhotoViewer.open(context, n)),
    onEditDrawing: (n) => unawaited(_flow.editDrawing(context, n)),
  );

  /// The new attachment goes where the cursor is, on its own line.
  void _insert(String name) {
    final text = this.text();
    if (text == null || !mounted()) return;
    text.value = AttachmentInsert.insert(text.value, name);
    onEdited(text.text);
  }
}
