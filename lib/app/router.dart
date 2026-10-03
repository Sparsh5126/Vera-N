import 'package:go_router/go_router.dart';

import '../core/navigation/routes.dart';
import '../features/home/home_screen.dart';
import '../features/note/note_screen.dart';
import '../features/onboarding/onboarding_folder_screen.dart';

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
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
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
