import 'package:flutter/material.dart';

/// Shows the first line of the note in the title style. The note is one
/// plain text: the first line *is* the title, nothing else marks it.
///
/// Keeps the keyboard's composing underline, which Hindi and other
/// transliterating keyboards rely on.
class TitledTextController extends TextEditingController {
  TitledTextController({super.text});

  /// Set from the theme by the screen; until then the body style is used.
  TextStyle? titleStyle;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    final lineBreak = text.indexOf('\n');
    final titleEnd = lineBreak == -1 ? text.length : lineBreak;
    final composing = value.composing;
    final showComposing = withComposing && value.isComposingRangeValid;
    final cuts = {0, titleEnd, text.length};
    if (showComposing) cuts.addAll([composing.start, composing.end]);
    final points = cuts.toList()..sort();

    final spans = <TextSpan>[];
    for (var i = 0; i + 1 < points.length; i++) {
      final start = points[i];
      final end = points[i + 1];
      if (start == end) continue;
      var spanStyle = start < titleEnd ? (titleStyle ?? style) : style;
      if (showComposing && start >= composing.start && end <= composing.end) {
        spanStyle = spanStyle?.copyWith(decoration: TextDecoration.underline);
      }
      spans.add(TextSpan(text: text.substring(start, end), style: spanStyle));
    }
    return TextSpan(style: style, children: spans);
  }
}
