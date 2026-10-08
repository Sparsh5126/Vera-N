import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import 'drawing.dart';
import 'drawing_painter.dart';

/// The plate a drawing is made on. A finger draws a line; each finished
/// line is handed to [onChanged]. The drawing takes this canvas's size
/// (a saved one is fitted to it).
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    super.key,
    required this.drawing,
    required this.onChanged,
  });

  final Drawing drawing;
  final ValueChanged<Drawing> onChanged;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Offset>? _line;

  void _fit(Size size) {
    if (widget.drawing.size == size) return;
    // After this frame: the parent can't change during layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged(widget.drawing.fittedTo(size));
    });
  }

  void _end() {
    final line = _line;
    if (line == null) return;
    setState(() => _line = null);
    widget.onChanged(widget.drawing.withStroke(line));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        _fit(size);
        return GestureDetector(
          onPanStart: (d) => setState(() => _line = [d.localPosition]),
          onPanUpdate: (d) =>
              setState(() => _line = [...?_line, d.localPosition]),
          onPanEnd: (_) => _end(),
          onTapUp: (d) {
            _line = [d.localPosition];
            _end();
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: AppRadius.cardBorder,
              border: Border.all(color: colors.border),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.cardBorder,
              child: CustomPaint(
                size: size,
                painter: DrawingPainter(
                  drawing: widget.drawing.size == size
                      ? widget.drawing
                      : widget.drawing.fittedTo(size),
                  ink: colors.text,
                  current: _line,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
