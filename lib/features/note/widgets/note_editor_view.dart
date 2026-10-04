import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import 'titled_text_controller.dart';

/// The note's text and, when not typing, the details below it, in one
/// scrolling column. A tap below the text starts editing at its end.
class NoteEditorView extends StatelessWidget {
  const NoteEditorView({
    super.key,
    required this.text,
    required this.focus,
    required this.autofocus,
    required this.onChanged,
    required this.onTap,
    required this.onTapBelow,
    required this.details,
  });

  final TitledTextController text;
  final FocusNode focus;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  /// A tap in the text (after the cursor moved there).
  final VoidCallback onTap;
  final VoidCallback onTapBelow;

  /// Folder, tags and links; hidden while typing.
  final Widget details;

  /// Centers [child] at a comfortable reading width.
  static Widget readable(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSize.readableWidth),
        child: Padding(padding: AppSpace.screen, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    final typing = focus.hasFocus && keyboardUp;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: readable(
            TextField(
              controller: text,
              focusNode: focus,
              autofocus: autofocus,
              onChanged: onChanged,
              onTap: onTap,
              style: context.textStyles.body,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
        if (!typing) SliverToBoxAdapter(child: details),
        SliverFillRemaining(
          hasScrollBody: false,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapBelow,
          ),
        ),
      ],
    );
  }
}
