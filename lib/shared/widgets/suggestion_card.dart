import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/models/suggestion_view.dart';
import '../../core/styles/app_styles.dart';
import 'highlighted_text.dart';

/// One side of a suggestion: a note, when it was written, and the passage
/// that matched.
class SuggestionSide {
  const SuggestionSide({
    required this.label,
    required this.title,
    required this.passage,
    required this.onOpen,
  });

  /// e.g. "NEW · Today".
  final String label;
  final String title;
  final String passage;
  final VoidCallback onOpen;
}

/// The words around a suggestion card: each side's label, the reason,
/// and for copies which note Merge keeps ([hint]). A link names the other
/// note ([otherTitle], or the older note); a tag says which tag and that
/// notes like this one have it, or that it is a new one.
({String first, String second, String reason, String? hint}) suggestionWording(
  SuggestionView view, {
  String? otherTitle,
}) {
  final s = view.suggestion;
  if (s.isTag) {
    return (
      first: AppCopy.tagThisNote,
      second: AppCopy.tagHasIt(s.tag),
      reason: view.single
          ? AppCopy.newTagReason(s.tag)
          : AppCopy.tagReason(s.tag),
      hint: null,
    );
  }
  final kept = view.keep == null ? null : view.noteOf(view.keep!);
  return (
    first: AppCopy.reviewNewLabel,
    second: AppCopy.reviewOlderLabel,
    reason: s.isDuplicate
        ? AppCopy.duplicateReason
        : AppCopy.suggestionReason(otherTitle ?? view.older.title),
    hint: kept == null ? null : AppCopy.mergeKeeps(kept.title),
  );
}

/// The suggestion card (UI spec §8): both notes with the matching passage
/// highlighted, the plain-language reason between them, and "Why?" to see
/// the passages in full. Used by Review and the note's suggestion sheet.
///
/// The laptop's sentence ([detail]) shows under the reason, dimmed like
/// every AI suggestion; [hint] closes the card (what Merge does).
class SuggestionCard extends StatefulWidget {
  const SuggestionCard({
    super.key,
    required this.newer,
    required this.older,
    required this.reason,
    this.detail = '',
    this.hint,
  });

  final SuggestionSide newer;

  /// Null shows one note only (a new tag no other note has).
  final SuggestionSide? older;
  final String reason;
  final String detail;
  final String? hint;

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard> {
  bool _why = false;

  static const _collapsedLines = 4;
  static const _expandedLines = 12;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpace.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _side(context, widget.newer),
            const SizedBox(height: AppSpace.m),
            _reason(context),
            if (widget.detail.isNotEmpty) _detail(context),
            if (widget.older case final older?) ...[
              const SizedBox(height: AppSpace.m),
              _side(context, older),
            ],
            if (widget.hint case final hint?) ...[
              const SizedBox(height: AppSpace.m),
              Text(
                hint,
                style: context.textStyles.small.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _side(BuildContext context, SuggestionSide side) {
    final styles = context.textStyles;
    final passage = '“${side.passage}”';
    return InkWell(
      onTap: side.onOpen,
      borderRadius: AppRadius.cardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(side.label, style: styles.sectionLabel),
          const SizedBox(height: AppSpace.xs),
          Text(
            side.title,
            style: styles.cardTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpace.xs),
          HighlightedText(
            text: passage,
            matches: [TextRange(start: 1, end: passage.length - 1)],
            style: styles.card,
            maxLines: _why ? _expandedLines : _collapsedLines,
          ),
        ],
      ),
    );
  }

  /// Written by the laptop's AI: in the quieter colour of suggestions,
  /// set under the reason (kept at full contrast for reading).
  Widget _detail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpace.l, top: AppSpace.xs),
      child: Text(
        widget.detail,
        style: context.textStyles.body.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }

  Widget _reason(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Row(
      children: [
        Icon(
          Icons.swap_vert,
          size: AppSize.iconSmall,
          color: colors.textSecondary,
        ),
        const SizedBox(width: AppSpace.s),
        Expanded(
          child: Text(
            widget.reason,
            style: styles.body.copyWith(color: colors.textSecondary),
          ),
        ),
        TextButton.icon(
          onPressed: () => setState(() => _why = !_why),
          icon: Icon(_why ? Icons.expand_less : Icons.expand_more),
          label: const Text(AppCopy.why),
          iconAlignment: IconAlignment.end,
        ),
      ],
    );
  }
}
