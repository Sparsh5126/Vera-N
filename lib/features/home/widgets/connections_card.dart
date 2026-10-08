import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/ai_settings.dart';
import '../../../core/ai/suggestions/suggestion_providers.dart';
import '../../../core/copy/app_copy.dart';
import '../../../core/navigation/routes.dart';
import 'home_suggestion_card.dart';
import 'home_suggestion_row.dart';

/// Home's top row (UI spec §5): "5 new connections" (opens Review) and
/// Revisit (opens old notes worth another look), side by side. Either
/// takes the full width when alone; the row is hidden when neither has
/// anything. The connections count never passes one batch, so it never
/// becomes a growing number to clear; Revisit shows no count at all.
class ConnectionsCard extends ConsumerWidget {
  const ConnectionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waiting = ref.watch(pendingSuggestionsProvider).value ?? 0;
    final revisit = (ref.watch(revisitProvider).value ?? const []).isNotEmpty;
    final cards = [
      if (waiting > 0)
        HomeSuggestionCard(
          icon: Icons.hub_outlined,
          label: AppCopy.newConnections(min(waiting, AiSettings.batchSize)),
          onTap: () => context.push(Routes.review),
        ),
      if (revisit)
        HomeSuggestionCard(
          icon: Icons.history,
          label: AppCopy.revisit,
          onTap: () => context.push(Routes.revisit),
        ),
    ];
    if (cards.isEmpty) return const SizedBox.shrink();
    return HomeSuggestionRow(cards: cards);
  }
}
