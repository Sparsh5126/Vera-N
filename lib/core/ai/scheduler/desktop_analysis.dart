import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

import '../../storage/storage_services.dart';
import 'analysis_job.dart';

/// Analysis on a laptop (docs/LAPTOP_PLAN.md, L0). There is no scheduled
/// background work there, so it runs inside the open app: only on mains
/// power, only after the user has left the keyboard and mouse alone for
/// [idleFor], and it stops at their next key press or click. Closing the
/// app ends it; nothing keeps running (CLAUDE.md §8).
class DesktopAnalysis {
  DesktopAnalysis(
    this._storage, {
    required this.enabled,
    Future<bool> Function()? onPower,
    Future<bool> Function(AnalysisStorage, bool Function())? run,
    this.boost,
  }) : _onPower = onPower ?? _mainsPower,
       _run =
           run ??
           ((storage, stop) => runAnalysisOnce(storage, stopRequested: stop));

  static const idleFor = Duration(minutes: 3);

  final AnalysisStorage _storage;

  /// Whether suggestions are on in Settings.
  final bool Function() enabled;
  final Future<bool> Function() _onPower;
  final Future<bool> Function(AnalysisStorage, bool Function()) _run;

  /// The laptop booster (docs/LAPTOP_PLAN.md, L2), run once analysis is
  /// done; returns true when it has nothing left.
  final Future<bool> Function(bool Function() stop)? boost;
  Timer? _idle;
  bool _running = false;
  bool _stop = false;

  /// The user typed, clicked or scrolled: stop any run, wait to be idle.
  void activity() {
    _stop = true;
    _idle?.cancel();
    _idle = Timer(idleFor, () => unawaited(_runWhileIdle()));
  }

  Future<void> _runWhileIdle() async {
    if (_running || !enabled() || !await _onPower()) return;
    _running = true;
    _stop = false;
    try {
      var done = false;
      // A big library takes several runs; carry on while still idle.
      while (!done && !_stop) {
        done = await _run(_storage, () => _stop);
      }
      debugPrint('VeraN analysis (laptop): finished, all done: $done');
      final boost = this.boost;
      var boosted = boost == null;
      while (done && !boosted && !_stop) {
        boosted = await boost!(() => _stop);
      }
    } on Object catch (e) {
      debugPrint('VeraN analysis (laptop): failed: $e');
    } finally {
      _running = false;
    }
  }

  void dispose() {
    _stop = true;
    _idle?.cancel();
  }

  /// On mains power: charging, full, or plugged in. A computer without a
  /// battery reports "unknown", which counts as mains.
  static Future<bool> _mainsPower() async {
    try {
      final state = await Battery().batteryState;
      return state != BatteryState.discharging;
    } on Object {
      return true;
    }
  }
}
