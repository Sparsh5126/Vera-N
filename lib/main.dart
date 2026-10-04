import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/platform/frame_stats.dart';
import 'core/storage/storage_providers.dart';
import 'core/storage/storage_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FrameStats.start();
  final storage = await StorageServices.open();
  final onboard =
      storage.canChooseFolder && !await storage.settings.onboardingDone();
  runApp(
    ProviderScope(
      overrides: [storageProvider.overrideWithValue(storage)],
      child: App(startWithOnboarding: onboard),
    ),
  );
  // Pick up notes added or changed outside the app, without delaying start.
  unawaited(storage.reconcile());
}
