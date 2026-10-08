import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// The slim row above the keyboard while editing (UI spec §7). With text
/// selected it offers bold, list, checklist, link and attach; otherwise
/// only attach, so a photo, drawing or voice note is one tap away without
/// selecting anything.
class FormatBar extends StatelessWidget {
  const FormatBar({
    super.key,
    required this.selecting,
    required this.onBold,
    required this.onList,
    required this.onChecklist,
    required this.onLink,
    required this.onAttach,
  });

  /// The row for [text], shown only while the editor has focus.
  static Widget whileEditing({
    required TextEditingController text,
    required FocusNode focus,
    required VoidCallback onBold,
    required VoidCallback onList,
    required VoidCallback onChecklist,
    required VoidCallback onLink,
    required VoidCallback onAttach,
  }) {
    return ListenableBuilder(
      listenable: Listenable.merge([text, focus]),
      builder: (context, _) {
        if (!focus.hasFocus) return const SizedBox.shrink();
        return FormatBar(
          selecting: !text.selection.isCollapsed,
          onBold: onBold,
          onList: onList,
          onChecklist: onChecklist,
          onLink: onLink,
          onAttach: onAttach,
        );
      },
    );
  }

  /// Text is selected: the formatting buttons show too.
  final bool selecting;
  final VoidCallback onBold;
  final VoidCallback onList;
  final VoidCallback onChecklist;
  final VoidCallback onLink;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s),
        child: Row(
          children: [
            if (selecting) ...[
              _button(Icons.format_bold, AppCopy.formatBold, onBold),
              _button(Icons.format_list_bulleted, AppCopy.formatList, onList),
              _button(Icons.checklist, AppCopy.formatChecklist, onChecklist),
              _button(Icons.link, AppCopy.formatLink, onLink),
            ],
            _button(Icons.attach_file, AppCopy.attach, onAttach),
          ],
        ),
      ),
    );
  }

  Widget _button(IconData icon, String label, VoidCallback onPressed) {
    return IconButton(onPressed: onPressed, tooltip: label, icon: Icon(icon));
  }
}
