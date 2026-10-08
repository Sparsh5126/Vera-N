import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A drawing: the lines drawn and the canvas they were drawn on. Saved as
/// an SVG (see `DrawingSvg`), so it can be drawn on again.
@immutable
class Drawing {
  const Drawing({required this.size, required this.strokes});

  static const empty = Drawing(size: Size.zero, strokes: []);

  /// The canvas the points are measured on.
  final Size size;

  /// Each line as the points the finger passed through.
  final List<List<Offset>> strokes;

  bool get isEmpty => strokes.isEmpty;

  Drawing withStroke(List<Offset> stroke) =>
      Drawing(size: size, strokes: [...strokes, stroke]);

  Drawing withoutLast() => Drawing(
    size: size,
    strokes: strokes.isEmpty ? strokes : strokes.sublist(0, strokes.length - 1),
  );

  Drawing withoutAll() => Drawing(size: size, strokes: const []);

  /// The same lines on a canvas of [target] size, scaled evenly to fit
  /// and centred, so reopening on another screen keeps the shape.
  Drawing fittedTo(Size target) {
    if (size.isEmpty || size == target) {
      return Drawing(size: target, strokes: strokes);
    }
    final scale = min(target.width / size.width, target.height / size.height);
    final shift = Offset(
      (target.width - size.width * scale) / 2,
      (target.height - size.height * scale) / 2,
    );
    return Drawing(
      size: target,
      strokes: [
        for (final s in strokes) [for (final p in s) p * scale + shift],
      ],
    );
  }
}
