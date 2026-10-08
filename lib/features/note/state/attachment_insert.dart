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
    return TextEditingValue(
      text: text.replaceRange(at, at, inserted),
      selection: TextSelection.collapsed(offset: caret),
    );
  }
}
