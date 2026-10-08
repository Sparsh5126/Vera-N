import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// A link to another note, shown as text: normal text colour with the
/// ink underline links use in the editor.
/// Tappable across the full 48-point height.
class TextLink extends StatelessWidget {
  const TextLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.link(context.textStyles.body, context.colors);
    return Semantics(
      link: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.fieldBorder,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSize.minTapTarget,
            maxWidth: AppSize.chipMaxWidth,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: Text(
              label,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
