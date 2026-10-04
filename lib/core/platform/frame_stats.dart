import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Frame timings for performance measurements (CLAUDE.md §8). Profile
/// builds only: collects build and raster times and logs a summary when
/// the app goes to the background. Stays on the device (`adb logcat`).
abstract final class FrameStats {
  static final _build = <int>[];
  static final _raster = <int>[];

  static void start() {
    if (!kProfileMode) return;
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        _build.add(t.buildDuration.inMicroseconds);
        _raster.add(t.rasterDuration.inMicroseconds);
      }
    });
  }

  /// Logs and clears what was collected since the last report.
  static void report() {
    if (!kProfileMode || _build.isEmpty) return;
    String ms(int us) => (us / 1000).toStringAsFixed(1);
    int at(List<int> sorted, double q) =>
        sorted[((sorted.length - 1) * q).round()];
    final b = [..._build]..sort();
    final r = [..._raster]..sort();
    var over8 = 0;
    var over16 = 0;
    for (var i = 0; i < _build.length; i++) {
      final worst = _build[i] > _raster[i] ? _build[i] : _raster[i];
      if (worst > 8333) over8++;
      if (worst > 16667) over16++;
    }
    debugPrint(
      'VeraN frames: n=${b.length} over8ms=$over8 over16ms=$over16 '
      'build p50=${ms(at(b, .5))} p90=${ms(at(b, .9))} max=${ms(b.last)} '
      'raster p50=${ms(at(r, .5))} p90=${ms(at(r, .9))} max=${ms(r.last)}',
    );
    _build.clear();
    _raster.clear();
  }
}
