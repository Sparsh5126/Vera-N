import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// "All caught up.", quietly: no streaks, rewards or "more" button. The
/// next batch waits for the next visit (UI spec §6).
class ReviewDone extends StatelessWidget {
  const ReviewDone({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppCopy.allCaughtUp, style: context.textStyles.cardTitle),
    );
  }
}
