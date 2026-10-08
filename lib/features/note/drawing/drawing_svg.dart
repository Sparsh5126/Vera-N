import 'dart:ui';

import '../../../core/styles/app_styles.dart';
import 'drawing.dart';

/// A drawing as an SVG file: one path per line, so it stays sharp at any
/// size and opens in any app (printed in light ink on a light plate,
/// whatever the app's theme). The app reads its own SVGs back, line by
/// line, to keep drawing.
abstract final class DrawingSvg {
  static final _viewBox = RegExp(r'viewBox="0 0 ([\d.]+) ([\d.]+)"');
  static final _path = RegExp(r'<path d="([^"]*)"');
  static final _number = RegExp(r'-?[\d.]+');

  static String encode(Drawing drawing) {
    const paper = AppPalette.light;
    final w = _n(drawing.size.width), h = _n(drawing.size.height);
    final lines = StringBuffer();
    for (final stroke in drawing.strokes) {
      if (stroke.isEmpty) continue;
      // A single tap is a dot: a line to the same point, drawn round.
      final points = stroke.length == 1 ? [stroke.first, stroke.first] : stroke;
      final d = [
        for (var i = 0; i < points.length; i++)
          '${i == 0 ? 'M' : 'L'}${_n(points[i].dx)} ${_n(points[i].dy)}',
      ].join(' ');
      lines.writeln('  <path d="$d"/>');
    }
    return '<svg xmlns="http://www.w3.org/2000/svg" '
        'viewBox="0 0 $w $h" width="$w" height="$h">\n'
        '  <rect width="$w" height="$h" fill="${_hex(paper.card)}"/>\n'
        '  <g fill="none" stroke="${_hex(paper.text)}" '
        'stroke-width="${_n(AppSize.drawingStroke)}" '
        'stroke-linecap="round" stroke-linejoin="round">\n'
        '$lines  </g>\n</svg>\n';
  }

  /// The lines of an SVG this app wrote; null for any other SVG (curves
  /// and shapes from other apps can't be drawn on).
  static Drawing? decode(String svg) {
    final box = _viewBox.firstMatch(svg);
    if (box == null) return null;
    final size = Size(double.parse(box.group(1)!), double.parse(box.group(2)!));
    final strokes = <List<Offset>>[];
    for (final m in _path.allMatches(svg)) {
      final d = m.group(1)!;
      if (RegExp('[^ML0-9. -]').hasMatch(d)) return null;
      final values = [
        for (final n in _number.allMatches(d)) double.parse(n.group(0)!),
      ];
      final points = [
        for (var i = 0; i + 1 < values.length; i += 2)
          Offset(values[i], values[i + 1]),
      ];
      final dot = points.length == 2 && points.first == points.last;
      strokes.add(dot ? [points.first] : points);
    }
    return Drawing(size: size, strokes: strokes);
  }

  /// One decimal is finer than a finger, and keeps the file small.
  static String _n(double v) {
    final r = (v * 10).round() / 10;
    return r == r.roundToDouble() ? r.toInt().toString() : r.toString();
  }

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
