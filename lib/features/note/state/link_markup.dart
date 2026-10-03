import 'package:flutter/services.dart';

/// Where one `[[link]]` sits in the note text. The file keeps the full
/// markup; the editor shows only [labelStart]..[labelEnd] (the title, or
/// the name for a link without one) and hides the rest.
class LinkRange {
  const LinkRange(this.start, this.labelStart, this.labelEnd, this.end);

  final int start;
  final int labelStart;
  final int labelEnd;
  final int end;

  bool inHiddenStart(int offset) => offset > start && offset < labelStart;
  bool inHiddenEnd(int offset) => offset > labelEnd && offset < end;
}

/// Keeps hidden link markup intact while editing: the cursor skips over
/// it, and an edit that reaches into it removes the whole link.
abstract final class LinkMarkup {
  static final _link = RegExp(r'\[\[([^\[\]|]+?)(?:\|([^\[\]]*))?\]\]');

  static List<LinkRange> find(String text) {
    return [
      for (final m in _link.allMatches(text))
        if (m.group(2)?.trim().isNotEmpty ?? false)
          LinkRange(m.start, m.start + 3 + m.group(1)!.length, m.end - 2, m.end)
        else
          LinkRange(m.start, m.start + 2, m.end - 2, m.end),
    ];
  }

  /// [next] with link markup protected, given the [previous] value.
  static TextEditingValue protect(
    TextEditingValue previous,
    TextEditingValue next,
  ) {
    if (next.composing.isValid) return next;
    if (next.text.length < previous.text.length) {
      final removed = _removeBrokenLink(previous, next);
      if (removed != null) return removed;
    }
    return _snapCursor(previous, next);
  }

  /// A deletion that touched a link's hidden markup removes the link.
  static TextEditingValue? _removeBrokenLink(
    TextEditingValue previous,
    TextEditingValue next,
  ) {
    final cut = _changedRange(previous.text, next.text);
    for (final link in find(previous.text)) {
      final hitsMarkup =
          (cut.start < link.labelStart && cut.end > link.start) ||
          (cut.start < link.end && cut.end > link.labelEnd);
      if (!hitsMarkup) continue;
      final start = cut.start < link.start ? cut.start : link.start;
      final end = cut.end > link.end ? cut.end : link.end;
      return TextEditingValue(
        text: previous.text.replaceRange(start, end, ''),
        selection: TextSelection.collapsed(offset: start),
      );
    }
    return null;
  }

  /// The part of [before] that is gone in [after] (one contiguous edit).
  static TextRange _changedRange(String before, String after) {
    var start = 0;
    while (start < after.length && before[start] == after[start]) {
      start++;
    }
    var endBefore = before.length;
    var endAfter = after.length;
    while (endAfter > start && before[endBefore - 1] == after[endAfter - 1]) {
      endBefore--;
      endAfter--;
    }
    return TextRange(start: start, end: endBefore);
  }

  /// A cursor that lands inside hidden markup jumps across it, in the
  /// direction it was moving.
  static TextEditingValue _snapCursor(
    TextEditingValue previous,
    TextEditingValue next,
  ) {
    final sel = next.selection;
    if (!sel.isValid || !sel.isCollapsed) return next;
    final at = sel.baseOffset;
    final forward = at >= previous.selection.baseOffset;
    for (final link in find(next.text)) {
      int? to;
      if (link.inHiddenStart(at)) to = forward ? link.labelStart : link.start;
      if (link.inHiddenEnd(at)) to = forward ? link.end : link.labelEnd;
      if (to != null) {
        return next.copyWith(selection: TextSelection.collapsed(offset: to));
      }
    }
    return next;
  }
}
