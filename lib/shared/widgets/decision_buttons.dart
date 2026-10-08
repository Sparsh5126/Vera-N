import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/styles/app_styles.dart';

/// ✕ and ✓ for a suggestion, with "Not sure" between them when offered
/// (UI spec §6, §8). Same look in Review and the note's suggestion sheet.
class DecisionButtons extends StatelessWidget {
  const DecisionButtons({
    super.key,
    required this.onReject,
    required this.onAccept,
    this.onNotSure,
  });

  final VoidCallback? onReject;
  final VoidCallback? onAccept;

  /// Null hides "Not sure" (in the sheet, closing it means not sure).
  final VoidCallback? onNotSure;

  static const _big = BoxConstraints(
    minWidth: AppSize.xlTapTarget,
    minHeight: AppSize.xlTapTarget,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onNotSure = this.onNotSure;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton.outlined(
          onPressed: onReject,
          icon: Icon(Icons.close, color: colors.reject),
          tooltip: AppCopy.reject,
          constraints: _big,
        ),
        if (onNotSure != null)
          OutlinedButton(
            onPressed: onNotSure,
            child: const Text(AppCopy.notSure),
          ),
        IconButton.outlined(
          onPressed: onAccept,
          icon: Icon(Icons.check, color: colors.accept),
          tooltip: AppCopy.accept,
          constraints: _big,
        ),
      ],
    );
  }
}
