import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// A tiny tick that fades in and out after each save.
class SavedTick extends StatefulWidget {
  const SavedTick({super.key, required this.saves});

  /// Changes after every save.
  final ValueListenable<int> saves;

  @override
  State<SavedTick> createState() => _SavedTickState();
}

class _SavedTickState extends State<SavedTick>
    with SingleTickerProviderStateMixin {
  late final _fade = AnimationController(
    vsync: this,
    duration: AppMotion.standard,
  );
  Timer? _hold;

  @override
  void initState() {
    super.initState();
    widget.saves.addListener(_show);
  }

  void _show() {
    final reduce = MediaQuery.disableAnimationsOf(context);
    _fade.duration = reduce ? AppMotion.reduced : AppMotion.standard;
    _fade.forward();
    _hold?.cancel();
    _hold = Timer(AppMotion.savedTickHold, () {
      if (mounted) _fade.reverse();
    });
  }

  @override
  void dispose() {
    widget.saves.removeListener(_show);
    _hold?.cancel();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _fade, curve: AppMotion.standardCurve),
      child: Icon(
        Icons.check,
        size: AppSize.iconSmall,
        color: context.colors.textSecondary,
        semanticLabel: AppCopy.saved,
      ),
    );
  }
}
