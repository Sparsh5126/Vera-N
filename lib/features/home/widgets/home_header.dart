import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// Wordmark and greeting. Scrolls away with the notes.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.m,
        AppSpace.l,
        AppSpace.m,
        AppSpace.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(AppCopy.appName, style: styles.wordmark),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            greeting,
            style: styles.body.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
