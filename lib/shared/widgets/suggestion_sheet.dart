import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/models/suggestion_view.dart';
import '../../core/styles/app_styles.dart';
import 'decision_buttons.dart';
import 'suggestion_card.dart';

enum SheetChoice { accept, reject }

/// The suggestion card in a bottom sheet, buttons only (UI spec §8), from
/// a note's dimmed chip or a dashed line in the Graph. The reason names
/// [otherTitle]; [dateLabel] words each note's date. Returns the choice,
/// or null when closed (which counts as not sure).
abstract final class SuggestionSheet {
  static Future<SheetChoice?> show(
    BuildContext context,
    SuggestionView view, {
    required String otherTitle,
    required ValueChanged<int> onOpenNote,
    required String Function(DateTime) dateLabel,
  }) {
    SuggestionSide side(String label, SuggestedNote note) => SuggestionSide(
      label: '$label · ${dateLabel(note.created)}',
      title: note.title,
      passage: note.passage,
      onOpen: () {
        Navigator.of(context, rootNavigator: true).pop();
        onOpenNote(note.ref);
      },
    );
    return showModalBottomSheet<SheetChoice>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpace.m,
            right: AppSpace.m,
            bottom: AppSpace.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SuggestionCard(
                newer: side(AppCopy.reviewNewLabel, view.newer),
                older: side(AppCopy.reviewOlderLabel, view.older),
                reason: AppCopy.suggestionReason(otherTitle),
              ),
              const SizedBox(height: AppSpace.m),
              DecisionButtons(
                onReject: () => Navigator.pop(sheet, SheetChoice.reject),
                onAccept: () => Navigator.pop(sheet, SheetChoice.accept),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
