import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// A thin filter pill (Search; later Graph). Unset: outlined with the
/// filter's name. Set: solid amber with the chosen value.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  /// The filter's name when unset, or its value when set.
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = active ? colors.onAccent : colors.text;
    return Semantics(
      button: true,
      selected: active,
      child: Material(
        color: active ? colors.accent : colors.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: active ? colors.accent : colors.border,
            width: AppBorder.width,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSize.minTapTarget,
              minWidth: AppSize.minTapTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpace.m,
                right: AppSpace.s,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: context.textStyles.label.copyWith(color: fg),
                  ),
                  Icon(Icons.expand_more, size: AppSize.iconSmall, color: fg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
