import 'package:flutter/services.dart';

import '../../../core/storage/files/note_markup.dart';

/// Keeps hidden Markdown intact while editing, so the user only ever sees
/// formatting, never symbols:
/// - the cursor steps over hidden symbols in the direction it moved;
/// - deleting into a link removes the link; into an attachment or a web
///   link card, the whole card; into bold markers, the bold;
///   into a checkbox or bullet, that marker (the line stays); backspace
///   right after a list number removes the number;
/// - Enter on a checklist, bullet or numbered line starts the next one
///   (numbers count on, and the items below are renumbered); Enter on an
///   empty item ends the list.
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
    // The cursor sits right after what was typed. (Comparing the texts is
    // ambiguous when Enter lands next to another line break.)
    final sel = next.selection;
    if (!sel.isValid || !sel.isCollapsed || sel.baseOffset < 1) return null;
    final at = sel.baseOffset - 1;
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
      final caret = at + 1;
      final number = span.number;
      if (number != null) {
        final prefix = '${number + 1}. ';
        final text = next.text.replaceRange(caret, caret, prefix);
        return _value(
          renumberAfter(text, caret, number + 1),
          caret + prefix.length,
        );
      }
      final prefix = span.kind == MarkupKind.checkbox
          ? _checkboxPrefix
          : _bulletPrefix;
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
      if (span.isBlock) {
        final removed = _removeEmbed(text, span, s, e);
        if (removed != null) return removed;
        continue;
      }
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
        case MarkupKind.numbered:
          // Only the space after the number: the digits are ordinary text.
          if (s != span.contentStart - 1 || e != span.contentStart) {
            return null;
          }
          return _value(
            text.replaceRange(span.start, span.contentStart, ''),
            span.start,
          );
        case MarkupKind.checkbox:
        case MarkupKind.bullet:
          if (e > span.contentStart) return null;
          return _value(
            text.replaceRange(span.start, span.contentStart, ''),
            span.start,
          );
        case MarkupKind.embed:
        case MarkupKind.webLink:
          return null;
      }
    }
    return null;
  }

  /// Deleting into an attachment or a web link card, or the line break
  /// right after it (backspace at the start of the next line), removes the
  /// whole card with its line, so its markup never shows half-deleted.
  static TextEditingValue? _removeEmbed(
    String text,
    MarkupSpan span,
    int s,
    int e,
  ) {
    final breakAfter = span.end < text.length && text[span.end] == '\n' ? 1 : 0;
    final into = s < span.end && e > span.start;
    final lineBreak = s == span.end && e == span.end + breakAfter;
    if (!into && !(lineBreak && breakAfter == 1)) return null;
    final from = s < span.start ? s : span.start;
    final lineEnd = span.end + breakAfter;
    final to = e > lineEnd ? e : lineEnd;
    return _value(text.replaceRange(from, to, ''), from);
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
      if (span.kind == MarkupKind.embed) {
        final to = _pastEmbed(next.text, span, at, forward);
        if (to == null) continue;
        return next.copyWith(selection: TextSelection.collapsed(offset: to));
      }
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

  /// Where the cursor goes instead of [at] on or inside an attachment's
  /// line: the next line going forward, the previous line going back, so
  /// typing never lands on the attachment's line. Null if [at] is clear.
  static int? _pastEmbed(String text, MarkupSpan span, int at, bool forward) {
    if (at < span.start || at > span.end) return null;
    final after = span.end < text.length ? span.end + 1 : null;
    final before = span.start > 0 ? span.start - 1 : null;
    if (forward || before == null) return after ?? before;
    return before;
  }

  static final _numberedLine = RegExp(r'^(\d{1,9})\. ');

  /// Renumbers the numbered lines that directly follow the line starting
  /// at [lineStart] (numbered [number]): number + 1, number + 2, ….
  static String renumberAfter(String text, int lineStart, int number) {
    final lineEnd = text.indexOf('\n', lineStart);
    if (lineEnd == -1) return text;
    final rest = text.substring(lineEnd + 1).split('\n');
    var next = number + 1;
    for (var i = 0; i < rest.length; i++) {
      final m = _numberedLine.firstMatch(rest[i]);
      if (m == null) break;
      rest[i] = rest[i].replaceRange(0, m.group(1)!.length, '${next++}');
    }
    return '${text.substring(0, lineEnd + 1)}${rest.join('\n')}';
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
