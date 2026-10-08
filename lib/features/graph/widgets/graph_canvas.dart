import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/models/suggestion.dart';
import '../../../core/styles/app_styles.dart';
import '../state/graph_controller.dart';
import 'graph_painter.dart';

/// The graph with pan and pinch zoom. Starts centred, zoomed out just
/// enough to fit (again whenever its size changes). A tap on a dot selects
/// it, on a dashed line opens that suggestion, elsewhere clears the
/// selection. A new [centerRequest] centres on [selected].
class GraphCanvas extends StatefulWidget {
  const GraphCanvas({
    super.key,
    required this.picture,
    required this.selected,
    required this.centerRequest,
    required this.onSelect,
    required this.onSuggestion,
  });

  final GraphPicture picture;
  final int? selected;
  final int centerRequest;
  final ValueChanged<int?> onSelect;
  final ValueChanged<Suggestion> onSuggestion;

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  final _transform = TransformationController();
  final _zoom = ValueNotifier<double>(1);
  double? _fittedSide;
  Size _view = Size.zero;

  @override
  void initState() {
    super.initState();
    _transform.addListener(
      () => _zoom.value = _transform.value.getMaxScaleOnAxis(),
    );
    // Arriving with a note picked (the search jump from folder bubbles).
    if (widget.selected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _center());
    }
  }

  @override
  void didUpdateWidget(GraphCanvas old) {
    super.didUpdateWidget(old);
    if (widget.centerRequest != old.centerRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _center());
    }
  }

  @override
  void dispose() {
    _transform.dispose();
    _zoom.dispose();
    super.dispose();
  }

  /// The graph's side: room for every note, so a few notes stay close
  /// together instead of spreading to the screen's edges.
  double get _side =>
      AppSize.graphSpacing * max(sqrt(widget.picture.positions.length), 2);

  void _place(double scale, Offset point) {
    final at = Offset(_view.width / 2, _view.height / 2) - point * scale;
    _transform.value = Matrix4.identity()
      ..translateByDouble(at.dx, at.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  void _fit(double side) {
    if (_fittedSide == side) return;
    _fittedSide = side;
    // Zoom out only if the graph doesn't fit; never blow small ones up.
    final scale = min(1.0, _view.shortestSide / side);
    _place(scale, Offset(side / 2, side / 2));
  }

  /// Centres on the selected dot, zoomed in enough to read titles.
  void _center() {
    final p = widget.picture.positions[widget.selected];
    if (p == null || !mounted) return;
    final scale = max(_zoom.value, AppSize.graphTitleZoom);
    _place(scale, Offset(p.x * _side, p.y * _side));
  }

  Offset _at(int ref, double side) {
    final p = widget.picture.positions[ref]!;
    return Offset(p.x * side, p.y * side);
  }

  void _tap(Offset local, double side) {
    final reach = max(
      AppSize.minTapTarget / 2 / _zoom.value,
      AppSize.graphDotMax,
    );
    int? dot;
    var best = double.infinity;
    for (final ref in widget.picture.nodes.keys) {
      final d = (_at(ref, side) - local).distance;
      if (d < best) (dot, best) = (ref, d);
    }
    if (best <= reach) return widget.onSelect(dot);
    for (final s in widget.picture.suggested) {
      if (_toSegment(local, _at(s.noteA, side), _at(s.noteB, side)) <= reach) {
        return widget.onSuggestion(s);
      }
    }
    widget.onSelect(null);
  }

  static double _toSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final length2 = ab.distanceSquared;
    if (length2 == 0) return (p - a).distance;
    final ap = p - a;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / length2).clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _view = constraints.biggest;
        final side = _side;
        _fit(side);
        return InteractiveViewer(
          transformationController: _transform,
          constrained: false,
          boundaryMargin: EdgeInsets.all(max(side, _view.longestSide)),
          minScale: AppSize.graphMinZoom,
          maxScale: AppSize.graphMaxZoom,
          child: GestureDetector(
            onTapUp: (d) => _tap(d.localPosition, side),
            child: CustomPaint(
              size: Size.square(side),
              painter: GraphPainter(
                picture: widget.picture,
                zoom: _zoom,
                selected: widget.selected,
                colors: context.colors,
                titleStyle: context.textStyles.small.copyWith(
                  color: context.colors.text,
                ),
                onSelect: widget.onSelect,
                onSuggestion: widget.onSuggestion,
              ),
            ),
          ),
        );
      },
    );
  }
}
