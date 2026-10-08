import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import '../state/graph_bubbles.dart';
import '../state/graph_layout.dart';
import 'graph_bubble.dart';

/// A very large library as folder bubbles (UI spec §10), with pan and
/// pinch zoom like the dots. Bubble area grows with the note count; a
/// solid line joins two folders whose notes link. Tapping a bubble picks
/// that folder, which shows its notes as dots.
class GraphBubbleView extends StatefulWidget {
  const GraphBubbleView({
    super.key,
    required this.bubbles,
    required this.positions,
    required this.onFolder,
  });

  final GraphBubbles bubbles;
  final GraphPositions positions;
  final ValueChanged<String> onFolder;

  @override
  State<GraphBubbleView> createState() => _GraphBubbleViewState();
}

class _GraphBubbleViewState extends State<GraphBubbleView> {
  final _transform = TransformationController();
  double? _fittedSide;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  /// The bubbles' area, with room for the largest bubble on every side so
  /// none is cut off at the edge.
  double get _side =>
      AppSize.graphBubbleSpacing * max(sqrt(widget.bubbles.bubbles.length), 2) +
      AppSize.graphBubbleMax * 2;

  double _radius(int count) {
    final most = widget.bubbles.bubbles.first.count;
    final share = sqrt(count / most);
    return AppSize.graphBubbleMin +
        (AppSize.graphBubbleMax - AppSize.graphBubbleMin) * share;
  }

  /// Zooms out only if the bubbles don't fit; centred.
  void _fit(Size view, double side) {
    if (_fittedSide == side) return;
    _fittedSide = side;
    final scale = min(1.0, view.shortestSide / side);
    final at =
        Offset(view.width / 2, view.height / 2) -
        Offset(side / 2, side / 2) * scale;
    _transform.value = Matrix4.identity()
      ..translateByDouble(at.dx, at.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  Offset _at(int i, double side) {
    final p = widget.positions[i]!;
    const edge = AppSize.graphBubbleMax;
    final inner = side - edge * 2;
    return Offset(edge + p.x * inner, edge + p.y * inner);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _side;
        _fit(constraints.biggest, side);
        return InteractiveViewer(
          transformationController: _transform,
          constrained: false,
          boundaryMargin: EdgeInsets.all(
            max(side, constraints.biggest.longestSide),
          ),
          minScale: AppSize.graphMinZoom,
          maxScale: AppSize.graphMaxZoom,
          child: SizedBox.square(
            dimension: side,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LinksPainter(
                      lines: [
                        for (final (a, b) in widget.bubbles.links)
                          (_at(a, side), _at(b, side)),
                      ],
                      color: context.colors.border,
                    ),
                  ),
                ),
                for (final (i, b) in widget.bubbles.bubbles.indexed)
                  _bubble(i, b, side),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bubble(int i, FolderBubble b, double side) {
    final r = _radius(b.count);
    final c = _at(i, side);
    return Positioned(
      left: c.dx - r,
      top: c.dy - r,
      child: GraphBubble(
        folder: b.folder,
        count: b.count,
        radius: r,
        onTap: () => widget.onFolder(b.folder),
      ),
    );
  }
}

/// The lines between folders whose notes link.
class _LinksPainter extends CustomPainter {
  _LinksPainter({required this.lines, required this.color});

  final List<(Offset, Offset)> lines;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = AppSize.graphLine;
    for (final (a, b) in lines) {
      canvas.drawLine(a, b, paint);
    }
  }

  @override
  bool shouldRepaint(_LinksPainter old) =>
      old.color != color || !listEquals(old.lines, lines);
}
