import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/copy/app_copy.dart';
import '../core/storage/storage_providers.dart';
import '../core/styles/app_styles.dart';
import 'router.dart';

/// Root widget. Follows the system theme until the Theme setting exists.
///
/// Going to the background writes unsaved text to files; coming back picks
/// up changes made outside the app.
class App extends ConsumerStatefulWidget {
  const App({super.key, this.startWithOnboarding = false});

  /// First launch: ask where notes should live before Home.
  final bool startWithOnboarding;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final GoRouter _router = buildRouter(
    startWithOnboarding: widget.startWithOnboarding,
  );
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageProvider);
    _lifecycle = AppLifecycleListener(
      onPause: storage.onPause,
      onResume: storage.onResume,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppCopy.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
