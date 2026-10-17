import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import '../state/dragged_notes.dart';

/// A place to drop dragged notes, in the folder tray (UI spec §5). It turns
/// ink while notes hover over it. With [onSpringOpen], resting there for
/// [AppMotion.springOpen] opens that folder under the finger, so the
/// notes can be dropped inside it.
class FolderDropChip extends StatefulWidget {
  const FolderDropChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onDrop,
    this.onSpringOpen,
  });

  final String label;
  final IconData icon;
  final ValueChanged<DraggedNotes> onDrop;
  final VoidCallback? onSpringOpen;

  @override
  State<FolderDropChip> createState() => _FolderDropChipState();
}

class _FolderDropChipState extends State<FolderDropChip> {
  Timer? _spring;
  bool _hover = false;

  @override
  void dispose() {
    _spring?.cancel();
    super.dispose();
  }

  void _enter() {
    setState(() => _hover = true);
    final open = widget.onSpringOpen;
    if (open == null || _spring != null) return;
    _spring = Timer(AppMotion.springOpen, () {
      _spring = null;
      open();
    });
  }

  void _leave() {
    _spring?.cancel();
    _spring = null;
    if (mounted) setState(() => _hover = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ink = _hover ? colors.background : colors.text;
    return DragTarget<DraggedNotes>(
      onWillAcceptWithDetails: (_) {
        _enter();
        return true;
      },
      onLeave: (_) => _leave(),
      onAcceptWithDetails: (details) {
        _leave();
        widget.onDrop(details.data);
      },
      builder: (context, _, _) => Container(
        height: AppSize.minTapTarget,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
        decoration: ShapeDecoration(
          color: _hover ? colors.text : colors.card,
          shape: StadiumBorder(
            side: BorderSide(color: colors.border, width: AppBorder.width),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: AppSize.iconSmall, color: ink),
            const SizedBox(width: AppSpace.xs),
            Text(
              widget.label,
              style: context.textStyles.label.copyWith(color: ink),
            ),
          ],
        ),
      ),
    );
  }
}
