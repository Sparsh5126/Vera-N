import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/suggestions/suggestion_providers.dart';
import '../../core/copy/app_copy.dart';
import '../../core/models/revisit_item.dart';
import '../../core/navigation/routes.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/date_label.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/undo_snack_bar.dart';
import 'widgets/revisit_card.dart';

/// Revisit (product spec §10, UI spec §5): old notes that became relevant
/// again because of something written recently. Silent and optional: the
/// user opens it by choice. Opening a note counts as revisited; "Not now"
/// hides it for a month, with Undo.
class RevisitScreen extends ConsumerWidget {
  const RevisitScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, RevisitItem item) {
    unawaited(ref.read(suggestionActionsProvider).revisited(item.suggestion));
    unawaited(context.push(Routes.note(item.ref)));
  }

  Future<void> _notNow(
    BuildContext context,
    WidgetRef ref,
    RevisitItem item,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final undo = await ref
        .read(suggestionActionsProvider)
        .putOff(item.suggestion);
    UndoSnackBar.show(
      messenger,
      message: AppCopy.putOff,
      onUndo: () => unawaited(undo()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(revisitProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.revisit)),
      body: items.when(
        // Local data arrives at once: no spinner.
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const EmptyState(message: AppCopy.loadError),
        data: (list) => list.isEmpty
            ? const EmptyState(message: AppCopy.nothingToRevisit)
            : _list(context, ref, list),
      ),
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, List<RevisitItem> list) {
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.m),
      itemCount: list.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(AppCopy.revisitBody, style: context.textStyles.body);
        }
        final item = list[i - 1];
        return RevisitCard(
          item: item,
          dateLabel: DateLabel.of(item.modified, now),
          onOpen: () => _open(context, ref, item),
          onNotNow: () => unawaited(_notNow(context, ref, item)),
        );
      },
    );
  }
}
