import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/ai_settings.dart';
import '../../../core/ai/suggestions/suggestion_providers.dart';
import '../../../core/copy/app_copy.dart';
import '../../../core/navigation/routes.dart';
import '../../../core/styles/app_styles.dart';

/// Home's "5 new connections" card (UI spec §5): opens Review. It counts
/// at most one batch, so it never becomes a growing number to clear.
/// Hidden when nothing is waiting. (Revisit joins this row later; until
/// then this card takes the full width.)
class ConnectionsCard extends ConsumerWidget {
  const ConnectionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waiting = ref.watch(pendingSuggestionsProvider).value ?? 0;
    if (waiting == 0) return const SizedBox.shrink();
    final styles = context.textStyles;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpace.m,
        right: AppSpace.m,
        bottom: AppSpace.m,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.review),
          child: Padding(
            padding: AppSpace.card,
            child: Row(
              children: [
                Icon(Icons.hub_outlined, color: context.colors.seal),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Text(
                    AppCopy.newConnections(min(waiting, AiSettings.batchSize)),
                    style: styles.cardTitle,
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
