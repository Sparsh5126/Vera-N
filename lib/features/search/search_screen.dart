import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/models/search_filters.dart';
import '../../core/models/search_hit.dart';
import '../../core/navigation/routes.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/date_label.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/option_sheet.dart';
import '../../shared/widgets/section_label.dart';
import 'state/search_notes_controller.dart';
import 'widgets/recent_searches.dart';
import 'widgets/search_field.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/search_result_card.dart';

/// Search (UI spec §9). Keyword matches appear instantly as you type;
/// notes similar in meaning follow a moment later.
/// Results are always one column, and only the user's own notes.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _query = TextEditingController();

  SearchNotesController get _search => ref.read(searchNotesProvider.notifier);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _searchFor(String q) {
    _query.value = TextEditingValue(
      text: q,
      selection: TextSelection.collapsed(offset: q.length),
    );
    unawaited(_search.setQuery(q));
  }

  void _open(SearchHit hit) {
    unawaited(_search.remember(_query.text));
    context.push(Routes.note(hit.ref));
  }

  Future<void> _pickFolder(SearchFilters filters) async {
    final folders = await _search.folders();
    if (!mounted) return;
    final picked = await OptionSheet.show<String>(
      context,
      selected: filters.folder,
      emptyMessage: AppCopy.noFoldersYet,
      options: [
        const SheetOption(null, AppCopy.anyFolder),
        for (final f in folders) SheetOption(f, f),
      ],
    );
    if (picked != null) {
      await _search.setFilters(filters.withFolder(picked.value));
    }
  }

  Future<void> _pickTag(SearchFilters filters) async {
    final tags = await _search.tags();
    if (!mounted) return;
    final picked = await OptionSheet.show<String>(
      context,
      selected: filters.tag,
      emptyMessage: AppCopy.noTagsYet,
      options: [
        const SheetOption(null, AppCopy.anyTag),
        for (final t in tags) SheetOption(t, AppCopy.tagLabel(t)),
      ],
    );
    if (picked != null) {
      await _search.setFilters(filters.withTag(picked.value));
    }
  }

  Future<void> _pickDate(SearchFilters filters) async {
    final picked = await OptionSheet.show<DateFilter>(
      context,
      selected: filters.date,
      options: [
        const SheetOption(null, AppCopy.anyTime),
        for (final d in DateFilter.values)
          SheetOption(d, SearchFilterBar.dateLabel(d)),
      ],
    );
    if (picked != null) {
      await _search.setFilters(filters.withDate(picked.value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotesProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.m,
                AppSpace.m,
                AppSpace.m,
                AppSpace.s,
              ),
              child: SearchField(
                controller: _query,
                onChanged: (q) => unawaited(_search.setQuery(q)),
                onSubmitted: (q) => unawaited(_search.remember(q)),
                onClear: () => _searchFor(''),
              ),
            ),
            SearchFilterBar(
              filters: state.filters,
              onFolder: () => unawaited(_pickFolder(state.filters)),
              onTag: () => unawaited(_pickTag(state.filters)),
              onDate: () => unawaited(_pickDate(state.filters)),
            ),
            const SizedBox(height: AppSpace.s),
            Expanded(child: _body(state)),
          ],
        ),
      ),
    );
  }

  Widget _body(SearchState state) {
    final hits = state.hits;
    if (!state.isSearching) {
      if (state.recent.isEmpty) return const SizedBox.shrink();
      return RecentSearches(
        queries: state.recent,
        onSelected: _searchFor,
        onRemove: (q) => unawaited(_search.forget(q)),
      );
    }
    // Results are a moment away (local): keep the space quiet, no spinner.
    if (hits == null) return const SizedBox.shrink();
    final similar = state.similar;
    if (hits.isEmpty && similar.isEmpty) {
      return const EmptyState(message: AppCopy.emptySearch);
    }
    final now = DateTime.now();
    // Matches first; "Similar in meaning" fills in a moment later.
    final rows = <Object>[
      if (hits.isNotEmpty) AppCopy.matches,
      ...hits,
      if (similar.isNotEmpty) AppCopy.similarInMeaning,
      ...similar,
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.m,
        AppSpace.s,
        AppSpace.m,
        AppSize.navBarClearance,
      ),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s),
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is String) return SectionLabel(row);
        final hit = row as SearchHit;
        return SearchResultCard(
          hit: hit,
          dateLabel: DateLabel.of(hit.modified, now),
          onTap: () => _open(hit),
        );
      },
    );
  }
}
