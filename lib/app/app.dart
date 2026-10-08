import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/ai/scheduler/analysis_scheduler.dart';
import '../core/ai/suggestions/suggestion_providers.dart';
import '../core/copy/app_copy.dart';
import '../core/models/app_prefs.dart';
import '../core/platform/frame_stats.dart';
import '../core/platform/launch_channel.dart';
import '../core/settings/app_prefs_controller.dart';
import '../core/storage/storage_providers.dart';
import '../core/styles/app_styles.dart';
import 'app_shell.dart';
import 'router.dart';

/// Root widget. Theme and start page come from Settings.
///
/// Going to the background writes unsaved text to files; coming back picks
/// up changes made outside the app. Leaving also asks for analysis, which
/// runs later, only while charging (or idle, if allowed in Settings), and
/// only while suggestions are on.
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
    startWithNewNote: ref.read(appPrefsProvider).startPage == StartPage.newNote,
  );
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageProvider);
    _lifecycle = AppLifecycleListener(
      onPause: () {
        FrameStats.report();
        storage.onPause();
        final prefs = ref.read(appPrefsProvider);
        if (prefs.suggestions) {
          unawaited(
            AnalysisScheduler.request(chargingOnly: prefs.chargingOnly),
          );
        }
      },
      onResume: storage.onResume,
    );
    LaunchChannel.listen(onOpen: _open, onWindowFocused: _showKeyboardIfTyping);
  }

  /// On a cold start into a new note the editor is focused before Android
  /// lets the app show the keyboard. Once the window has focus, ask again.
  void _showKeyboardIfTyping() {
    final editor = FocusManager.instance.primaryFocus?.context
        ?.findAncestorStateOfType<EditableTextState>();
    editor?.requestKeyboard();
  }

  /// An entry point while running: tabs are switched to, other screens
  /// (a new note, Review) open on top.
  void _open(String route) {
    if (AppShell.tabs.contains(route)) {
      _router.go(route);
    } else {
      unawaited(_router.push(route));
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // "Review connections" on the app icon only while suggestions wait.
    ref.listen(pendingSuggestionsProvider, (_, next) {
      final waiting = (next.value ?? 0) > 0;
      unawaited(LaunchChannel.setReviewShortcut(waiting: waiting));
    });
    return MaterialApp.router(
      title: AppCopy.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (ref.watch(appPrefsProvider.select((p) => p.theme))) {
        ThemeChoice.system => ThemeMode.system,
        ThemeChoice.dark => ThemeMode.dark,
        ThemeChoice.light => ThemeMode.light,
      },
      routerConfig: _router,
    );
  }
}
