import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'embedder.dart';
import 'onnx_embedder.dart';
import 'quality_set.dart';
import 'tflite_embedder.dart';

/// Embedding model benchmark for Vera N (CLAUDE.md §8, product spec §20).
///
/// One model per launch, so memory numbers don't mix. The model to run is
/// read from `/sdcard/Download/vera_bench/run.txt`; results are logged as one
/// `BENCH {json}` line, then the app exits. See README.md.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('bench'))),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) => _run());
}

const _runs = 15;
const _warmup = 3;

Future<void> _run() async {
  // Shared folder written by adb (see README.md).
  const files = '/sdcard/Download/vera_bench';
  final key = (await File('$files/run.txt').readAsString()).trim();
  final models = '$files/models';
  final Embedder embedder = switch (key) {
    'e5-small' => OnnxEmbedder(
      name: 'multilingual-e5-small int8',
      dir: '$models/e5-small',
      prefix: 'query: ',
    ),
    'ml-minilm-l12' => OnnxEmbedder(
      name: 'paraphrase-multilingual-MiniLM-L12-v2 int8',
      dir: '$models/ml-minilm-l12',
    ),
    // Trimmed to English + Hindi by tool/model_trim (--words 300000).
    'ml-minilm-l12-trim' => OnnxEmbedder(
      name: 'paraphrase-multilingual-MiniLM-L12-v2 int8, trimmed en+hi',
      dir: '$models/ml-minilm-l12-trim',
    ),
    'embeddinggemma' => TfliteEmbedder(
      name: 'EmbeddingGemma-300M seq256 mixed-precision',
      dir: '$models/embeddinggemma',
      modelFile: 'embeddinggemma-300M_seq256_mixed-precision.tflite',
    ),
    _ => throw ArgumentError('unknown model $key'),
  };

  final result = <String, Object?>{'model': embedder.name};
  try {
    result['rssStartMb'] = _memMb('VmRSS');
    final load = Stopwatch()..start();
    await embedder.load();
    result['loadMs'] = load.elapsedMilliseconds;
    result['rssLoadedMb'] = _memMb('VmRSS');
    if (embedder is TfliteEmbedder) result['io'] = embedder.describe();

    for (var i = 0; i < _warmup; i++) {
      await embedder.embedIds(embedder.tokenize(timingTexts['medium']!));
    }
    result['timing'] = {
      for (final e in timingTexts.entries)
        e.key: await _time(embedder, e.value),
    };
    result['quality'] = await _quality(embedder);
    result['rssPeakMb'] = _memMb('VmHWM');
    await embedder.close();
  } catch (e, st) {
    result['error'] = '$e';
    result['stack'] = '$st'.split('\n').take(6).join(' | ');
  }
  // One line per section: Android's log cuts long lines.
  for (final e in result.entries) {
    debugPrint('BENCH ${e.key} ${jsonEncode(e.value)}');
  }
  debugPrint('BENCH done');
  exit(0);
}

/// Median and p90 of tokenize-only and full (tokenize + model + pooling)
/// time, in milliseconds, over [_runs] runs.
Future<Map<String, Object>> _time(Embedder e, String text) async {
  final ids = e.tokenize(text);
  final tok = <double>[];
  final full = <double>[];
  for (var i = 0; i < _runs; i++) {
    final t = Stopwatch()..start();
    e.tokenize(text);
    tok.add(t.elapsedMicroseconds / 1000);
    final f = Stopwatch()..start();
    await e.embedIds(e.tokenize(text));
    full.add(f.elapsedMicroseconds / 1000);
  }
  return {
    'tokens': ids.length,
    'tokenizeMedianMs': _pct(tok, .5),
    'medianMs': _pct(full, .5),
    'p90Ms': _pct(full, .9),
  };
}

/// Each text's nearest neighbour should be its partner. Also reports how
/// far apart partner and non-partner similarities are (threshold room).
Future<Map<String, Object>> _quality(Embedder e) async {
  final texts = [
    for (final p in qualityPairs) ...[p.$1, p.$2],
  ];
  final vectors = [for (final t in texts) await e.embedIds(e.tokenize(t))];
  var hits = 0;
  final partner = <double>[];
  final other = <double>[];
  for (var i = 0; i < texts.length; i++) {
    final mate = i.isEven ? i + 1 : i - 1;
    var best = -1;
    var bestSim = -2.0;
    for (var j = 0; j < texts.length; j++) {
      if (j == i) continue;
      final sim = cosine(vectors[i], vectors[j]);
      if (sim > bestSim) {
        bestSim = sim;
        best = j;
      }
      if (j == mate) {
        if (i < j) partner.add(sim);
      } else if (i < j) {
        other.add(sim);
      }
    }
    if (best == mate) hits++;
  }
  return {
    'top1': '$hits/${texts.length}',
    'partnerMean': _round(partner.reduce((a, b) => a + b) / partner.length),
    'partnerP10': _pct(partner, .1),
    'otherMean': _round(other.reduce((a, b) => a + b) / other.length),
    'otherP90': _pct(other, .9),
    'otherMax': _pct(other, 1),
  };
}

double _pct(List<double> values, double q) {
  final s = [...values]..sort();
  return _round(s[((s.length - 1) * q).round()]);
}

double _round(double v) => (v * 1000).round() / 1000;

/// A memory figure from /proc/self/status, in MB.
double _memMb(String field) {
  final line = File('/proc/self/status')
      .readAsLinesSync()
      .firstWhere((l) => l.startsWith('$field:'));
  final kb = int.parse(line.split(RegExp(r'\s+'))[1]);
  return _round(kb / 1024);
}
