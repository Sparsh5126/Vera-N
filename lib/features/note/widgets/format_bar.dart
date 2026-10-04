import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// The slim formatting row above the keyboard, shown only while text is
/// selected (UI spec §7). Attach joins it when attachments exist.
class FormatBar extends StatelessWidget {
  const FormatBar({
    super.key,
    required this.onBold,
    required this.onList,
    required this.onChecklist,
    required this.onLink,
  });

  /// The row for [text], shown only while text in it is selected and the
  /// editor has focus.
  static Widget whileSelecting({
    required TextEditingController text,
    required FocusNode focus,
    required VoidCallback onBold,
    required VoidCallback onList,
    required VoidCallback onChecklist,
    required VoidCallback onLink,
  }) {
    return ListenableBuilder(
      listenable: Listenable.merge([text, focus]),
      builder: (context, _) {
        if (!focus.hasFocus || text.selection.isCollapsed) {
          return const SizedBox.shrink();
        }
        return FormatBar(
          onBold: onBold,
          onList: onList,
          onChecklist: onChecklist,
          onLink: onLink,
        );
      },
    );
  }

  final VoidCallback onBold;
  final VoidCallback onList;
  final VoidCallback onChecklist;
  final VoidCallback onLink;

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
          ],
        ),
      ),
    );
  }

  Widget _button(IconData icon, String label, VoidCallback onPressed) {
    return IconButton(onPressed: onPressed, tooltip: label, icon: Icon(icon));
  }
}
