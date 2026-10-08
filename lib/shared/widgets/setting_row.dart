import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// One Settings row: a label with its current value on the right, an
/// optional plain-language line below, and a tap or a [trailing] control.
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? value;
  final String? hint;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final value = this.value;
    final hint = this.hint;
    return ListTile(
      minTileHeight: AppSize.minTapTarget,
      contentPadding: AppSpace.screen,
      title: Text(label, style: styles.body),
      subtitle: hint == null ? null : Text(hint, style: styles.small),
      trailing:
          trailing ??
          (value == null
              ? null
              : ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSize.chipMaxWidth,
                  ),
                  child: Text(
                    value,
                    style: styles.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
      onTap: onTap,
    );
  }
}
