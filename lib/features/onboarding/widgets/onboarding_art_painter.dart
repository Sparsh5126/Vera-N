import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import 'onboarding_art_kind.dart';

/// Draws the onboarding illustrations: simple ink lines on the note plate,
/// in the theme's own colours, so they follow light and dark. Only the
/// dashed line between two notes is in the seal colour: it is the app's
/// mark for a suggestion, used here for exactly that.
///
/// Each drawing sits in a 140 × 100 box scaled to fit, so it stays the
/// same picture at any size.
class OnboardingArtPainter extends CustomPainter {
  OnboardingArtPainter({required this.kind, required this.colors});

  final OnboardingArtKind kind;
  final AppPalette colors;

  static const _boxWidth = 140.0;
  static const _boxHeight = 100.0;

  /// The ink line in box units: [AppSize.artStroke] at full size.
  static const _line =
      AppSize.artStroke * _boxHeight / AppSize.onboardingArtHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _boxWidth, size.height / _boxHeight);
    canvas
      ..save()
      ..translate(
        (size.width - _boxWidth * scale) / 2,
        (size.height - _boxHeight * scale) / 2,
      )
      ..scale(scale);
    switch (kind) {
      case OnboardingArtKind.privateNote:
        _privateNote(canvas);
      case OnboardingArtKind.connections:
        _connections(canvas);
      case OnboardingArtKind.onPhone:
        _onPhone(canvas);
      case OnboardingArtKind.onComputer:
        _onComputer(canvas);
      case OnboardingArtKind.reminder:
        _reminder(canvas);
      case OnboardingArtKind.folder:
        _folder(canvas);
      case OnboardingArtKind.name:
        _name(canvas);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(OnboardingArtPainter old) =>
      old.kind != kind || old.colors != colors;

  Paint _stroke(Color color, [double width = _line]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint _fill(Color color) => Paint()..color = color;

  /// [r] with corners rounded by [share] of its shorter side.
  static RRect _rounded(Rect r, double share) => RRect.fromRectAndRadius(
    r,
    Radius.circular(math.min(r.width, r.height) * share),
  );

  /// A semicircle's radius: half the gap between its two ends.
  static Radius _half(double from, double to) =>
      Radius.circular((to - from) / 2);

  /// A note: the card plate with its hairline edge.
  void _plate(Canvas canvas, Rect r) {
    final shape = _rounded(r, 0.12);
    canvas
      ..drawRRect(shape, _fill(colors.card))
      ..drawRRect(shape, _stroke(colors.border, _line * 0.5));
  }

  /// A title line in ink, then lines of text in secondary ink below it.
  void _text(Canvas canvas, Offset at, double title, List<double> lines) {
    canvas.drawLine(
      at,
      at.translate(title, 0),
      _stroke(colors.text, _line * 1.4),
    );
    for (final (i, width) in lines.indexed) {
      final y = at.dy + 11 + i * 9.5;
      canvas.drawLine(
        Offset(at.dx, y),
        Offset(at.dx + width, y),
        _stroke(colors.textSecondary),
      );
    }
  }

  /// The suggestion mark: a dashed line in the seal colour.
  void _dashed(Canvas canvas, Path path) {
    final paint = _stroke(colors.seal);
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 7) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
      }
    }
  }

  void _dot(Canvas canvas, Offset at, Color color, [double r = 3]) =>
      canvas.drawCircle(at, r, _fill(color));

  void _privateNote(Canvas canvas) {
    _plate(canvas, const Rect.fromLTWH(36, 6, 64, 86));
    _text(canvas, const Offset(46, 22), 34, const [44, 40, 28, 36]);
    // A padlock over the note's lower corner.
    final body = _rounded(const Rect.fromLTWH(88, 68, 28, 22), 0.18);
    final shackle = Path()
      ..moveTo(94, 68)
      ..lineTo(94, 61)
      ..arcToPoint(const Offset(110, 61), radius: _half(94, 110))
      ..lineTo(110, 68);
    canvas
      ..drawPath(shackle, _stroke(colors.text, _line * 1.4))
      ..drawRRect(body, _fill(colors.text));
    _dot(canvas, const Offset(102, 78), colors.card, 2.6);
  }

  void _connections(Canvas canvas) {
    _plate(canvas, const Rect.fromLTWH(6, 12, 54, 48));
    _text(canvas, const Offset(15, 24), 28, const [36, 26]);
    _plate(canvas, const Rect.fromLTWH(80, 40, 54, 48));
    _text(canvas, const Offset(89, 52), 30, const [36, 22]);
    _dashed(
      canvas,
      Path()
        ..moveTo(62, 36)
        ..cubicTo(74, 36, 66, 64, 78, 64),
    );
    _dot(canvas, const Offset(62, 36), colors.seal, 2.2);
    _dot(canvas, const Offset(78, 64), colors.seal, 2.2);
  }

  /// A few notes linked inside a frame, one of the links still a
  /// suggestion: what the device works out by itself.
  void _graph(Canvas canvas, List<Offset> nodes) {
    final quiet = _stroke(colors.textSecondary);
    canvas
      ..drawLine(nodes[0], nodes[1], quiet)
      ..drawLine(nodes[1], nodes[2], quiet);
    _dashed(
      canvas,
      Path()
        ..moveTo(nodes[1].dx, nodes[1].dy)
        ..lineTo(nodes[3].dx, nodes[3].dy),
    );
    for (final node in nodes) {
      _dot(canvas, node, colors.text);
    }
  }

  void _onPhone(Canvas canvas) {
    final phone = _rounded(const Rect.fromLTWH(48, 2, 44, 96), 0.2);
    canvas
      ..drawRRect(phone, _fill(colors.card))
      ..drawRRect(phone, _stroke(colors.text))
      ..drawLine(
        const Offset(64, 9),
        const Offset(76, 9),
        _stroke(colors.textSecondary),
      );
    _graph(canvas, const [
      Offset(60, 32),
      Offset(78, 48),
      Offset(62, 70),
      Offset(80, 80),
    ]);
  }

  void _onComputer(Canvas canvas) {
    final screen = _rounded(const Rect.fromLTWH(28, 10, 84, 58), 0.09);
    final base = _rounded(const Rect.fromLTWH(14, 70, 112, 8), 0.5);
    canvas
      ..drawRRect(screen, _fill(colors.card))
      ..drawRRect(screen, _stroke(colors.text))
      ..drawRRect(base, _stroke(colors.text));
    _graph(canvas, const [
      Offset(46, 28),
      Offset(68, 40),
      Offset(52, 54),
      Offset(92, 28),
    ]);
  }

  void _reminder(Canvas canvas) {
    _plate(canvas, const Rect.fromLTWH(10, 22, 82, 60));
    _text(canvas, const Offset(20, 36), 44, const [60, 40, 52]);
    // A bell beside the note.
    final bell = Path()
      ..moveTo(104, 54)
      ..lineTo(104, 42)
      ..arcToPoint(const Offset(126, 42), radius: _half(104, 126))
      ..lineTo(126, 54)
      ..lineTo(130, 58)
      ..lineTo(100, 58)
      ..close();
    canvas
      ..drawPath(bell, _fill(colors.card))
      ..drawPath(bell, _stroke(colors.text))
      ..drawLine(
        const Offset(115, 27),
        const Offset(115, 31),
        _stroke(colors.text),
      );
    _dot(canvas, const Offset(115, 63), colors.text, 2.6);
  }

  void _folder(Canvas canvas) {
    final back = Path()
      ..moveTo(22, 86)
      ..lineTo(22, 20)
      ..lineTo(52, 20)
      ..lineTo(60, 28)
      ..lineTo(118, 28)
      ..lineTo(118, 86)
      ..close();
    canvas
      ..drawPath(back, _fill(colors.card))
      ..drawPath(back, _stroke(colors.text));
    // Two notes inside, their tops showing.
    _plate(canvas, const Rect.fromLTWH(34, 32, 42, 40));
    _text(canvas, const Offset(41, 41), 22, const [26]);
    _plate(canvas, const Rect.fromLTWH(64, 26, 44, 46));
    _text(canvas, const Offset(71, 35), 24, const [30]);
    final front = Path()
      ..moveTo(18, 48)
      ..lineTo(122, 48)
      ..lineTo(116, 88)
      ..lineTo(24, 88)
      ..close();
    canvas
      ..drawPath(front, _fill(colors.card))
      ..drawPath(front, _stroke(colors.text));
  }

  void _name(Canvas canvas) {
    _plate(canvas, const Rect.fromLTWH(22, 18, 96, 64));
    // A greeting being written, the cursor after it, a line of text below.
    final quiet = _stroke(colors.textSecondary);
    canvas
      ..drawLine(
        const Offset(34, 40),
        const Offset(80, 40),
        _stroke(colors.text, _line * 2),
      )
      ..drawLine(
        const Offset(88, 32),
        const Offset(88, 48),
        _stroke(colors.text),
      )
      ..drawLine(const Offset(34, 60), const Offset(96, 60), quiet)
      ..drawLine(const Offset(34, 70), const Offset(70, 70), quiet);
  }
}
