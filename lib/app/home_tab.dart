import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/copy/app_copy.dart';
import '../core/navigation/open_note.dart';
import '../core/styles/app_styles.dart';
import '../features/home/home_screen.dart';
import '../features/note/note_screen.dart';
import '../shared/widgets/empty_state.dart';

/// Home. On a wide window (docs/LAPTOP_PLAN.md, L1) the notes list sits on
/// the left and the open note on the right, so a click opens a note
/// without leaving the list. A phone shows Home alone.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppBreakpoints.wide(context)) return const HomeScreen();
    final open = ref.watch(openNoteProvider);
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(width: AppSize.listPaneWidth, child: HomeScreen()),
        VerticalDivider(width: AppBorder.width, color: colors.border),
        Expanded(
          child: open == null
              ? const EmptyState(message: AppCopy.pickANote)
              : NoteScreen(
                  key: ValueKey(open.serial),
                  noteRef: open.ref,
                  onClose: ref.read(openNoteProvider.notifier).close,
                ),
        ),
      ],
    );
  }
}
