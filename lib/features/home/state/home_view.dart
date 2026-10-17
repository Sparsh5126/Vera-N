import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/folder_summary.dart';
import '../../../core/models/note_summary.dart';
import '../../../core/models/search_filters.dart';
import '../../../core/storage/storage_providers.dart';

/// Home's view switch (UI spec §5).
enum HomeView { recent, folders, tags }

@immutable
class HomeViewState {
  const HomeViewState({this.view = HomeView.recent, this.folder, this.tag});

  final HomeView view;

  /// The folder or tag picked in those views; null shows only the pills.
  final String? folder;
  final String? tag;
}

/// Which view Home shows and what is picked in it. Kept while the app
/// runs, so coming back to Home keeps the user's place.
class HomeViewController extends Notifier<HomeViewState> {
  @override
  HomeViewState build() => const HomeViewState();

  void show(HomeView view) =>
      state = HomeViewState(view: view, folder: state.folder, tag: state.tag);

  /// Picks [folder]; picking it again clears the choice.
  void pickFolder(String folder) => state = HomeViewState(
    view: state.view,
    folder: state.folder == folder ? null : folder,
    tag: state.tag,
  );

  /// Shows [folder] opened in the Folders view: a drag resting on its chip.
  void openFolder(String folder) => state = HomeViewState(
    view: HomeView.folders,
    folder: folder,
    tag: state.tag,
  );

  /// Back to the folder cards from an opened folder.
  void closeFolder() => state = HomeViewState(view: state.view, tag: state.tag);

  /// Picks [tag]; picking it again clears the choice.
  void pickTag(String tag) => state = HomeViewState(
    view: state.view,
    folder: state.folder,
    tag: state.tag == tag ? null : tag,
  );
}

final homeViewProvider = NotifierProvider<HomeViewController, HomeViewState>(
  HomeViewController.new,
);

/// The folder cards: every folder with how many notes it holds.
final homeFolderSummariesProvider =
    StreamProvider.autoDispose<List<FolderSummary>>(
      (ref) => ref.watch(searchRepositoryProvider).watchFolderSummaries(),
    );

final hasLockedNotesProvider = StreamProvider.autoDispose<bool>(
  (ref) => ref.watch(notesRepositoryProvider).watchHasLocked(),
);

final homeTagsProvider = StreamProvider.autoDispose<List<String>>(
  (ref) => ref.watch(searchRepositoryProvider).watchTags(),
);

/// Notes in one folder (with its subfolders) or with one tag.
final groupNotesProvider = StreamProvider.autoDispose
    .family<List<NoteSummary>, SearchFilters>(
      (ref, filters) =>
          ref.watch(notesRepositoryProvider).watchNotes(filters: filters),
    );
