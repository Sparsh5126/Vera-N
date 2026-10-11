import '../../../core/copy/app_copy.dart';
import '../../../core/models/attachment_kind.dart';
import '../../../core/storage/files/attachment_name.dart';
import '../../../core/storage/files/note_markup.dart';
import '../../../core/storage/files/web_link.dart';

/// What a screen reader hears for a note's text, so it reads like the
/// screen, not the Markdown underneath:
/// - hidden symbols (`**`, `[[name|`, `]]`, `- [`) are silent;
/// - a checkbox says whether it is ticked;
/// - a link card says "Link: title, site"; an attachment says what it
///   is ("Photo", "Drawing", "Voice note").
///
/// The result is exactly as long as the text, character for character, so
/// the cursor position the screen reader reports still matches the text.
/// (A card's or checkbox's own glyph is a placeholder Flutter reports by
/// itself; its character is left as it is.)
abstract final class MarkupSemantics {
  static String of(String text, List<MarkupSpan> spans) {
    final spoken = text.split('');
    for (final span in spans) {
      if (span.isBlock) {
        _fill(spoken, span.start + 1, span.end, _blockLabel(text, span));
        continue;
      }
      for (var i = span.start; i < span.end && i < spoken.length; i++) {
        if (span.hides(i)) spoken[i] = ' ';
      }
      if (span.kind == MarkupKind.checkbox && span.glyphAt > span.start) {
        spoken[span.start] = span.checked
            ? AppCopy.checkboxDoneSpoken
            : AppCopy.checkboxOpenSpoken;
      }
    }
    return spoken.join();
  }

  static String _blockLabel(String text, MarkupSpan span) {
    if (span.kind == MarkupKind.webLink) {
      final link = WebLink.parse(text.substring(span.start, span.end));
      return link == null ? '' : AppCopy.linkSpoken(link.label, link.site);
    }
    return switch (AttachmentName.kindOf(span.target ?? '')) {
      AttachmentKind.drawing => AppCopy.drawing,
      AttachmentKind.voice => AppCopy.voiceNote,
      _ => AppCopy.photo,
    };
  }

  /// Writes [label] into [from]..[to], cut or padded with spaces to fit.
  static void _fill(List<String> spoken, int from, int to, String label) {
    for (var i = from; i < to && i < spoken.length; i++) {
      final at = i - from;
      spoken[i] = at < label.length ? label[at] : ' ';
    }
  }
}
