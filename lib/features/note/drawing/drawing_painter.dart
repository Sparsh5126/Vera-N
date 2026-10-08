import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import 'drawing.dart';

/// Paints a drawing's lines in [ink], scaled from the drawing's canvas to
/// the space it is given.
class DrawingPainter extends CustomPainter {
  DrawingPainter({
    required this.drawing,
    required this.ink,
    this.current,
    this.framed = false,
  });

  final Drawing drawing;
  final Color ink;

  /// The line being drawn right now, if any.
  final List<Offset>? current;

  /// Show just the drawn lines, scaled to fit and centred (a preview),
  /// instead of the whole canvas.
  final bool framed;

  @override
  void paint(Canvas canvas, Size size) {
    final from = framed ? _linesBounds() : Offset.zero & drawing.size;
    if (!from.isEmpty) {
      final scale = min(size.width / from.width, size.height / from.height);
      canvas
        ..translate(
          (size.width - from.width * scale) / 2,
          (size.height - from.height * scale) / 2,
        )
        ..scale(scale)
        ..translate(-from.left, -from.top);
    }
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

  /// The area the lines cover, with room around them.
  Rect _linesBounds() {
    final points = [for (final s in drawing.strokes) ...s];
    if (points.isEmpty) return Offset.zero & drawing.size;
    var r = Rect.fromPoints(points.first, points.first);
    for (final p in points) {
      r = r.expandToInclude(Rect.fromPoints(p, p));
    }
    // A square around the lines, so a single stroke isn't blown up flat.
    final side = max(max(r.width, r.height), AppSize.embedSize / 2);
    return Rect.fromCenter(
      center: r.center,
      width: side,
      height: side,
    ).inflate(AppSpace.l);
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
      old.drawing != drawing ||
      old.ink != ink ||
      old.current != current ||
      old.framed != framed;
}
