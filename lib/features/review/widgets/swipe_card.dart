import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../core/styles/app_styles.dart';

enum SwipeDirection { right, left, up, down }

/// A card the user swipes: right, left or up sends it away, down asks for
/// undo (UI spec §6). It tilts while dragged, shows a faint ✓ or ✕, and
/// settles back on a spring. With reduced motion it moves without
/// animating. Only transform and opacity change, never layout.
class SwipeCard extends StatefulWidget {
  const SwipeCard({super.key, required this.child, required this.onSwipe});

  final Widget child;
  final ValueChanged<SwipeDirection> onSwipe;

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settle = AnimationController.unbounded(
    vsync: this,
  )..addListener(_onSettle);
  Offset _drag = Offset.zero;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;

  /// Share of the card's width (or height, upward) that counts as a swipe.
  static const _distance = 0.3;
  static const _flingSpeed = 800.0;

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

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
        final lean = (_drag.dx / size.width).clamp(-1.0, 1.0);
        return GestureDetector(
          onPanStart: (_) => _settle.stop(),
          onPanUpdate: (d) => setState(() => _drag += d.delta),
          onPanEnd: (d) => _onEnd(d, size),
          child: Transform.translate(
            offset: _drag,
            child: Transform.rotate(
              angle: lean * AppMotion.cardTiltMax,
              child: Stack(children: [widget.child, _mark(context, lean)]),
            ),
          ),
        );
      },
    );
  }

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
