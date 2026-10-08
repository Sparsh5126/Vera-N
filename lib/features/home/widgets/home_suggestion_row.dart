import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';

/// The row under the greeting: one card full width, or two side by side.
class HomeSuggestionRow extends StatelessWidget {
  const HomeSuggestionRow({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpace.m,
        right: AppSpace.m,
        bottom: AppSpace.m,
      ),
      child: Row(
        spacing: AppSpace.s,
        children: [for (final card in cards) Expanded(child: card)],
      ),
    );
  }
}
