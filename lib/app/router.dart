import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/feedback/motion.dart';
import '../core/navigation/routes.dart';
import '../core/styles/app_styles.dart';
import '../core/utils/shared_text.dart';
import '../features/graph/graph_screen.dart';
import '../features/note/note_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/review/review_screen.dart';
import '../features/revisit/revisit_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/trash/trash_screen.dart';
import 'app_shell.dart';
import 'home_tab.dart';

/// The route table. URL-style paths so widgets, the Quick Settings tile
/// and app shortcuts can deep-link later (e.g. straight to a new note).
/// [startWithNewNote] is the "Open app to: New note" setting; back from
/// that note goes Home.
GoRouter buildRouter({
  bool startWithOnboarding = false,
  bool startWithNewNote = false,
}) {
  return GoRouter(
    initialLocation: startWithOnboarding
        ? Routes.welcome
        : startWithNewNote
        ? Routes.newNote
        : Routes.home,
    routes: [
      GoRoute(
        path: Routes.welcome,
        builder: (_, _) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (_, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          _tab(Routes.home, const HomeTab()),
          _tab(Routes.search, const SearchScreen()),
          _tab(Routes.graph, const GraphScreen()),
          _tab(Routes.settings, const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: Routes.newNote,
        // Text or a link shared from another app arrives as query values.
        builder: (_, state) => NoteScreen(
          key: state.pageKey,
          sharedText: SharedText.toNoteBody(
            text: state.uri.queryParameters[Routes.sharedTextParam],
            subject: state.uri.queryParameters[Routes.sharedSubjectParam],
          ),
        ),
      ),
      GoRoute(path: Routes.review, builder: (_, _) => const ReviewScreen()),
      GoRoute(path: Routes.trash, builder: (_, _) => const TrashScreen()),
      GoRoute(path: Routes.revisit, builder: (_, _) => const RevisitScreen()),
      GoRoute(
        path: Routes.notePattern,
        builder: (_, state) => NoteScreen(
          noteRef: int.tryParse(state.pathParameters[Routes.noteParam] ?? ''),
        ),
      ),
    ],
  );
}

/// Tabs switch in place with a short fade (none when the system asks
/// for less motion).
GoRoute _tab(String path, Widget screen) => GoRoute(
  path: path,
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: screen,
    transitionDuration: Motion.of(context),
    reverseTransitionDuration: Motion.of(context),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: AppMotion.standardCurve,
      ),
      child: child,
    ),
  ),
);
