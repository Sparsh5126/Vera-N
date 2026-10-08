import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/styles/app_styles.dart';
import '../drawing/drawing.dart';
import '../drawing/drawing_painter.dart';
import '../drawing/drawing_svg.dart';
import 'embed_missing.dart';

/// A drawing in the note, drawn from its vector lines in the theme's ink
/// on a plate, so it is sharp at any size and reads in light and dark.
/// Tapping reopens it for more drawing.
class DrawingEmbed extends ConsumerWidget {
  const DrawingEmbed({super.key, required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(attachmentBytesProvider(name));
    if (bytes.isLoading) {
      return const SizedBox(height: AppSize.minTapTarget);
    }
    final data = bytes.value;
    final drawing = data == null
        ? null
        : DrawingSvg.decode(utf8.decode(data, allowMalformed: true));
    if (drawing == null || drawing.size.isEmpty) return const EmbedMissing();
    return Semantics(
      image: true,
      button: true,
      label: AppCopy.drawing,
      hint: AppCopy.editDrawing,
      child: GestureDetector(onTap: onTap, child: _plate(context, drawing)),
    );
  }

  Widget _plate(BuildContext context, Drawing drawing) {
    final colors = context.colors;
    final ratio = drawing.size.width / drawing.size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: AppSize.embedMaxHeight,
        maxWidth: AppSize.embedMaxHeight * ratio,
      ),
      child: AspectRatio(
        aspectRatio: ratio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: AppRadius.cardBorder,
            border: Border.all(color: colors.border),
          ),
          child: CustomPaint(
            painter: DrawingPainter(drawing: drawing, ink: colors.text),
          ),
        ),
      ),
    );
  }
}
