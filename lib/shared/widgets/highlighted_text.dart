import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// Text with some ranges marked by the soft seal fill (search matches,
/// matched passages).
/// The words keep the normal text color, so contrast stays the same.
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.matches,
    required this.style,
    this.maxLines,
  });

  final String text;
  final List<TextRange> matches;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final marked = style.copyWith(backgroundColor: context.colors.sealSoft);
    final spans = <TextSpan>[];
    var at = 0;
    for (final m in matches) {
      if (m.start < at || m.end > text.length) continue;
      if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
      spans.add(TextSpan(text: text.substring(m.start, m.end), style: marked));
      at = m.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
