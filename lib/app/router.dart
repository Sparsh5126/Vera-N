import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/routes.dart';
import '../features/home/home_screen.dart';
import '../features/note/note_screen.dart';
import '../features/onboarding/onboarding_folder_screen.dart';
import '../features/search/search_screen.dart';
import 'app_shell.dart';

/// The route table. URL-style paths so widgets, the Quick Settings tile
/// and app shortcuts can deep-link later (e.g. straight to a new note).
GoRouter buildRouter({bool startWithOnboarding = false}) {
  return GoRouter(
    initialLocation: startWithOnboarding
        ? Routes.onboardingFolder
        : Routes.home,
    routes: [
      GoRoute(
        path: Routes.onboardingFolder,
        builder: (_, _) => const OnboardingFolderScreen(),
      ),
      ShellRoute(
        builder: (_, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          _tab(Routes.home, const HomeScreen()),
          _tab(Routes.search, const SearchScreen()),
        ],
      ),
      GoRoute(path: Routes.newNote, builder: (_, _) => const NoteScreen()),
      GoRoute(
        path: Routes.notePattern,
        builder: (_, state) => NoteScreen(
          noteRef: int.tryParse(state.pathParameters[Routes.noteParam] ?? ''),
        ),
      ),
    ],
  );
}

/// Tabs switch in place, without a page transition.
GoRoute _tab(String path, Widget screen) => GoRoute(
  path: path,
  pageBuilder: (_, state) =>
      NoTransitionPage(key: state.pageKey, child: screen),
);
