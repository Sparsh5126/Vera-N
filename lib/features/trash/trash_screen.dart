import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/copy/app_copy.dart';
import '../../core/models/trashed_note.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/date_label.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/undo_snack_bar.dart';
import 'widgets/trash_card.dart';

final _trashProvider = StreamProvider.autoDispose<List<TrashedNote>>(
  (ref) => ref.watch(storageProvider).trash.watch(),
);

/// Trash (UI spec §11): deleted notes, kept 30 days. Restore puts a note
/// back where it was; Delete forever removes it once its Undo has gone
/// (the file can't be brought back after that). Both offer Undo.
class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  /// Notes being deleted for good, hidden while their Undo is offered.
  final _leaving = <int>{};

  void _restore(TrashedNote note) {
    final notes = ref.read(notesRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    notes.restore(note.ref).then((_) {
      UndoSnackBar.show(
        messenger,
        message: AppCopy.restored,
        onUndo: () => notes.trash(note.ref),
      );
    });
  }

  void _delete(TrashedNote note) {
    final trash = ref.read(storageProvider).trash;
    setState(() => _leaving.add(note.ref));
    UndoSnackBar.show(
      ScaffoldMessenger.of(context),
      message: AppCopy.deletedForever,
      onUndo: () {
        if (mounted) setState(() => _leaving.remove(note.ref));
      },
      onExpired: () => trash.deleteForever(note.ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(_trashProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.trash)),
      body: notes.when(
        // Local data arrives at once: no spinner.
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const EmptyState(message: AppCopy.loadError),
        data: (all) {
          final shown = [
            for (final n in all)
              if (!_leaving.contains(n.ref)) n,
          ];
          if (shown.isEmpty) {
            return const EmptyState(message: AppCopy.emptyTrash);
          }
          return _list(shown);
        },
      ),
    );
  }

  Widget _list(List<TrashedNote> notes) {
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.m),
      itemCount: notes.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(AppCopy.trashHint, style: context.textStyles.small);
        }
        final note = notes[i - 1];
        return TrashCard(
          note: note,
          dateLabel: DateLabel.of(note.trashedAt, now),
          onRestore: () => _restore(note),
          onDelete: () => _delete(note),
        );
      },
    );
  }
}
