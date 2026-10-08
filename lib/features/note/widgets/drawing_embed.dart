import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/styles/app_styles.dart';
import '../drawing/drawing.dart';
import '../drawing/drawing_painter.dart';
import 'photo_embed.dart';

/// A drawing in the note, drawn from its strokes in the theme's ink on a
/// plate, so it reads in light and dark. Tapping reopens it for more
/// drawing. One made elsewhere (no strokes file) shows as its picture.
class DrawingEmbed extends ConsumerWidget {
  const DrawingEmbed({super.key, required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokes = ref.watch(drawingStrokesProvider(name));
    if (strokes.isLoading) {
      return const SizedBox(height: AppSize.minTapTarget);
    }
    final json = strokes.value;
    final drawing = json == null ? null : Drawing.fromJson(json);
    if (drawing == null || drawing.size.isEmpty) {
      return PhotoEmbed(name: name, onTap: onTap);
    }
    final colors = context.colors;
    return Semantics(
      image: true,
      button: true,
      label: AppCopy.drawing,
      hint: AppCopy.editDrawing,
      child: GestureDetector(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: AppSize.embedMaxHeight,
            maxWidth:
                AppSize.embedMaxHeight *
                drawing.size.width /
                drawing.size.height,
          ),
          child: AspectRatio(
            aspectRatio: drawing.size.width / drawing.size.height,
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
        ),
      ),
    );
  }
}
