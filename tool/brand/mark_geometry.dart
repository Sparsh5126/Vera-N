// Geometry of the Vera N mark: two strokes, two notes, meeting in one drop
// of ink. Every point comes from the rules below, so the mark can be redrawn
// exactly; docs/brand/preview.html draws the rules over it.
//
// 1. The V's outer contour is an inverted equilateral triangle, so both
//    strokes run at 60° to the baseline.
// 2. Terminals are cut flat, on the triangle's top edge.
// 3. The left stroke is the heavy one, 4 : 3 against the right, like a pen's
//    down-stroke and up-stroke.
// 4. Each stroke keeps its weight down most of its length, then narrows
//    to a neck where the two meet.
// 5. The drop's diameter is the light stroke's top width. It hangs just
//    below the apex, where the two strokes meet.
import 'dart:math' as math;

typedef P = math.Point<double>;

class MarkRules {
  static const apexX = 60.0;
  static const topY = 20.0;
  static const height = 80.0;
  static const strokeAngle = math.pi / 3;
  static const lightRatio = 3 / 4;
}

/// One drawing of the mark. Widths are measured across the stroke.
class MarkCut {
  const MarkCut({
    required this.name,
    required this.heavyWidth,
    required this.neck,
    required this.fullness,
    required this.dropDip,
  });

  final String name;

  /// The heavy stroke's width at its terminal.
  final double heavyWidth;

  /// Each stroke's width where it meets the other.
  final double neck;

  /// How far each inner edge bulges out, as a share of the stroke's width,
  /// so the stroke holds its weight before it narrows.
  final double fullness;

  /// How far the drop's centre sits below the apex.
  final double dropDip;

  double get lightWidth => heavyWidth * MarkRules.lightRatio;
  double get dropRadius => lightWidth / 2;

  /// For sizes from about 96 px up: the wordmark, print, the splash.
  static const primary = MarkCut(
    name: 'primary',
    heavyWidth: 12,
    neck: 1.4,
    fullness: 0.3,
    dropDip: 2,
  );

  /// For the launcher icon and anything under about 96 px: heavier, with a
  /// neck wide enough to survive 24 px.
  static const icon = MarkCut(
    name: 'icon',
    heavyWidth: 16,
    neck: 4.5,
    fullness: 0.2,
    dropDip: 1.5,
  );
}

class MarkShape {
  MarkShape(this.cut);

  final MarkCut cut;

  static final halfTop = MarkRules.height / math.tan(MarkRules.strokeAngle);
  static const apex = P(MarkRules.apexX, MarkRules.topY + MarkRules.height);

  /// The triangle's top corner on [side]: 1 is left, -1 is right.
  static P corner(int side) =>
      P(MarkRules.apexX - side * halfTop, MarkRules.topY);

  P get dropCentre => P(apex.x, apex.y + cut.dropDip);

  double get left => corner(1).x;
  double get right => corner(-1).x;
  double get top => MarkRules.topY;
  double get bottom => dropCentre.y + cut.dropRadius;
  double get width => right - left;
  double get height => bottom - top;

  /// The stroke's top terminal on its inner side.
  P innerTop(int side) {
    final width = side == 1 ? cut.heavyWidth : cut.lightWidth;
    final across = width / math.sin(MarkRules.strokeAngle);
    return P(corner(side).x + side * across, MarkRules.topY);
  }

  /// The stroke on [side]: 1 is the heavy left one, -1 the light right one.
  String strokePath(int side) {
    final width = side == 1 ? cut.heavyWidth : cut.lightWidth;
    final outer = corner(side);
    final length = outer.distanceTo(apex);
    final along = P((apex.x - outer.x) / length, (apex.y - outer.y) / length);
    final inward = P(side * along.y, -side * along.x);
    final start = innerTop(side);
    final end = apex + inward * cut.neck;
    final mid = P((start.x + end.x) / 2, (start.y + end.y) / 2);
    // A quadratic curve's midpoint lies halfway to its control point.
    final control = mid + inward * (cut.fullness * (width + cut.neck));
    return 'M${pt(outer)} L${pt(start)} '
        'Q${pt(control)} ${pt(end)} L${pt(apex)} Z';
  }

  /// The drop as a path, for formats with no circle (Android vectors).
  String dropPath() {
    final c = dropCentre;
    final r = fmt(cut.dropRadius);
    return 'M${fmt(c.x - cut.dropRadius)},${fmt(c.y)} '
        'A$r,$r 0 1,0 ${fmt(c.x + cut.dropRadius)},${fmt(c.y)} '
        'A$r,$r 0 1,0 ${fmt(c.x - cut.dropRadius)},${fmt(c.y)} Z';
  }

  /// The mark as SVG elements with no fill of their own, so they take the
  /// fill of whatever uses them.
  String elements() =>
      '<path d="${strokePath(1)}"/>'
      '<path d="${strokePath(-1)}"/>'
      '<circle cx="${fmt(dropCentre.x)}" cy="${fmt(dropCentre.y)}" '
      'r="${fmt(cut.dropRadius)}"/>';

  String get viewBox => '${fmt(left)} ${fmt(top)} ${fmt(width)} ${fmt(height)}';
}

/// Places a cut on Android's 108 dp adaptive-icon canvas: 48 dp wide, with
/// the point 42% down the mark on the canvas centre, since a V carries its
/// weight high. All of it must sit inside the 66 dp safe circle.
class IconPlacement {
  IconPlacement(this.shape) {
    final worst = [
      MarkShape.corner(1),
      MarkShape.corner(-1),
      P(shape.dropCentre.x, shape.bottom),
    ].map((p) => map(p).distanceTo(const P(centre, centre))).reduce(math.max);
    if (worst > safeRadius) {
      throw StateError(
        '${shape.cut.name} reaches $worst dp from the centre, '
        'outside the $safeRadius dp safe circle',
      );
    }
    reach = worst;
  }

  static const canvas = 108.0;
  static const centre = canvas / 2;
  static const safeRadius = 33.0;
  static const markWidth = 48.0;
  static const opticalCentre = 0.42;

  final MarkShape shape;

  /// The farthest any part of the mark gets from the canvas centre, in dp.
  late final double reach;

  double get scale => markWidth / shape.width;
  double get dx => centre - (shape.left + shape.width / 2) * scale;
  double get dy => centre - (shape.top + opticalCentre * shape.height) * scale;

  P map(P p) => P(dx + p.x * scale, dy + p.y * scale);

  String get transform =>
      'translate(${fmt(dx)} ${fmt(dy)}) scale(${fmt(scale, 4)})';
}

String pt(P p) => '${fmt(p.x)},${fmt(p.y)}';

String fmt(double v, [int digits = 2]) {
  final s = v.toStringAsFixed(digits);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}
