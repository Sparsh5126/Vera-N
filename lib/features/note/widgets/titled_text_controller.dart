import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import '../state/link_markup.dart';

/// The note editor's text. One plain text, shown with:
/// - the first line in the title style (the first line *is* the title);
/// - links shown as just their title, underlined, with the `[[name|` and
///   `]]` markup kept in the text but hidden; the cursor skips the hidden
///   parts and an edit into them removes the whole link ([LinkMarkup]);
/// - the keyboard's composing underline, which Hindi and other
///   transliterating keyboards rely on.
class TitledTextController extends TextEditingController {
  TitledTextController({super.text});

  /// Set from the theme by the screen; until then the body style is used.
  TextStyle? titleStyle;
  AppPalette? palette;

  @override
  set value(TextEditingValue newValue) {
    super.value = LinkMarkup.protect(value, newValue);
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
    final links = LinkMarkup.find(text);
    final composing = value.composing;
    final showComposing = withComposing && value.isComposingRangeValid;

    final cuts = {0, titleEnd, text.length};
    for (final l in links) {
      cuts.addAll([l.start, l.labelStart, l.labelEnd, l.end]);
    }
    if (showComposing) cuts.addAll([composing.start, composing.end]);
    final points = cuts.where((c) => c <= text.length).toList()..sort();

    final spans = <TextSpan>[];
    for (var i = 0; i + 1 < points.length; i++) {
      final start = points[i];
      final end = points[i + 1];
      if (start == end) continue;
      var s = start < titleEnd ? (titleStyle ?? base) : base;
      final link = _linkAt(links, start);
      final palette = this.palette;
      if (link != null && start < link.labelStart || _inEnd(link, start)) {
        s = AppTextStyles.hidden(s);
      } else if (link != null && palette != null) {
        s = AppTextStyles.link(s, palette);
      }
      if (showComposing && start >= composing.start && end <= composing.end) {
        s = s.copyWith(decoration: TextDecoration.underline);
      }
      spans.add(TextSpan(text: text.substring(start, end), style: s));
    }
    return TextSpan(style: base, children: spans);
  }

  static LinkRange? _linkAt(List<LinkRange> links, int offset) {
    for (final l in links) {
      if (offset >= l.start && offset < l.end) return l;
    }
    return null;
  }

  static bool _inEnd(LinkRange? link, int offset) =>
      link != null && offset >= link.labelEnd;
}
