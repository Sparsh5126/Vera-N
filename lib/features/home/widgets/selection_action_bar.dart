import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// The actions for the selected notes, floating above the nav bar in thumb
/// reach, in the nav bar's own plate: Folder, Lock, Archive, Pin or Unpin,
/// Delete. Each is a labelled button at least 48 points across.
class SelectionActionBar extends StatelessWidget {
  const SelectionActionBar({
    super.key,
    required this.onFolder,
    required this.onLock,
    required this.onArchive,
    required this.onPin,
    required this.onDelete,
    required this.allPinned,
  });

  final VoidCallback onFolder;
  final VoidCallback onLock;
  final VoidCallback onArchive;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  /// Every selected note is pinned, so the pin button unpins.
  final bool allPinned;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      // The nav bar's height: the floating slot would otherwise let the
      // bar grow over the notes.
      height: AppSize.navBarHeight,
      // As wide as five nav items, narrower on a small phone: the buttons
      // share the width, each still a full tap target.
      constraints: const BoxConstraints(
        maxWidth: AppSize.navItemWidth * 5 + AppSpace.s * 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s),
      decoration: ShapeDecoration(
        color: colors.card,
        shape: StadiumBorder(
          side: BorderSide(color: colors.border, width: AppBorder.width),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          children: [
            _button(
              context,
              Icons.drive_file_move_outline,
              HomeCopy.actionFolder,
              onFolder,
            ),
            _button(context, Icons.lock_outline, HomeCopy.actionLock, onLock),
            _button(
              context,
              Icons.archive_outlined,
              HomeCopy.actionArchive,
              onArchive,
            ),
            _button(
              context,
              Icons.push_pin_outlined,
              allPinned ? AppCopy.unpin : AppCopy.pin,
              onPin,
            ),
            _button(context, Icons.delete_outline, AppCopy.delete, onDelete),
          ],
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final styles = context.textStyles;
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppSize.minTapTarget,
              minHeight: AppSize.navBarHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: context.colors.text),
                const SizedBox(height: AppSpace.xs),
                Text(
                  label,
                  style: styles.small,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
