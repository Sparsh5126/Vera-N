import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// Over Home's header while notes are selected: stop selecting, and how
/// many are picked. The actions sit at the bottom, in thumb reach.
class SelectionTopBar extends StatelessWidget {
  const SelectionTopBar({
    super.key,
    required this.count,
    required this.onClose,
  });

  final int count;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
        child: Row(
          children: [
            const SizedBox(width: AppSpace.xs),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              tooltip: HomeCopy.stopSelecting,
            ),
            const SizedBox(width: AppSpace.xs),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  HomeCopy.selectedCount(count),
                  style: context.textStyles.noteTitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
