import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import 'saved_tick.dart';

/// Back, the saved tick, pin, and the ⋮ menu.
class NoteTopBar extends StatelessWidget {
  const NoteTopBar({
    super.key,
    required this.saves,
    required this.pinned,
    required this.onBack,
    required this.onPinChanged,
    required this.onDelete,
  });

  final ValueListenable<int> saves;
  final bool pinned;
  final VoidCallback onBack;

  /// Null while the note doesn't exist yet (nothing typed).
  final ValueChanged<bool>? onPinChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final onPin = onPinChanged;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: AppCopy.back,
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          SavedTick(saves: saves),
          IconButton(
            onPressed: onPin == null ? null : () => onPin(!pinned),
            tooltip: pinned ? AppCopy.unpin : AppCopy.pin,
            isSelected: pinned,
            icon: const Icon(Icons.push_pin_outlined),
            selectedIcon: const Icon(Icons.push_pin),
          ),
          PopupMenuButton<VoidCallback>(
            tooltip: AppCopy.moreOptions,
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              PopupMenuItem(value: onDelete, child: const Text(AppCopy.delete)),
            ],
          ),
        ],
      ),
    );
  }
}
