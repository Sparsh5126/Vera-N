import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';

/// One card of Home's top row: the AI's seal mark, a short label, and a
/// chevron. Tapping opens its screen.
class HomeSuggestionCard extends StatelessWidget {
  const HomeSuggestionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpace.card,
          child: Row(
            children: [
              Icon(icon, color: context.colors.seal),
              // Tight, so "connections" fits on a half-width card.
              const SizedBox(width: AppSpace.s),
              Expanded(child: Text(label, style: context.textStyles.cardTitle)),
              Icon(
                Icons.chevron_right,
                size: AppSize.iconSmall,
                color: context.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
