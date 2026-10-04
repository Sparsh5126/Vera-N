// Records the Dart/engine timeline of a running profile build and
// summarises where time goes, so performance work is guided by data.
//
// Usage: dart run bin/timeline.dart WS_URI SECONDS OUT.json
// WS_URI is the VM service address printed by `flutter run --profile`
// (http://… is accepted and turned into ws://…/ws).
import 'dart:convert';
import 'dart:io';

import 'package:vm_service/vm_service_io.dart';

class Slice {
  Slice(this.name, this.tid, this.start, this.dur);
  final String name;
  final int tid;
  final int start;
  final int dur;
  int get end => start + dur;
}

Future<void> main(List<String> args) async {
  var uri = args[0];
  if (uri.startsWith('http')) {
    uri = '${uri.replaceFirst('http', 'ws').replaceAll(RegExp(r'/$'), '')}/ws';
  }
  final seconds = int.parse(args[1]);
  final service = await vmServiceConnectUri(uri);
  await service.setVMTimelineFlags(['Dart', 'Embedder', 'GC', 'API']);
  await service.clearVMTimeline();
  stdout.writeln('RECORDING for $seconds s');
  await Future<void>.delayed(Duration(seconds: seconds));
  final timeline = await service.getVMTimeline();
  await service.dispose();

  final events = [for (final e in timeline.traceEvents!) e.json!];
  File(args[2]).writeAsStringSync(jsonEncode(events));
  summarise(events);
}

void summarise(List<Map<String, dynamic>> events) {
  final threadNames = <int, String>{};
  final slices = <Slice>[];
  final open = <int, List<Map<String, dynamic>>>{};
  for (final e in events) {
    final tid = (e['tid'] as num?)?.toInt() ?? 0;
    switch (e['ph']) {
      case 'M':
        if (e['name'] == 'thread_name') {
          threadNames[tid] = (e['args'] as Map)['name'] as String;
        }
      case 'X':
        slices.add(Slice(e['name'] as String, tid, (e['ts'] as num).toInt(),
            (e['dur'] as num? ?? 0).toInt()));
      case 'B':
        (open[tid] ??= []).add(e);
      case 'E':
        final stack = open[tid];
        if (stack == null || stack.isEmpty) break;
        final b = stack.removeLast();
        final start = (b['ts'] as num).toInt();
        slices.add(Slice(b['name'] as String, tid, start,
            (e['ts'] as num).toInt() - start));
    }
  }
  String thread(int tid) => threadNames[tid] ?? 'tid $tid';

  final byThread = <int, List<Slice>>{};
  for (final s in slices) {
    (byThread[s.tid] ??= []).add(s);
  }
  for (final entry in byThread.entries) {
    final list = entry.value..sort((a, b) => a.start.compareTo(b.start));
    final totals = <String, int>{};
    for (final s in list) {
      totals[s.name] = (totals[s.name] ?? 0) + s.dur;
    }
    final top = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (top.isEmpty || top.first.value < 20000) continue;
    stdout.writeln('\n=== ${thread(entry.key)} (${list.length} slices)');
    stdout.writeln('  total time by event:');
    for (final t in top.take(12)) {
      stdout.writeln('    ${(t.value / 1000).toStringAsFixed(1).padLeft(8)} ms  ${t.key}');
    }
    final longest = [...list]..sort((a, b) => b.dur.compareTo(a.dur));
    stdout.writeln('  slowest events (with what ran inside, > 1 ms):');
    for (final s in longest.take(8)) {
      final inside = list
          .where((c) => c != s && c.start >= s.start && c.end <= s.end && c.dur > 1000)
          .map((c) => '${c.name} ${(c.dur / 1000).toStringAsFixed(1)}')
          .take(8)
          .join(', ');
      stdout.writeln('    ${(s.dur / 1000).toStringAsFixed(1).padLeft(7)} ms  ${s.name}'
          '${inside.isEmpty ? '' : '  [$inside]'}');
    }
  }
}
