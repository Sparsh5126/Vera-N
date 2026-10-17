import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../core/styles/app_styles.dart';

enum SwipeDirection { right, left, up, down }

/// A card the user swipes: right, left or up sends it away, down asks for
/// undo (UI spec §6). It tilts while dragged, shows a faint ✓ or ✕, and
/// settles back on a spring. With reduced motion it moves without
/// animating. Only transform and opacity change, never layout.
///
/// With [nudge], the card shows the swipe once by itself: it leans right
/// (the ✓ shows), settles, leans left (the ✕), settles, with a finger on
/// it. Touching the card stops it; with reduced motion it doesn't move.
class SwipeCard extends StatefulWidget {
  const SwipeCard({
    super.key,
    required this.child,
    required this.onSwipe,
    this.nudge = false,
  });

  final Widget child;
  final ValueChanged<SwipeDirection> onSwipe;
  final bool nudge;

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with TickerProviderStateMixin {
  late final AnimationController _settle = AnimationController.unbounded(
    vsync: this,
  )..addListener(_onSettle);
  late final AnimationController _nudge =
      AnimationController(
          vsync: this,
          duration: AppMotion.nudgeStep * 4 + AppMotion.nudgeHold * 2,
        )
        ..addListener(_onNudge)
        // Rebuild when it ends or stops, so the finger goes too.
        ..addStatusListener((_) {
          if (mounted) setState(() {});
        });
  Offset _drag = Offset.zero;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  double _width = 0;
  bool _nudged = false;

  /// Share of the card's width (or height, upward) that counts as a swipe.
  static const _distance = 0.3;
  static const _flingSpeed = 800.0;

  /// The nudge's lean, as a share of the card's width, over its run.
  static final _lean = () {
    const lean = AppMotion.nudgeLean;
    final step = AppMotion.nudgeStep.inMilliseconds.toDouble();
    final hold = AppMotion.nudgeHold.inMilliseconds.toDouble();
    TweenSequenceItem<double> move(double from, double to, Curve curve) =>
        TweenSequenceItem(
          tween: Tween(begin: from, end: to).chain(CurveTween(curve: curve)),
          weight: step,
        );
    TweenSequenceItem<double> stay(double at) =>
        TweenSequenceItem(tween: ConstantTween(at), weight: hold);
    return TweenSequence<double>([
      move(0, lean, AppMotion.standardCurve),
      stay(lean),
      move(lean, 0, AppMotion.nudgeSettleCurve),
      move(0, -lean, AppMotion.standardCurve),
      stay(-lean),
      move(-lean, 0, AppMotion.nudgeSettleCurve),
    ]);
  }();

  @override
  void initState() {
    super.initState();
    if (widget.nudge) _scheduleNudge();
  }

  @override
  void didUpdateWidget(SwipeCard old) {
    super.didUpdateWidget(old);
    // Whether the hint was seen loads after the first frame.
    if (widget.nudge && !old.nudge) _scheduleNudge();
  }

  @override
  void dispose() {
    _settle.dispose();
    _nudge.dispose();
    super.dispose();
  }

  void _scheduleNudge() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _startNudge());

  void _startNudge() {
    if (_nudged || !mounted || MediaQuery.disableAnimationsOf(context)) return;
    _nudged = true;
    unawaited(_nudge.forward(from: 0));
  }

  void _onNudge() =>
      setState(() => _drag = Offset(_lean.evaluate(_nudge) * _width, 0));

  void _onSettle() =>
      setState(() => _drag = Offset.lerp(_from, _to, _settle.value)!);

  void _onEnd(DragEndDetails details, Size size) {
    final v = details.velocity.pixelsPerSecond;
    final dx = _drag.dx / size.width;
    final dy = _drag.dy / size.height;
    final SwipeDirection? direction;
    if (dx > _distance || v.dx > _flingSpeed && dx > 0) {
      direction = SwipeDirection.right;
    } else if (dx < -_distance || v.dx < -_flingSpeed && dx < 0) {
      direction = SwipeDirection.left;
    } else if (dy < -_distance || v.dy < -_flingSpeed && dy < 0) {
      direction = SwipeDirection.up;
    } else if (dy > _distance || v.dy > _flingSpeed && dy > 0) {
      direction = SwipeDirection.down;
    } else {
      direction = null;
    }
    // Down is undo: the card stays and springs back like a non-swipe.
    final away = direction != null && direction != SwipeDirection.down;
    final target = away ? _offscreen(direction, size) : Offset.zero;
    _animateTo(
      target,
      onDone: () {
        if (direction != null) widget.onSwipe(direction);
        if (away && mounted) setState(() => _drag = Offset.zero);
      },
    );
  }

  Offset _offscreen(SwipeDirection d, Size size) => switch (d) {
    SwipeDirection.right => Offset(size.width * 1.5, _drag.dy),
    SwipeDirection.left => Offset(-size.width * 1.5, _drag.dy),
    _ => Offset(_drag.dx, -size.height * 1.5),
  };

  void _animateTo(Offset target, {required VoidCallback onDone}) {
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _drag = target);
      onDone();
      return;
    }
    _from = _drag;
    _to = target;
    _settle.value = 0;
    _settle
        .animateWith(SpringSimulation(AppMotion.cardSpring, 0, 1, 0))
        .whenComplete(onDone);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        _width = size.width;
        final lean = (_drag.dx / size.width).clamp(-1.0, 1.0);
        return GestureDetector(
          onPanStart: (_) {
            _settle.stop();
            _nudge.stop();
          },
          onPanUpdate: (d) => setState(() => _drag += d.delta),
          onPanEnd: (d) => _onEnd(d, size),
          child: Transform.translate(
            offset: _drag,
            child: Transform.rotate(
              angle: lean * AppMotion.cardTiltMax,
              child: Stack(
                children: [
                  widget.child,
                  _mark(context, lean),
                  if (_nudge.isAnimating) _finger(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// A finger resting on the card while it shows the swipe by itself.
  Widget _finger(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.l),
          child: Icon(
            Icons.touch_app_outlined,
            size: AppSize.minTapTarget,
            color: context.colors.textSecondary,
          ),
        ),
      ),
    ),
  );

  /// A faint ✓ (dragging right) or ✕ (left) in the card's top corner.
  Widget _mark(BuildContext context, double lean) {
    final colors = context.colors;
    final right = lean > 0;
    return Positioned(
      top: AppSpace.m,
      left: right ? AppSpace.m : null,
      right: right ? null : AppSpace.m,
      child: IgnorePointer(
        child: Opacity(
          opacity: (lean.abs() / _distance).clamp(0.0, 1.0) * AppOpacity.dimmed,
          child: Icon(
            right ? Icons.check_circle : Icons.cancel,
            size: AppSize.minTapTarget,
            color: right ? colors.accept : colors.reject,
          ),
        ),
      ),
    );
  }
}
