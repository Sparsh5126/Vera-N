import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/suggestions/suggestion_providers.dart';
import '../../../core/models/note.dart';
import '../../../shared/widgets/suggestion_flow.dart';
import '../state/note_providers.dart';
import 'note_actions.dart';
import 'note_details.dart';

/// The note's details below its text, with their live data: folder, tags
/// and tag suggestions, links, backlinks and link suggestions.
class NoteDetailsSection extends ConsumerWidget {
  const NoteDetailsSection({
    super.key,
    required this.note,
    required this.actions,
    required this.suggestions,
    required this.onOpenNote,
  });

  final Note note;
  final NoteActions actions;
  final SuggestionFlow suggestions;
  final ValueChanged<int> onOpenNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggested =
        ref.watch(suggestedLinksProvider(note.ref)).value ?? const [];
    final tagSuggestions =
        ref.watch(suggestedTagsProvider(note.ref)).value ?? const [];
    return NoteDetails(
      folder: note.folder,
      onFolderTap: () => unawaited(actions.moveToFolder(context, note)),
      tags: note.tags,
      linked: ref.watch(linkedProvider(note.ref)).value ?? const [],
      mentionedIn: ref.watch(mentionedInProvider(note.ref)).value ?? const [],
      suggested: [for (final s in suggested) s.other],
      onSuggestedTap: (other) {
        final link = suggested.firstWhere((s) => s.other.ref == other);
        unawaited(
          suggestions.open(
            context,
            link.suggestion,
            otherTitle: link.other.title,
          ),
        );
      },
      suggestedTags: [for (final s in tagSuggestions) s.tag],
      onSuggestedTagTap: (tag) => unawaited(
        suggestions.open(
          context,
          tagSuggestions.firstWhere((s) => s.tag == tag),
        ),
      ),
      onAddTag: () => unawaited(actions.addTag(context, note)),
      onTagTap: (tag) => unawaited(actions.tagTapped(context, note, tag)),
      onOpenNote: onOpenNote,
    );
  }
}
