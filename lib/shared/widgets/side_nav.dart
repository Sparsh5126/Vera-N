import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/styles/app_styles.dart';
import 'pill_button.dart';
import 'pill_nav_bar.dart';

/// The sidebar on a wide window (docs/LAPTOP_PLAN.md, L1), in place of
/// the floating pill bar: the wordmark, "New note", and the same places
/// with their names. The current one sits on the ink plate.
class SideNav extends StatelessWidget {
  const SideNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    required this.onNewNote,
  });

  final List<PillNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onNewNote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: AppSize.sidebarWidth,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: AppSpace.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpace.l),
              Text(AppCopy.appName, style: context.textStyles.wordmark),
              const SizedBox(height: AppSpace.l),
              PillButton(
                label: AppCopy.newNote,
                icon: Icons.add,
                onPressed: onNewNote,
              ),
              const SizedBox(height: AppSpace.l),
              for (var i = 0; i < items.length; i++) _item(context, i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i) {
    final colors = context.colors;
    final selected = i == currentIndex;
    final item = items[i];
    final fg = selected ? colors.onAccent : colors.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xs),
      child: Material(
        color: selected ? colors.accent : colors.background,
        shape: AppRadius.pill,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(i),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSize.minTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
              child: Row(
                spacing: AppSpace.m,
                children: [
                  Icon(selected ? item.selectedIcon : item.icon, color: fg),
                  Text(
                    item.label,
                    style: context.textStyles.label.copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
