import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/ai/scheduler/analysis_scheduler.dart';
import '../core/ai/scheduler/desktop_analysis.dart';
import '../core/booster/laptop_booster.dart';
import '../core/ai/suggestions/suggestion_providers.dart';
import '../core/copy/app_copy.dart';
import '../core/models/app_prefs.dart';
import '../core/platform/frame_stats.dart';
import '../core/navigation/routes.dart';
import '../core/platform/device_kind.dart';
import '../core/platform/launch_channel.dart';
import '../core/platform/reminder_notifications.dart';
import '../core/reminders/reminder_providers.dart';
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
      onResume: () {
        storage.onResume();
        // Notifications may have been allowed meanwhile (prompt, settings).
        ref.read(notificationsRecheckProvider.notifier).recheck();
      },
    );
    LaunchChannel.listen(onOpen: _open, onWindowFocused: _showKeyboardIfTyping);
    // Reminders are a phone-only feature (docs/LAPTOP_PLAN.md).
    if (DeviceKind.isPhone) unawaited(_startReminders());
    if (DeviceKind.isDesktop) _startDesktop();
  }

  DesktopAnalysis? _analysis;

  /// On a laptop: follow the notes folder while open, and analyse while
  /// the user is away from the keyboard (and on mains power).
  void _startDesktop() {
    final storage = ref.read(storageProvider);
    unawaited(storage.watchFolder());
    final analysis = DesktopAnalysis(
      storage.forAnalysis,
      enabled: () => ref.read(appPrefsProvider).suggestions,
      boost: LaptopBooster(
        booster: storage.booster,
        analysis: storage.analysis,
        suggestions: storage.suggestions,
        settings: storage.settings,
      ).runOnce,
    );
    _analysis = analysis;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    HardwareKeyboard.instance.addHandler(_onKey);
    analysis.activity();
  }

  void _onPointer(PointerEvent _) => _analysis?.activity();

  bool _onKey(KeyEvent _) {
    _analysis?.activity();
    return false;
  }

  /// Reminders a note asked for: tapping one opens its note. The notes are
  /// followed while "Reminders from notes" is on (see build).
  Future<void> _startReminders() async {
    await ref
        .read(reminderNotificationsProvider)
        .init((note) => unawaited(_router.push(Routes.note(note))));
    if (mounted && ref.read(appPrefsProvider).reminders) {
      ref.read(reminderSyncProvider).start();
    }
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
    if (_analysis != null) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
      HardwareKeyboard.instance.removeHandler(_onKey);
      _analysis?.dispose();
    }
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
    ref.listen(appPrefsProvider.select((p) => p.reminders), (_, on) {
      if (!DeviceKind.isPhone) return;
      final sync = ref.read(reminderSyncProvider);
      on ? sync.start() : unawaited(sync.stop());
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
