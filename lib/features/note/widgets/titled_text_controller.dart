import 'package:flutter/material.dart';

import '../../../core/storage/files/note_markup.dart';
import '../../../core/styles/app_styles.dart';
import '../state/markup_editing.dart';
import 'checkbox_glyph.dart';

/// The note editor's text: one plain Markdown text, shown as formatting.
/// - The first line uses the title style (the first line *is* the title).
/// - Links show only their title, underlined; bold shows bold; checklist
///   lines show a real checkbox to tick; bullet lines show a bullet. The
///   Markdown symbols stay in the text but are hidden ([MarkupEditing]
///   keeps the cursor and deletions away from them).
/// - The keyboard's composing underline is kept, which Hindi and other
///   transliterating keyboards rely on.
class TitledTextController extends TextEditingController {
  TitledTextController({super.text});

  /// Set from the theme by the screen; until then plain styles are used.
  TextStyle? titleStyle;
  AppPalette? palette;

  /// Called after a checkbox is ticked or unticked, to save it.
  VoidCallback? onCheckboxToggled;

  @override
  set value(TextEditingValue newValue) {
    super.value = MarkupEditing.protect(value, newValue);
  }

  void _toggle(MarkupSpan span) {
    super.value = MarkupEditing.toggleCheckbox(value, span);
    onCheckboxToggled?.call();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    final base = style ?? DefaultTextStyle.of(context).style;
    final lineBreak = text.indexOf('\n');
    final titleEnd = lineBreak == -1 ? text.length : lineBreak;
    final spans = NoteMarkup.find(text);
    final composing = value.composing;
    final showComposing = withComposing && value.isComposingRangeValid;

    final cuts = {0, titleEnd, text.length};
    for (final s in spans) {
      cuts.addAll([s.start, s.contentStart, s.contentEnd, s.end]);
      if (s.hasGlyph) cuts.addAll([s.glyphAt, s.glyphAt + 1]);
    }
    if (showComposing) cuts.addAll([composing.start, composing.end]);
    final points = cuts.where((c) => c <= text.length).toList()..sort();

    // One pass over the pieces: [active] holds only the spans covering the
    // current piece, so long notes stay linear, not pieces × spans.
    final glyphs = <int, MarkupSpan>{};
    for (final s in spans) {
      if (s.hasGlyph) glyphs.putIfAbsent(s.glyphAt, () => s);
    }
    final active = <MarkupSpan>[];
    var nextSpan = 0;
    final children = <InlineSpan>[];
    for (var i = 0; i + 1 < points.length; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a == b) continue;
      while (nextSpan < spans.length && spans[nextSpan].start <= a) {
        active.add(spans[nextSpan++]);
      }
      active.removeWhere((s) => s.end <= a);
      final lineStyle = a < titleEnd ? (titleStyle ?? base) : base;
      final glyph = glyphs[a];
      if (glyph != null) {
        children.add(_glyph(glyph, lineStyle));
        continue;
      }
      var s = _styleAt(active, a, lineStyle);
      if (showComposing && a >= composing.start && b <= composing.end) {
        s = s.copyWith(decoration: TextDecoration.underline);
      }
      children.add(TextSpan(text: text.substring(a, b), style: s));
    }
    return TextSpan(style: base, children: children);
  }

  TextStyle _styleAt(List<MarkupSpan> spans, int at, TextStyle style) {
    final palette = this.palette;
    var s = style;
    for (final span in spans) {
      if (span.hides(at)) return AppTextStyles.hidden(style);
      final inContent = at >= span.contentStart && at < span.contentEnd;
      if (!inContent) continue;
      switch (span.kind) {
        case MarkupKind.bold:
          s = AppTextStyles.strong(s);
        case MarkupKind.link:
          if (palette != null) s = AppTextStyles.link(s, palette);
        case MarkupKind.checkbox:
          if (span.checked && palette != null) {
            s = AppTextStyles.done(s, palette);
          }
        case MarkupKind.bullet:
        case MarkupKind.numbered:
          break;
      }
    }
    return s;
  }

  InlineSpan _glyph(MarkupSpan span, TextStyle style) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: CheckboxGlyph(
        bullet: span.kind == MarkupKind.bullet,
        checked: span.checked,
        textStyle: style,
        onTap: span.kind == MarkupKind.checkbox ? () => _toggle(span) : null,
      ),
    );
  }
}
