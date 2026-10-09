import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/ai/embedder/model_files.dart';
import 'core/ai/scheduler/analysis_scheduler.dart';
import 'core/ai/suggestions/laptop_results_import.dart';
import 'core/platform/frame_stats.dart';
import 'core/settings/app_prefs_controller.dart';
import 'core/storage/storage_providers.dart';
import 'core/storage/storage_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FrameStats.start();
  ModelFiles.registerLicense();
  final storage = await StorageServices.open();
  // The laptop's results, offered as suggestions (docs/LAPTOP_PLAN.md, L3).
  storage.afterOutsideChanges = LaptopResultsImport(
    booster: storage.booster,
    suggestions: storage.suggestions,
    analysis: storage.analysis,
    rejections: storage.rejections,
  ).run;
  final prefs = await storage.settings.prefs();
  final onboard = !await storage.settings.onboardingDone();
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
  unawaited(storage.reconcile().then((_) => storage.cleanUp()));
  unawaited(AnalysisScheduler.init());
}
