import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import 'drawing.dart';
import 'drawing_canvas.dart';

/// Draw with a finger (UI spec §7): one ink, Undo for the last line, Clear,
/// and Save. Returns the drawing, or null if the user backed out.
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key, this.initial});

  /// A saved drawing to keep drawing on.
  final Drawing? initial;

  static Future<Drawing?> open(BuildContext context, {Drawing? initial}) {
    return Navigator.of(context).push<Drawing>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DrawingScreen(initial: initial),
      ),
    );
  }

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late Drawing _drawing = widget.initial ?? Drawing.empty;

  void _set(Drawing d) => setState(() => _drawing = d);

  @override
  Widget build(BuildContext context) {
    final empty = _drawing.isEmpty;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          tooltip: AppCopy.cancel,
        ),
        title: const Text(AppCopy.drawing),
        actions: [
          IconButton(
            onPressed: empty ? null : () => _set(_drawing.withoutLast()),
            icon: const Icon(Icons.undo),
            tooltip: AppCopy.undoStroke,
          ),
          TextButton(
            onPressed: empty ? null : () => _set(_drawing.withoutAll()),
            child: const Text(AppCopy.clearDrawing),
          ),
          TextButton(
            onPressed: empty ? null : () => Navigator.of(context).pop(_drawing),
            child: const Text(AppCopy.save),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpace.screen,
          child: DrawingCanvas(drawing: _drawing, onChanged: _set),
        ),
      ),
    );
  }
}
