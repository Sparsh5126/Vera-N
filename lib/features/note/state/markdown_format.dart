import 'package:flutter/services.dart';

import 'numbered_points.dart';

/// Line markers the formatting row can toggle.
enum LineMark {
  list('- '),
  checklist('- [ ] ');

  const LineMark(this.prefix);

  final String prefix;
}

/// Formatting-row edits on the selected text, as plain Markdown. Every
/// action is a toggle: applying it twice gives back the original text.
abstract final class MarkdownFormat {
  static const _bold = '**';

  /// A letter, digit or joining mark (Devanagari vowel signs count, so a
  /// Hindi word is one word).
  static final _wordChar = RegExp(r'[\p{L}\p{M}\p{N}_]', unicode: true);

  /// Bold with nothing selected: the word the cursor is in or touches,
  /// leaving the cursor at its end. Nothing happens between words.
  static TextEditingValue _boldWordAt(TextEditingValue value) {
    final text = value.text;
    final at = value.selection.baseOffset;
    var s = at, e = at;
    while (s > 0 && _wordChar.hasMatch(text[s - 1])) {
      s--;
    }
    while (e < text.length && _wordChar.hasMatch(text[e])) {
      e++;
    }
    if (s == e) return value;
    final done = toggleBold(
      value.copyWith(
        selection: TextSelection(baseOffset: s, extentOffset: e),
      ),
    );
    return done.copyWith(
      selection: TextSelection.collapsed(offset: done.selection.end),
    );
  }

  /// Any list or checklist marker at the start of a line.
  static final _anyMark = RegExp(r'^- (\[[ xX]\] )?');

  /// Wraps the selection in `**`, or unwraps it if already bold.
  static TextEditingValue toggleBold(TextEditingValue value) {
    final sel = value.selection;
    if (!sel.isValid) return value;
    if (sel.isCollapsed) return _boldWordAt(value);
    final text = value.text;
    final s = sel.start;
    final e = sel.end;
    final wrapped =
        s >= _bold.length &&
        e + _bold.length <= text.length &&
        text.substring(s - _bold.length, s) == _bold &&
        text.substring(e, e + _bold.length) == _bold;
    if (wrapped) {
      final inner = text.substring(s, e);
      return TextEditingValue(
        text: text.replaceRange(s - _bold.length, e + _bold.length, inner),
        selection: TextSelection(
          baseOffset: s - _bold.length,
          extentOffset: e - _bold.length,
        ),
      );
    }
    return TextEditingValue(
      text: text.replaceRange(s, e, '$_bold${text.substring(s, e)}$_bold'),
      selection: TextSelection(
        baseOffset: s + _bold.length,
        extentOffset: e + _bold.length,
      ),
    );
  }

  /// Puts [mark] on every non-empty selected line, or takes it off if all
  /// of them already have it. A list line becomes a checklist line (and
  /// back) instead of getting both markers. List on numbered points keeps
  /// them numbered, one per line ([NumberedPoints]).
  static TextEditingValue toggleLines(TextEditingValue value, LineMark mark) {
    final sel = value.selection;
    if (!sel.isValid) return value;
    final text = value.text;
    final start = sel.start == 0
        ? 0
        : text.lastIndexOf('\n', sel.start - 1) + 1;
    final endBreak = text.indexOf('\n', sel.end);
    final end = endBreak == -1 ? text.length : endBreak;
    final lines = text.substring(start, end).split('\n');
    final numbered = mark == LineMark.list
        ? NumberedPoints.asList(lines)
        : null;
    final changed = (numbered ?? _marked(lines, mark)).join('\n');
    return TextEditingValue(
      text: text.replaceRange(start, end, changed),
      selection: TextSelection(
        baseOffset: start,
        extentOffset: start + changed.length,
      ),
    );
  }

  static List<String> _marked(List<String> lines, LineMark mark) {
    final filled = lines.where((l) => l.trim().isNotEmpty);
    final allMarked = filled.isNotEmpty && filled.every((l) => _has(l, mark));
    return [
      for (final l in lines)
        if (l.trim().isEmpty)
          l
        else if (allMarked)
          l.replaceFirst(_anyMark, '')
        else
          '${mark.prefix}${l.replaceFirst(_anyMark, '')}',
    ];
  }

  static bool _has(String line, LineMark mark) {
    final m = _anyMark.firstMatch(line);
    if (m == null) return false;
    final isChecklist = m.group(1) != null;
    return mark == LineMark.checklist ? isChecklist : !isChecklist;
  }

  /// Replaces the selection with [link] (cursor after it).
  static TextEditingValue replaceSelection(
    TextEditingValue value,
    String link,
  ) {
    final sel = value.selection;
    if (!sel.isValid) return value;
    return TextEditingValue(
      text: value.text.replaceRange(sel.start, sel.end, link),
      selection: TextSelection.collapsed(offset: sel.start + link.length),
    );
  }

  /// The selected words, trimmed; empty if nothing is selected.
  static String selectedText(TextEditingValue value) {
    final sel = value.selection;
    if (!sel.isValid || sel.isCollapsed) return '';
    return value.text.substring(sel.start, sel.end).trim();
  }
}
