import 'package:flutter/services.dart';

/// Typing `[[` in a note opens the note picker; picking a note replaces
/// the `[[` with the full link.
abstract final class LinkTyping {
  static const _open = '[[';

  /// Whether the user just typed the second `[` of a `[[`.
  static bool justOpened(String before, TextEditingValue after) {
    final sel = after.selection;
    if (!sel.isValid || !sel.isCollapsed || after.composing.isValid) {
      return false;
    }
    final at = sel.baseOffset;
    return after.text.length == before.length + 1 &&
        at >= _open.length &&
        after.text.substring(at - _open.length, at) == _open;
  }

  /// Replaces the `[[` before the cursor with [link], cursor after it.
  static TextEditingValue insert(TextEditingValue value, String link) {
    final at = value.selection.baseOffset;
    final hasOpen =
        at >= _open.length &&
        value.text.substring(at - _open.length, at) == _open;
    final start = hasOpen ? at - _open.length : at;
    final text = value.text.replaceRange(start, at, link);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + link.length),
    );
  }
}
