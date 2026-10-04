import 'package:flutter/services.dart';

import '../../../core/storage/files/note_markup.dart';

/// Keeps hidden Markdown intact while editing, so the user only ever sees
/// formatting, never symbols:
/// - the cursor steps over hidden symbols in the direction it moved;
/// - deleting into a link removes the link; into bold markers, the bold;
///   into a checkbox or bullet, that marker (the line stays);
/// - Enter on a checklist or bullet line starts the next one, and Enter on
///   an empty one ends the list.
abstract final class MarkupEditing {
  static const _checkboxPrefix = '- [ ] ';
  static const _bulletPrefix = '- ';

  /// [next] adjusted for hidden Markdown, given the [previous] value.
  static TextEditingValue protect(
    TextEditingValue previous,
    TextEditingValue next,
  ) {
    if (next.composing.isValid) return next;
    final grew = next.text.length - previous.text.length;
    if (grew == 1) {
      final continued = _continueList(previous, next);
      if (continued != null) return continued;
    } else if (grew < 0) {
      final repaired = _repairDeletion(previous, next);
      if (repaired != null) return repaired;
    }
    return _snapCaret(previous, next);
  }

  static TextEditingValue? _continueList(
    TextEditingValue previous,
    TextEditingValue next,
  ) {
    final at = _changeStart(previous.text, next.text);
    if (next.text[at] != '\n') return null;
    for (final span in NoteMarkup.find(previous.text)) {
      if (!span.isLine || at < span.contentStart || at > span.contentEnd) {
        continue;
      }
      if (span.contentStart == span.contentEnd) {
        // Enter on an empty item ends the list.
        return _value(
          previous.text.replaceRange(span.start, span.contentStart, ''),
          span.start,
        );
      }
      final prefix = span.kind == MarkupKind.checkbox
          ? _checkboxPrefix
          : _bulletPrefix;
      final caret = at + 1;
      return _value(
        next.text.replaceRange(caret, caret, prefix),
        caret + prefix.length,
      );
    }
    return null;
  }

  static TextEditingValue? _repairDeletion(
    TextEditingValue previous,
    TextEditingValue next,
  ) {
    final s = _changeStart(previous.text, next.text);
    final e = s + previous.text.length - next.text.length;
    final text = previous.text;
    for (final span in NoteMarkup.find(text)) {
      final inStart = s < span.contentStart && e > span.start;
      final inEnd = !span.isLine && s < span.end && e > span.contentEnd;
      if (!inStart && !inEnd) continue;
      switch (span.kind) {
        case MarkupKind.link:
          final from = s < span.start ? s : span.start;
          final to = e > span.end ? e : span.end;
          return _value(text.replaceRange(from, to, ''), from);
        case MarkupKind.bold:
          if (s < span.start || e > span.end) return null;
          final inner = text.substring(span.contentStart, span.contentEnd);
          final unbolded = text.replaceRange(span.start, span.end, inner);
          return _value(
            unbolded,
            inStart ? span.start : span.start + inner.length,
          );
        case MarkupKind.checkbox:
        case MarkupKind.bullet:
          if (e > span.contentStart) return null;
          return _value(
            text.replaceRange(span.start, span.contentStart, ''),
            span.start,
          );
      }
    }
    return null;
  }

  static TextEditingValue _snapCaret(
    TextEditingValue previous,
    TextEditingValue next,
  ) {
    final sel = next.selection;
    if (!sel.isValid || !sel.isCollapsed) return next;
    final at = sel.baseOffset;
    final forward = at >= previous.selection.baseOffset;
    for (final span in NoteMarkup.find(next.text)) {
      if (!span.blocksCaret(at)) continue;
      final int to;
      if (span.isLine) {
        to = forward || span.start == 0 ? span.contentStart : span.start - 1;
      } else if (at < span.contentStart) {
        to = forward ? span.contentStart : span.start;
      } else {
        to = forward ? span.end : span.contentEnd;
      }
      return next.copyWith(selection: TextSelection.collapsed(offset: to));
    }
    return next;
  }

  /// Where [before] and [after] first differ.
  static int _changeStart(String before, String after) {
    var i = 0;
    final limit = before.length < after.length ? before.length : after.length;
    while (i < limit && before.codeUnitAt(i) == after.codeUnitAt(i)) {
      i++;
    }
    return i;
  }

  static TextEditingValue _value(String text, int caret) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: caret),
  );

  /// Ticks or unticks the checkbox of [span].
  static TextEditingValue toggleCheckbox(
    TextEditingValue value,
    MarkupSpan span,
  ) {
    final at = span.glyphAt;
    return value.copyWith(
      text: value.text.replaceRange(at, at + 1, span.checked ? ' ' : 'x'),
      composing: TextRange.empty,
    );
  }

  /// The link whose visible title contains [offset] (not at its edges, so
  /// a cursor placed just before or after a link doesn't count).
  static MarkupSpan? linkAt(String text, int offset) {
    for (final span in NoteMarkup.find(text)) {
      if (span.kind == MarkupKind.link &&
          offset > span.contentStart &&
          offset < span.contentEnd) {
        return span;
      }
    }
    return null;
  }
}
