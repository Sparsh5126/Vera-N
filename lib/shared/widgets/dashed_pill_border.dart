import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// Paints a dashed stadium outline: the mark of an AI suggestion, so its
/// meaning never relies on color alone.
class DashedPillBorder extends CustomPainter {
  const DashedPillBorder({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = AppBorder.width / 2;
    final rect = (Offset.zero & size).deflate(inset);
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppBorder.width;
    for (final metric in outline.computeMetrics()) {
      for (
        var d = 0.0;
        d < metric.length;
        d += AppBorder.dashLength + AppBorder.dashGap
      ) {
        canvas.drawPath(metric.extractPath(d, d + AppBorder.dashLength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedPillBorder old) => old.color != color;
}
