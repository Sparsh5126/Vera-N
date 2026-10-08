import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import 'drawing.dart';

/// Paints a drawing's lines in [ink], scaled from the drawing's canvas to
/// the space it is given.
class DrawingPainter extends CustomPainter {
  DrawingPainter({required this.drawing, required this.ink, this.current});

  final Drawing drawing;
  final Color ink;

  /// The line being drawn right now, if any.
  final List<Offset>? current;

  @override
  void paint(Canvas canvas, Size size) {
    final from = drawing.size;
    final scale = from.isEmpty ? 1.0 : size.width / from.width;
    canvas.scale(scale);
    final pen = Paint()
      ..color = ink
      ..strokeWidth = AppSize.drawingStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in [...drawing.strokes, ?current]) {
      _line(canvas, stroke, pen);
    }
  }

  static void _line(Canvas canvas, List<Offset> points, Paint pen) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      canvas.drawPoints(ui.PointMode.points, points, pen);
      return;
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, pen);
  }

  @override
  bool shouldRepaint(DrawingPainter old) =>
      old.drawing != drawing || old.ink != ink || old.current != current;
}
