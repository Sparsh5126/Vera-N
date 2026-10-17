import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/suggestions/suggestion_providers.dart';
import '../../core/copy/app_copy.dart';
import '../../core/feedback/haptics.dart';
import '../../core/navigation/routes.dart';
import '../../core/settings/app_prefs_controller.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/date_label.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/option_sheet.dart';
import '../../shared/widgets/suggestion_flow.dart';
import '../../shared/widgets/text_entry_sheet.dart';
import 'state/graph_controller.dart';
import 'state/graph_view.dart';
import 'widgets/graph_bubble_view.dart';
import 'widgets/graph_canvas.dart';
import 'widgets/graph_controls.dart';
import 'widgets/graph_preview_card.dart';

/// Graph (UI spec §10): notes as dots, confirmed links as solid lines,
/// suggestions as dimmed dashed lines when asked for. No stats, nothing
/// to maintain.
class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  GraphView get _controls => ref.read(graphViewProvider.notifier);

  late final _suggestions = SuggestionFlow(
    load: ref.read(suggestionViewsProvider).load,
    accept: ref.read(suggestionActionsProvider).accept,
    reject: ref.read(suggestionActionsProvider).reject,
    notSure: ref.read(suggestionActionsProvider).notSure,
    dateLabel: (d) => DateLabel.of(d, DateTime.now()),
    onOpenNote: _open,
    aboveNavBar: true,
  );

  void _open(int ref) => context.push(Routes.note(ref));

  Future<void> _pickFolder(GraphViewState view) async {
    final folders = await ref.read(searchRepositoryProvider).folders();
    if (!mounted) return;
    final picked = await OptionSheet.show<String>(
      context,
      selected: view.filters.folder,
      emptyMessage: AppCopy.noFoldersYet,
      options: [
        const SheetOption(null, AppCopy.anyFolder),
        for (final f in folders) SheetOption(f, f),
      ],
    );
    if (picked != null) {
      _controls.setFilters(view.filters.withFolder(picked.value));
    }
  }

  Future<void> _pickTag(GraphViewState view) async {
    final tags = await ref.read(searchRepositoryProvider).tags();
    if (!mounted) return;
    final picked = await OptionSheet.show<String>(
      context,
      selected: view.filters.tag,
      emptyMessage: AppCopy.noTagsYet,
      options: [
        const SheetOption(null, AppCopy.anyTag),
        for (final t in tags) SheetOption(t, AppCopy.tagLabel(t)),
      ],
    );
    if (picked != null) {
      _controls.setFilters(view.filters.withTag(picked.value));
    }
  }

  /// The search jump: type to find a note, then centre on it.
  Future<void> _find(GraphPicture? picture) async {
    if (picture == null) return;
    final titles = {for (final n in picture.all.values) n.title: n.ref};
    final typed = await TextEntrySheet.show(
      context,
      hint: AppCopy.findNote,
      suggestions: titles.keys.toList()..sort(),
    );
    final lower = typed?.toLowerCase();
    if (lower == null) return;
    final match = titles.entries
        .where((e) => e.key.toLowerCase().contains(lower))
        .firstOrNull;
    if (match == null) return;
    // Folder bubbles: open the note's folder first, then find it there.
    if (picture.bubbles != null) {
      final folder = picture.all[match.value]!.topFolder;
      final filters = ref.read(graphViewProvider).filters;
      _controls.setFilters(filters.withFolder(folder));
    }
    _controls.jumpTo(
      match.value,
      hidden: !picture.nodes.containsKey(match.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(graphViewProvider);
    final picture = ref.watch(graphPictureProvider);
    final current = picture.value;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpace.m),
            GraphControls(
              view: view,
              focusTitle: current?.all[view.focus]?.title,
              offerSuggestions: ref.watch(suggestionsOnProvider),
              onFolder: () => unawaited(_pickFolder(view)),
              onTag: () => unawaited(_pickTag(view)),
              onFind: () => unawaited(_find(current)),
              controls: _controls,
            ),
            Expanded(
              child: picture.when(
                // Local work: keep the space quiet, no spinner.
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const EmptyState(message: AppCopy.loadError),
                data: (p) => p.isEmpty
                    ? const EmptyState(message: AppCopy.emptyGraph)
                    : _graph(p, view),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _graph(GraphPicture picture, GraphViewState view) {
    final bubbles = picture.bubbles;
    if (bubbles != null) {
      return GraphBubbleView(
        bubbles: bubbles,
        positions: picture.positions,
        onFolder: (f) => _controls.setFilters(view.filters.withFolder(f)),
      );
    }
    final node = picture.nodes[view.selected];
    return Stack(
      children: [
        Positioned.fill(
          child: GraphCanvas(
            picture: picture,
            selected: node?.ref,
            centerRequest: view.centerRequest,
            onSelect: (ref) {
              // A light tick for picking a dot (CLAUDE.md §7), not for
              // tapping away or tapping the same one again.
              if (ref != null && ref != view.selected) {
                unawaited(Haptics.play(HapticEvent.select));
              }
              _controls.select(ref);
            },
            onSuggestion: (s) => unawaited(_suggestions.open(context, s)),
          ),
        ),
        if (node != null)
          Positioned(
            left: AppSpace.m,
            right: AppSpace.m,
            bottom: AppSize.navBarClearance,
            child: GraphPreviewCard(
              node: node,
              onOpen: () => _open(node.ref),
              onFocus: () => _controls.focusOn(node.ref),
              onClose: () => _controls.select(null),
            ),
          ),
      ],
    );
  }
}
