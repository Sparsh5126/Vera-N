import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// A quiet centered message for empty and error states.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyles.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
