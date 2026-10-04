import 'package:flutter/material.dart';

import '../../core/feedback/motion.dart';
import '../../core/styles/app_styles.dart';

/// One destination in the [PillNavBar].
@immutable
class PillNavItem {
  const PillNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The floating pill navigation bar: icons only, the current one on a
/// small amber pill that slides to the chosen tab (instant when the
/// system asks for less motion). Names are spoken by screen readers and
/// shown on long press.
class PillNavBar extends StatelessWidget {
  const PillNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  /// One step of the sliding pill: an item plus the gap after it.
  static const _step = AppSize.navItemWidth + AppSpace.xs;

  final List<PillNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = Motion.of(context);
    return Container(
      height: AppSize.navBarHeight,
      padding: const EdgeInsets.all(AppSpace.s),
      decoration: ShapeDecoration(
        color: colors.card,
        shape: StadiumBorder(
          side: BorderSide(color: colors.border, width: AppBorder.width),
        ),
      ),
      // Transparent material so the tabs' ink ripples have a surface.
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Moves by transform only, never by layout (CLAUDE.md §7).
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: AnimatedSlide(
                offset: Offset(currentIndex * _step / AppSize.navItemWidth, 0),
                duration: duration,
                curve: AppMotion.standardCurve,
                child: SizedBox(
                  width: AppSize.navItemWidth,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: colors.accent,
                      shape: AppRadius.pill,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpace.xs,
              children: [
                for (var i = 0; i < items.length; i++)
                  _NavPill(
                    item: items[i],
                    selected: i == currentIndex,
                    duration: duration,
                    onTap: () => onSelected(i),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.item,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final PillNavItem item;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Tooltip(
        message: item.label,
        child: InkWell(
          onTap: onTap,
          customBorder: AppRadius.pill,
          child: SizedBox(
            width: AppSize.navItemWidth,
            height: double.infinity,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end: selected ? colors.onAccent : colors.textSecondary,
              ),
              duration: duration,
              curve: AppMotion.standardCurve,
              builder: (context, color, _) =>
                  Icon(selected ? item.selectedIcon : item.icon, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
