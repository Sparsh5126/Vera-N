import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/feedback/haptics.dart';
import '../../core/models/suggestion.dart';
import '../../core/models/suggestion_view.dart';
import 'suggestion_sheet.dart';
import 'undo_snack_bar.dart';

/// A suggestion opened outside Review (a note's dimmed chip, a dashed line
/// in the Graph): the suggestion sheet, then the same accept / reject as
/// Review, with Undo (UI spec §7–8). Closing the sheet counts as "not
/// sure": the suggestion stays.
///
/// The actions come in as callbacks (the screen passes the shared
/// suggestion actions), so this stays a plain shared piece. [accept] and
/// [reject] return their undo.
///
/// Accepting may add a link to an open note's text, so a note screen saves
/// its unsaved text first ([beforeChange]) and reloads it after
/// ([afterChange]); nothing the user typed is lost.
class SuggestionFlow {
  SuggestionFlow({
    required this.load,
    required this.accept,
    required this.reject,
    required this.notSure,
    required this.dateLabel,
    required this.onOpenNote,
    this.beforeChange,
    this.afterChange,
    this.aboveNavBar = false,
  });

  final Future<SuggestionView?> Function(Suggestion) load;
  final Future<AsyncCallback> Function(Suggestion) accept;
  final Future<AsyncCallback> Function(Suggestion) reject;
  final Future<void> Function(Suggestion) notSure;
  final String Function(DateTime) dateLabel;
  final ValueChanged<int> onOpenNote;
  final AsyncCallback? beforeChange;
  final AsyncCallback? afterChange;

  /// Shown on a tab screen: the Undo message keeps clear of the nav bar.
  final bool aboveNavBar;

  /// Shows suggestion [s]. The reason names [otherTitle] (the note the
  /// user isn't in), or the older note when there is no such note.
  Future<void> open(
    BuildContext context,
    Suggestion s, {
    String? otherTitle,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final view = await load(s);
    if (view == null || !context.mounted) return;
    final choice = await SuggestionSheet.show(
      context,
      view,
      otherTitle: otherTitle,
      onOpenNote: onOpenNote,
      dateLabel: dateLabel,
    );
    if (choice == null) {
      await notSure(s);
      return;
    }
    await beforeChange?.call();
    final accepted = choice == SheetChoice.accept;
    if (accepted) unawaited(Haptics.play(HapticEvent.accept));
    final undo = await (accepted ? accept(s) : reject(s));
    await afterChange?.call();
    UndoSnackBar.show(
      messenger,
      message: accepted ? AppCopy.linked : AppCopy.notLinked,
      aboveNavBar: aboveNavBar,
      onUndo: () async {
        unawaited(Haptics.play(HapticEvent.undo));
        await beforeChange?.call();
        await undo();
        await afterChange?.call();
      },
    );
  }
}
