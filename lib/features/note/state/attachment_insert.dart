import 'package:flutter/services.dart';

import '../../../core/storage/files/note_markup.dart';

/// Puts an attachment into the note where the cursor is, on its own line
/// (UI spec §7), and leaves the cursor on the line after it, ready to
/// keep writing.
abstract final class AttachmentInsert {
  static TextEditingValue insert(TextEditingValue value, String name) {
    final text = value.text;
    final sel = value.selection;
    final at = sel.isValid ? sel.end.clamp(0, text.length) : text.length;
    final lineBefore = at > 0 && text[at - 1] != '\n' ? '\n' : '';
    final embed = '$lineBefore${NoteMarkup.embed(name)}';
    // Reuse the line break that follows, or add one.
    final breakFollows = at < text.length && text[at] == '\n';
    final inserted = breakFollows ? embed : '$embed\n';
    final caret = at + embed.length + 1;
    return roomAfter(
      TextEditingValue(
        text: text.replaceRange(at, at, inserted),
        selection: TextSelection.collapsed(offset: caret),
      ),
    );
  }

  /// With the cursor at the very end, right under a photo or drawing, adds
  /// a line break so the cursor's line isn't the last. Flutter places the
  /// cursor of an empty last line by the line above, and under a tall
  /// picture that is several lines too low. A note ending in an attachment
  /// gets the line to write on.
  static TextEditingValue roomAfter(TextEditingValue value) {
    final text = value.text;
    final sel = value.selection;
    if (!sel.isValid || !sel.isCollapsed || sel.baseOffset != text.length) {
      return value;
    }
    final spans = NoteMarkup.find(text);
    final last = spans.isEmpty ? null : spans.last;
    if (last == null || last.kind != MarkupKind.embed) return value;
    final rest = text.substring(last.end);
    if (rest.isEmpty) {
      // Ends with the attachment itself: a line to write on, and one after.
      return TextEditingValue(
        text: '$text\n\n',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    if (rest != '\n') return value;
    return TextEditingValue(
      text: '$text\n',
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
