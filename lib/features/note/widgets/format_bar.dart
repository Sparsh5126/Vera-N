import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// The slim row above the keyboard while editing (UI spec §7): bold,
/// list, checklist, link and attach, always there (changed 2026-10-08 at
/// the user's request). With nothing selected they act where the cursor
/// is: bold on its word, list and checklist on its line, link at it.
class FormatBar extends StatelessWidget {
  const FormatBar({
    super.key,
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
      listenable: focus,
      builder: (context, _) {
        if (!focus.hasFocus) return const SizedBox.shrink();
        return FormatBar(
          onBold: onBold,
          onList: onList,
          onChecklist: onChecklist,
          onLink: onLink,
          onAttach: onAttach,
        );
      },
    );
  }

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
            _button(Icons.format_bold, AppCopy.formatBold, onBold),
            _button(Icons.format_list_bulleted, AppCopy.formatList, onList),
            _button(Icons.checklist, AppCopy.formatChecklist, onChecklist),
            _button(Icons.link, AppCopy.formatLink, onLink),
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
