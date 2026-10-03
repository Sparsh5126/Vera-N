import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/section_label.dart';

/// "Recent searches": tap one to search again, ✕ to remove it.
class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required this.queries,
    required this.onSelected,
    required this.onRemove,
  });

  final List<String> queries;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSize.navBarClearance),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.m,
            AppSpace.m,
            AppSpace.m,
            AppSpace.xs,
          ),
          child: SectionLabel(AppCopy.recentSearches),
        ),
        for (final q in queries)
          ListTile(
            contentPadding: const EdgeInsets.only(left: AppSpace.m),
            title: Text(q, style: context.textStyles.body),
            onTap: () => onSelected(q),
            trailing: IconButton(
              onPressed: () => onRemove(q),
              tooltip: AppCopy.removeRecentSearch,
              icon: Icon(Icons.close, color: context.colors.textSecondary),
            ),
          ),
      ],
    );
  }
}
