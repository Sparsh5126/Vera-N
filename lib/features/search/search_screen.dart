import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/models/search_hit.dart';
import '../../core/navigation/routes.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/date_label.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/section_label.dart';
import 'state/search_notes_controller.dart';
import 'widgets/recent_searches.dart';
import 'widgets/search_field.dart';
import 'widgets/search_result_card.dart';

/// Search (UI spec §9). Keyword matches appear instantly as you type.
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
            Expanded(child: _body(state)),
          ],
        ),
      ),
    );
  }

  Widget _body(SearchState state) {
    final hits = state.hits;
    if (!state.hasQuery || hits == null) {
      if (state.recent.isEmpty) return const SizedBox.shrink();
      return RecentSearches(
        queries: state.recent,
        onSelected: _searchFor,
        onRemove: (q) => unawaited(_search.forget(q)),
      );
    }
    if (hits.isEmpty) return const EmptyState(message: AppCopy.emptySearch);
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.m,
        AppSpace.s,
        AppSpace.m,
        AppSize.navBarClearance,
      ),
      itemCount: hits.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s),
      itemBuilder: (context, i) {
        if (i == 0) return const SectionLabel(AppCopy.matches);
        final hit = hits[i - 1];
        return SearchResultCard(
          hit: hit,
          dateLabel: DateLabel.of(hit.modified, now),
          onTap: () => _open(hit),
        );
      },
    );
  }
}
