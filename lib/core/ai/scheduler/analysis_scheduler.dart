import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../storage/storage_services.dart';
import '../ai_settings.dart';
import 'analysis_job.dart';

/// Schedules on-device analysis with Android's WorkManager, only while the
/// phone is charging or idle (CLAUDE.md §8): no polling, no wake locks.
/// With "Analyze only when charging" off, a second request allows idle
/// runs too (WorkManager's constraints all have to hold at once, so it
/// takes two); whichever runs first does the work, the other finds none.
abstract final class AnalysisScheduler {
  static const _task = 'vera_n.analysis';
  static const _idle = 'analysis-idle';
  static bool _ready = false;

  static Future<void> init() async {
    if (defaultTargetPlatform != TargetPlatform.android || kIsWeb) return;
    try {
      await Workmanager().initialize(analysisDispatcher);
      _ready = true;
    } on Object catch (e) {
      debugPrint('VeraN analysis: init failed: $e');
    }
  }

  /// Asks for a run soon after the user leaves the app. Repeated requests
  /// before it runs are merged.
  /// A failure is written to the device log only (never sent anywhere):
  /// notes work without analysis, so it must never disturb the app.
  static Future<void> request({required bool chargingOnly}) async {
    if (!_ready) {
      debugPrint('VeraN analysis: scheduler not ready');
      return;
    }
    try {
      await _enqueue('analysis-charging', Constraints(requiresCharging: true));
      if (chargingOnly) {
        await Workmanager().cancelByUniqueName(_idle);
      } else {
        await _enqueue(
          _idle,
          Constraints(requiresDeviceIdle: true, requiresBatteryNotLow: true),
        );
      }
      debugPrint('VeraN analysis: requested');
    } on Object catch (e) {
      debugPrint('VeraN analysis: request failed: $e');
    }
  }

  /// "Suggest connections" turned off: nothing more runs.
  static Future<void> cancel() async {
    if (!_ready) return;
    try {
      await Workmanager().cancelAll();
    } on Object catch (e) {
      debugPrint('VeraN analysis: cancel failed: $e');
    }
  }

  static Future<void> _enqueue(String name, Constraints constraints) {
    return Workmanager().registerOneOffTask(
      name,
      _task,
      constraints: constraints,
      initialDelay: AiSettings.startDelay,
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}

/// Entry point WorkManager starts in the background.
@pragma('vm:entry-point')
void analysisDispatcher() {
  var stop = false;
  Workmanager().executeTask(
    (task, _) async {
      final storage = StorageServices.openForAnalysis();
      try {
        final done = await runAnalysisOnce(storage, stopRequested: () => stop);
        // Large libraries: carry on in a later run while charging.
        if (!done && !stop) await _continueLater();
        debugPrint('VeraN analysis: run finished, all done: $done');
        return true;
      } on Object catch (e) {
        debugPrint('VeraN analysis: run failed: $e');
        return false;
      } finally {
        await storage.close();
      }
    },
    onTaskStopped: (_, _) async {
      stop = true;
    },
  );
}

Future<void> _continueLater() {
  return Workmanager().registerOneOffTask(
    'analysis-more',
    AnalysisScheduler._task,
    constraints: Constraints(requiresCharging: true),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}
