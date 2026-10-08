import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/ai/embedder/model_files.dart';
import 'core/ai/scheduler/analysis_scheduler.dart';
import 'core/platform/frame_stats.dart';
import 'core/settings/app_prefs_controller.dart';
import 'core/storage/storage_providers.dart';
import 'core/storage/storage_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FrameStats.start();
  ModelFiles.registerLicense();
  final storage = await StorageServices.open();
  final prefs = await storage.settings.prefs();
  final onboard =
      storage.canChooseFolder && !await storage.settings.onboardingDone();
  runApp(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(storage),
        initialPrefsProvider.overrideWithValue(prefs),
      ],
      child: App(startWithOnboarding: onboard),
    ),
  );
  // Pick up notes added or changed outside the app, without delaying start.
  unawaited(storage.reconcile());
  unawaited(AnalysisScheduler.init());
}
