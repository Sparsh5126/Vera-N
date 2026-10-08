import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/suggestion.dart';
import '../../../core/styles/app_styles.dart';
import '../state/graph_controller.dart';

/// Draws the graph: solid lines for confirmed links, one dot per note
/// (bigger with more links), dashed seal lines for suggestions when
/// shown, and titles once zoomed in. Each dot is also
/// a screen-reader item that selects it, since a drawing can't be read.
class GraphPainter extends CustomPainter {
  GraphPainter({
    required this.picture,
    required this.zoom,
    required this.selected,
    required this.colors,
    required this.titleStyle,
    required this.onSelect,
    required this.onSuggestion,
  }) : super(repaint: zoom);

  final GraphPicture picture;

  /// The current zoom; titles show from [AppSize.graphTitleZoom].
  final ValueNotifier<double> zoom;
  final int? selected;
  final AppPalette colors;
  final TextStyle titleStyle;
  final ValueChanged<int> onSelect;
  final ValueChanged<Suggestion> onSuggestion;

  static double radiusFor(int links) => min(
    AppSize.graphDot + max(links - 1, 0) * AppSize.graphDotStep,
    AppSize.graphDotMax,
  );

  Offset _at(int ref, Size size) {
    final p = picture.positions[ref]!;
    return Offset(p.x * size.width, p.y * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = colors.border
      ..strokeWidth = AppSize.graphLine / zoom.value;
    final near = Paint()
      ..color = colors.accent
      ..strokeWidth = AppSize.graphLine * 2 / zoom.value;
    for (final e in picture.edges) {
      if (!picture.positions.containsKey(e.a) ||
          !picture.positions.containsKey(e.b)) {
        continue;
      }
      final touches = e.a == selected || e.b == selected;
      canvas.drawLine(_at(e.a, size), _at(e.b, size), touches ? near : line);
    }
    _suggested(canvas, size);
    final dot = Paint()
      ..color = picture.inFolder ? colors.folder : colors.accent;
    final dim = Paint()..color = colors.textSecondary;
    final showTitles = zoom.value >= AppSize.graphTitleZoom;
    for (final ref in picture.nodes.keys) {
      final at = _at(ref, size);
      final links = picture.degrees[ref] ?? 0;
      final r = radiusFor(links);
      canvas.drawCircle(at, r, links == 0 ? dim : dot);
      if (ref == selected) {
        canvas.drawCircle(
          at,
          r + AppSpace.xs,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = colors.text
            ..strokeWidth = AppSize.graphLine,
        );
      }
      if (showTitles) _title(canvas, picture.nodes[ref]!.title, at, r);
    }
  }

  /// Waiting suggestions: seal-coloured and dashed, so they never read as
  /// links (the user's confirmed links are solid ink).
  void _suggested(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.seal
      ..strokeWidth = AppSize.graphLine / zoom.value;
    final dash = AppBorder.dashLength * 2 / zoom.value;
    final gap = AppBorder.dashGap * 2 / zoom.value;
    for (final s in picture.suggested) {
      final from = _at(s.noteA, size);
      final to = _at(s.noteB, size);
      final length = (to - from).distance;
      if (length == 0) continue;
      final step = (to - from) / length;
      for (var d = 0.0; d < length; d += dash + gap) {
        canvas.drawLine(
          from + step * d,
          from + step * min(d + dash, length),
          paint,
        );
      }
    }
  }

  void _title(Canvas canvas, String title, Offset at, double r) {
    final text = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: AppSize.pinnedCardWidth);
    text.paint(canvas, at + Offset(-text.width / 2, r + AppSpace.xs));
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder =>
      (size) => [
        for (final s in picture.suggested)
          CustomPainterSemantics(
            rect: Rect.fromCircle(
              center: (_at(s.noteA, size) + _at(s.noteB, size)) / 2,
              radius: AppSize.minTapTarget / 2,
            ),
            properties: SemanticsProperties(
              label: AppCopy.suggestedLinkBetween(
                picture.nodes[s.noteA]!.title,
                picture.nodes[s.noteB]!.title,
              ),
              button: true,
              onTap: () => onSuggestion(s),
              textDirection: TextDirection.ltr,
            ),
          ),
        for (final ref in picture.nodes.keys)
          CustomPainterSemantics(
            rect: Rect.fromCircle(
              center: _at(ref, size),
              radius: AppSize.minTapTarget / 2,
            ),
            properties: SemanticsProperties(
              label: AppCopy.graphDot(
                picture.nodes[ref]!.title,
                picture.degrees[ref] ?? 0,
              ),
              selected: ref == selected,
              button: true,
              onTap: () => onSelect(ref),
              textDirection: TextDirection.ltr,
            ),
          ),
      ];

  @override
  bool shouldRepaint(GraphPainter oldDelegate) =>
      oldDelegate.picture != picture ||
      oldDelegate.selected != selected ||
      oldDelegate.colors != colors;

  @override
  bool shouldRebuildSemantics(GraphPainter oldDelegate) =>
      oldDelegate.picture != picture || oldDelegate.selected != selected;
}
