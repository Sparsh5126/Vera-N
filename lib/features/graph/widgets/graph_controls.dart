import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/filter_pill.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../state/graph_view.dart';

/// The Graph's filter pills (Folder, Tag, and the two toggles) with the
/// search icon; while focused, a second row with how far to reach and
/// "Show all".
class GraphControls extends StatelessWidget {
  const GraphControls({
    super.key,
    required this.view,
    required this.focusTitle,
    required this.offerSuggestions,
    required this.onFolder,
    required this.onTag,
    required this.onFind,
    required this.controls,
  });

  final GraphViewState view;

  /// The focused note's title, or null when not focused.
  final String? focusTitle;

  /// "Show suggestions" appears only while suggestions are on in Settings.
  final bool offerSuggestions;
  final VoidCallback onFolder;
  final VoidCallback onTag;
  final VoidCallback onFind;
  final GraphView controls;

  @override
  Widget build(BuildContext context) {
    final folder = view.filters.folder;
    final tag = view.filters.tag;
    final focusTitle = this.focusTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: AppSpace.screen,
                child: Row(
                  spacing: AppSpace.s,
                  children: [
                    FilterPill(
                      label: folder ?? AppCopy.filterFolder,
                      active: folder != null,
                      onTap: onFolder,
                    ),
                    FilterPill(
                      label: tag == null
                          ? AppCopy.filterTag
                          : AppCopy.tagLabel(tag),
                      active: tag != null,
                      onTap: onTag,
                    ),
                    FilterPill(
                      label: AppCopy.showUnlinked,
                      active: view.showUnlinked,
                      showArrow: false,
                      onTap: controls.toggleUnlinked,
                    ),
                    if (offerSuggestions)
                      FilterPill(
                        label: AppCopy.showSuggestions,
                        active: view.showSuggestions,
                        showArrow: false,
                        onTap: controls.toggleSuggestions,
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onFind,
              icon: const Icon(Icons.search),
              tooltip: AppCopy.findNote,
            ),
          ],
        ),
        if (focusTitle != null) ...[
          const SizedBox(height: AppSpace.s),
          Padding(
            padding: AppSpace.screen,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppCopy.focusOn(focusTitle),
                    style: context.textStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: controls.clearFocus,
                  child: const Text(AppCopy.focusOff),
                ),
              ],
            ),
          ),
          PillTabs(
            labels: [
              for (var i = 1; i <= GraphView.maxHops; i++) AppCopy.hops(i),
            ],
            selected: view.hops - 1,
            onSelected: (i) => controls.setHops(i + 1),
          ),
        ],
      ],
    );
  }
}
