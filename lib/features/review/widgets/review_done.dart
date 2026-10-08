import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/pill_button.dart';

/// "All caught up.", quietly: no streaks or rewards. "Review more" only
/// when more are waiting (UI spec §6).
class ReviewDone extends StatelessWidget {
  const ReviewDone({super.key, required this.onMore});

  /// Null when nothing more is waiting.
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final onMore = this.onMore;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppCopy.allCaughtUp, style: context.textStyles.cardTitle),
          if (onMore != null) ...[
            const SizedBox(height: AppSpace.l),
            PillButton(label: AppCopy.reviewMore, onPressed: onMore),
          ],
        ],
      ),
    );
  }
}
