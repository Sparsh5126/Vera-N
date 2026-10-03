import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/models/search_filters.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/filter_pill.dart';

/// The Folder, Tag and Date pills under the search box.
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.filters,
    required this.onFolder,
    required this.onTag,
    required this.onDate,
  });

  final SearchFilters filters;
  final VoidCallback onFolder;
  final VoidCallback onTag;
  final VoidCallback onDate;

  /// The words shown for each Date choice.
  static String dateLabel(DateFilter date) => switch (date) {
    DateFilter.today => AppCopy.dateToday,
    DateFilter.last7Days => AppCopy.dateLast7Days,
    DateFilter.last30Days => AppCopy.dateLast30Days,
    DateFilter.thisYear => AppCopy.dateThisYear,
  };

  @override
  Widget build(BuildContext context) {
    final folder = filters.folder;
    final tag = filters.tag;
    final date = filters.date;
    return SingleChildScrollView(
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
            label: tag == null ? AppCopy.filterTag : AppCopy.tagLabel(tag),
            active: tag != null,
            onTap: onTag,
          ),
          FilterPill(
            label: date == null ? AppCopy.filterDate : dateLabel(date),
            active: date != null,
            onTap: onDate,
          ),
        ],
      ),
    );
  }
}
