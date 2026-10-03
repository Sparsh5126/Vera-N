import 'package:flutter/material.dart';

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
/// small amber pill. Names are spoken by screen readers and shown on long
/// press.
class PillNavBar extends StatelessWidget {
  const PillNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<PillNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: AppSize.navBarHeight,
      padding: const EdgeInsets.all(AppSpace.s),
      decoration: ShapeDecoration(
        color: colors.card,
        shape: StadiumBorder(
          side: BorderSide(color: colors.border, width: AppBorder.width),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpace.xs,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavPill(
              item: items[i],
              selected: i == currentIndex,
              onTap: () => onSelected(i),
            ),
        ],
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PillNavItem item;
  final bool selected;
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
        child: Material(
          color: selected ? colors.accent : colors.card,
          shape: AppRadius.pill,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: AppSize.navItemWidth,
              height: double.infinity,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                color: selected ? colors.onAccent : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
