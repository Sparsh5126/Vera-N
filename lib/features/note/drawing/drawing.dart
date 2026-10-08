import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A drawing: the lines drawn and the canvas they were drawn on. Saved as
/// `<id>.drawing.json` next to its picture, so it can be drawn on again.
@immutable
class Drawing {
  const Drawing({required this.size, required this.strokes});

  static const empty = Drawing(size: Size.zero, strokes: []);
  static const _version = 1;

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

  String toJson() => jsonEncode({
    'version': _version,
    'width': _round(size.width),
    'height': _round(size.height),
    'strokes': [
      for (final s in strokes)
        [
          for (final p in s) ...[_round(p.dx), _round(p.dy)],
        ],
    ],
  });

  /// Null if [json] isn't a drawing this app can read.
  static Drawing? fromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      final strokes = [
        for (final s in map['strokes']! as List<Object?>)
          _points((s! as List<Object?>).cast<num>()),
      ];
      final size = Size(
        (map['width']! as num).toDouble(),
        (map['height']! as num).toDouble(),
      );
      return Drawing(size: size, strokes: strokes);
    } on Object {
      return null;
    }
  }

  static List<Offset> _points(List<num> flat) => [
    for (var i = 0; i + 1 < flat.length; i += 2)
      Offset(flat[i].toDouble(), flat[i + 1].toDouble()),
  ];

  /// One decimal is finer than a finger, and keeps the file small.
  static num _round(double v) => (v * 10).round() / 10;
}
