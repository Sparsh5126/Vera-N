import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/suggestions/suggestion_actions.dart';
import '../../../core/ai/suggestions/suggestion_providers.dart';
import '../../../core/copy/app_copy.dart';
import '../../../core/feedback/haptics.dart';
import '../../../core/models/suggested_link.dart';
import '../../../shared/widgets/undo_snack_bar.dart';
import 'suggestion_sheet.dart';

/// Tapping a dimmed "Suggested links" chip: the suggestion sheet, then the
/// same accept / reject as Review, with Undo (UI spec §7–8). Closing the
/// sheet counts as "not sure": the chip stays dimmed.
///
/// Accepting may add a link to the open note's text, so the editor's
/// unsaved text is saved first ([beforeChange]) and the editor reloads
/// the text after ([afterChange]); nothing the user typed is lost.
class NoteSuggestionFlow {
  NoteSuggestionFlow({
    required this.ref,
    required this.beforeChange,
    required this.afterChange,
    required this.onOpenNote,
  });

  final WidgetRef ref;
  final Future<void> Function() beforeChange;
  final Future<void> Function() afterChange;
  final ValueChanged<int> onOpenNote;

  Future<void> open(BuildContext context, SuggestedLink link) async {
    final messenger = ScaffoldMessenger.of(context);
    final view = await ref.read(suggestionViewsProvider).load(link.suggestion);
    if (view == null || !context.mounted) return;
    final choice = await SuggestionSheet.show(
      context,
      view,
      otherTitle: link.other.title,
      onOpenNote: onOpenNote,
    );
    final actions = ref.read(suggestionActionsProvider);
    final s = link.suggestion;
    if (choice == null) {
      await actions.notSure(s);
      return;
    }
    await beforeChange();
    final Undo undo;
    if (choice == SheetChoice.accept) {
      unawaited(Haptics.play(HapticEvent.accept));
      undo = await actions.accept(s);
    } else {
      undo = await actions.reject(s);
    }
    await afterChange();
    UndoSnackBar.show(
      messenger,
      message: choice == SheetChoice.accept
          ? AppCopy.linked
          : AppCopy.notLinked,
      onUndo: () async {
        unawaited(Haptics.play(HapticEvent.undo));
        await beforeChange();
        await undo();
        await afterChange();
      },
    );
  }
}
