import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';
import 'filter_pill.dart';

/// A row of thin pills where one is chosen, e.g. Recent | Folders | Tags.
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpace.screen,
      child: Row(
        spacing: AppSpace.s,
        children: [
          for (var i = 0; i < labels.length; i++)
            FilterPill(
              label: labels[i],
              active: i == selected,
              showArrow: false,
              onTap: () => onSelected(i),
            ),
        ],
      ),
    );
  }
}
