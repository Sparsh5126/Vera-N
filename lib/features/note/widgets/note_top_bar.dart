import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import 'saved_tick.dart';

/// Back, the saved tick, copy, pin, and the ⋮ menu (attach, archive,
/// lock, delete).
class NoteTopBar extends StatelessWidget {
  const NoteTopBar({
    super.key,
    required this.saves,
    required this.pinned,
    required this.onBack,
    required this.onPinChanged,
    required this.onCopy,
    required this.onDelete,
    required this.onAttach,
    this.archived = false,
    this.onArchive,
    this.locked = false,
    this.onLock,
  });

  final ValueListenable<int> saves;
  final bool pinned;
  final VoidCallback onBack;

  /// Null while the note doesn't exist yet (nothing typed).
  final ValueChanged<bool>? onPinChanged;

  /// Copies the whole note. Null while there is no text.
  final VoidCallback? onCopy;

  final VoidCallback onDelete;

  /// A photo, drawing or voice note (UI spec §7), also above the keyboard.
  final VoidCallback onAttach;

  /// In the ⋮ menu: Archive, or Unarchive when [archived]. Null while the
  /// note doesn't exist yet.
  final VoidCallback? onArchive;
  final bool archived;

  /// In the ⋮ menu: Move to Locked folder, or take it out when [locked].
  /// Null while the note doesn't exist yet.
  final VoidCallback? onLock;
  final bool locked;

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
            onPressed: onCopy,
            tooltip: AppCopy.copyNote,
            icon: const Icon(Icons.content_copy_outlined),
          ),
          IconButton(
            onPressed: onPin == null ? null : () => onPin(!pinned),
            tooltip: pinned ? AppCopy.unpin : AppCopy.pin,
            isSelected: pinned,
            icon: const Icon(Icons.push_pin_outlined),
            selectedIcon: const Icon(Icons.push_pin),
          ),
          // Move to folder lives below the text (the Folder row).
          PopupMenuButton<VoidCallback>(
            tooltip: AppCopy.moreOptions,
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              PopupMenuItem(value: onAttach, child: const Text(AppCopy.attach)),
              if (onArchive != null)
                PopupMenuItem(
                  value: onArchive,
                  child: Text(archived ? AppCopy.unarchive : AppCopy.archive),
                ),
              if (onLock != null)
                PopupMenuItem(
                  value: onLock,
                  child: Text(
                    locked ? AppCopy.moveOutOfLocked : AppCopy.moveToLocked,
                  ),
                ),
              PopupMenuItem(value: onDelete, child: const Text(AppCopy.delete)),
            ],
          ),
        ],
      ),
    );
  }
}
