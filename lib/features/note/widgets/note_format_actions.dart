import 'package:flutter/material.dart';

import '../state/markdown_format.dart';
import 'note_actions.dart';
import 'titled_text_controller.dart';

/// What the formatting row's buttons do to the editor's text. Each change
/// goes through [onEdited] so it is saved like typing.
class NoteFormatActions {
  NoteFormatActions(this._text, this._actions, this._onEdited);

  final TitledTextController _text;
  final NoteActions _actions;
  final ValueChanged<String> _onEdited;

  void bold() => _apply(MarkdownFormat.toggleBold(_text.value));

  void list() => _apply(MarkdownFormat.toggleLines(_text.value, LineMark.list));

  void checklist() =>
      _apply(MarkdownFormat.toggleLines(_text.value, LineMark.checklist));

  /// Turns the selected words into a link to a picked note; the words stay
  /// on screen as the link's title.
  Future<void> link(BuildContext context, int? currentRef) async {
    final before = _text.value;
    final words = MarkdownFormat.selectedText(before);
    final link = await _actions.pickLink(
      context,
      currentRef,
      label: words.isEmpty ? null : words,
    );
    if (link != null) _apply(MarkdownFormat.replaceSelection(before, link));
  }

  void _apply(TextEditingValue next) {
    if (next.text == _text.text && next.selection == _text.selection) return;
    _text.value = next;
    _onEdited(_text.text);
  }
}
