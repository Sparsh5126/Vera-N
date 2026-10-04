import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// A checklist checkbox or a bullet, drawn inside the note's text in place
/// of the Markdown `- [ ]` / `- [x]` / `- `.
class CheckboxGlyph extends StatelessWidget {
  const CheckboxGlyph({
    super.key,
    required this.bullet,
    required this.checked,
    required this.textStyle,
    this.onTap,
  });

  final bool bullet;
  final bool checked;

  /// The line's text style, so the glyph sits on the text.
  final TextStyle textStyle;

  /// Ticks or unticks a checkbox; null for bullets.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (bullet) {
      return SizedBox(
        width: AppSize.glyphWidth,
        child: Text(
          AppCopy.bullet,
          textAlign: TextAlign.center,
          style: textStyle.copyWith(color: colors.textSecondary),
        ),
      );
    }
    return Semantics(
      checked: checked,
      label: checked ? AppCopy.checkboxDone : AppCopy.checkboxNotDone,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: AppSize.glyphWidth,
          child: Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: AppSize.iconSmall,
            color: checked ? colors.accent : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
