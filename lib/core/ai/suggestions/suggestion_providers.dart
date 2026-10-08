import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/linked_note.dart';
import '../../models/suggested_link.dart';
import '../../models/suggestion.dart';
import '../../settings/app_prefs_controller.dart';
import '../../storage/storage_providers.dart';
import 'suggestion_actions.dart';
import 'suggestion_views.dart';

final suggestionActionsProvider = Provider<SuggestionActions>((ref) {
  final storage = ref.watch(storageProvider);
  return SuggestionActions(
    notes: storage.notes,
    links: ref.watch(linksRepositoryProvider),
    suggestions: storage.suggestions,
    rejections: storage.rejections,
    settings: storage.settings,
  );
});

final suggestionViewsProvider = Provider<SuggestionViews>((ref) {
  final storage = ref.watch(storageProvider);
  return SuggestionViews(storage.notes, storage.analysis);
});

/// How many suggestions are waiting, for Home's connections card.
final pendingSuggestionsProvider = StreamProvider.autoDispose<int>((ref) {
  if (!ref.watch(suggestionsOnProvider)) return Stream.value(0);
  return ref.watch(storageProvider).suggestions.watchCount();
});

/// Link suggestions waiting for one note, with the other note's title,
/// for the dimmed chips in its note view.
final suggestedLinksProvider = StreamProvider.autoDispose
    .family<List<SuggestedLink>, int>((ref, note) {
      if (!ref.watch(suggestionsOnProvider)) return Stream.value(const []);
      final storage = ref.watch(storageProvider);
      return storage.suggestions.watchFor(note).asyncMap((list) async {
        final links = <SuggestedLink>[];
        for (final s in list.where((s) => !s.isTag)) {
          final other = await storage.notes.getNote(s.otherThan(note));
          if (other == null) continue;
          links.add(
            SuggestedLink(s, LinkedNote(ref: other.ref, title: other.title)),
          );
        }
        return links;
      });
    });

/// Tag suggestions waiting for one note, for the dimmed chips in its Tags
/// row (UI spec §7).
final suggestedTagsProvider = StreamProvider.autoDispose
    .family<List<Suggestion>, int>((ref, note) {
      if (!ref.watch(suggestionsOnProvider)) return Stream.value(const []);
      return ref
          .watch(storageProvider)
          .suggestions
          .watchFor(note)
          .map(
            (list) => [
              for (final s in list)
                if (s.isTag && s.noteA == note) s,
            ],
          );
    });
