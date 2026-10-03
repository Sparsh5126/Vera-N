import 'package:flutter/material.dart';

import '../../../core/models/search_hit.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/highlighted_text.dart';

/// One search result: title, date, and the passage with matched words
/// highlighted.
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.hit,
    required this.dateLabel,
    required this.onTap,
  });

  /// How many lines of the matching passage to show.
  static const snippetLines = 3;

  final SearchHit hit;
  final String dateLabel;
  final VoidCallback onTap;

  /// A one-line note's passage is just its title again: skip it.
  bool get _showSnippet {
    final passage = hit.snippet.text.replaceAll('…', '').trim();
    return passage.isNotEmpty && passage != hit.title.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpace.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: HighlightedText(
                      text: hit.title.text,
                      matches: hit.title.matches,
                      style: styles.cardTitle,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  Text(dateLabel, style: styles.small),
                ],
              ),
              if (_showSnippet) ...[
                const SizedBox(height: AppSpace.xs),
                HighlightedText(
                  text: hit.snippet.text,
                  matches: hit.snippet.matches,
                  style: styles.card,
                  maxLines: snippetLines,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
