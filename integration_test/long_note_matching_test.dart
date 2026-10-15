// Measures how well notes match with the real on-device model, for several
// ways of cutting notes into pieces (2026-10-15: long notes got no
// suggestions). Run on a desktop or phone:
//   flutter test integration_test/long_note_matching_test.dart -d windows
// Prints a table; asserts nothing about quality.
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vera_n/core/ai/ai_settings.dart';
import 'package:vera_n/core/ai/chunking/note_chunker.dart';
import 'package:vera_n/core/ai/embedder/onnx_embedder.dart';
import 'package:vera_n/core/ai/matching/vectors.dart';

import 'matching_eval_set.dart';

typedef Cutter = List<String> Function(String body);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('long-note matching, by way of cutting', (tester) async {
    await tester.runAsync(() async {
      final embedder = OnnxEmbedder();
      await embedder.load();
      final cache = <String, Uint8List>{};
      Future<Uint8List> vector(String text) async =>
          cache[text] ??= Vectors.quantize(await embedder.embed(text));

      List<String> sentences(String body, int maxTokens) => [
        for (final c in NoteChunker.split(
          body,
          embedder.countTokens,
          maxTokens: maxTokens,
        ))
          c.text,
      ];
      final cutters = <String, Cutter>{
        'NoteChunker': (b) => sentences(b, AiSettings.chunkTokens),
        // The same notes typed with one Enter between thoughts.
        'NoteChunker, one-Enter notes': (b) =>
            sentences(_oneEnter(b), AiSettings.chunkTokens),
      };
      final texts = {...MatchingEvalSet.notes, ...MatchingEvalSet.short};
      final unrelated = <(String, String)>[
        for (var i = 0; i < MatchingEvalSet.groups.length; i++)
          for (var j = i + 1; j < MatchingEvalSet.groups.length; j++)
            for (final a in MatchingEvalSet.groups[i])
              for (final b in MatchingEvalSet.groups[j]) (a, b),
      ];
      final out = StringBuffer()
        ..writeln('MATCHING EVAL (bar ${AiSettings.strongMatch})')
        ..writeln(
          'way | related found | related min/median | unrelated over bar '
          '| unrelated max | pieces',
        );
      for (final cut in cutters.entries) {
        final pieces = <String, List<Uint8List>>{};
        var count = 0;
        for (final t in texts.entries) {
          final parts = cut.value(t.value);
          count += parts.length;
          pieces[t.key] = [for (final p in parts) await vector(p)];
        }
        double best(String a, String b) => [
          for (final x in pieces[a]!)
            for (final y in pieces[b]!) Vectors.cosine(x, y),
        ].reduce(max);
        if (cut.key == 'NoteChunker') {
          for (final (a, b) in MatchingEvalSet.related) {
            out.writeln('  $a ~ $b: ${best(a, b).toStringAsFixed(2)}');
          }
          var worst = ('', '', 0.0);
          for (final (a, b) in unrelated) {
            if (best(a, b) > worst.$3) worst = (a, b, best(a, b));
          }
          out.writeln('  closest unrelated: ${worst.$1} ~ ${worst.$2}');
        }
        out.writeln(
          _row(
            cut.key,
            [for (final (a, b) in MatchingEvalSet.related) best(a, b)],
            [for (final (a, b) in unrelated) best(a, b)],
            count,
          ),
        );
      }
      // Whole notes: the mean of a note's chunks.
      final means = <String, Float32List>{};
      for (final t in texts.entries) {
        means[t.key] = _mean([
          for (final p in sentences(t.value, AiSettings.chunkTokens))
            await vector(p),
        ]);
      }
      double whole(String a, String b) => _dot(means[a]!, means[b]!);
      out.writeln(
        _row(
          'whole-note mean',
          [for (final (a, b) in MatchingEvalSet.related) whole(a, b)],
          [for (final (a, b) in unrelated) whole(a, b)],
          0,
        ),
      );
      await embedder.close();
      // ignore: avoid_print
      print(out);
    });
  });
}

String _row(String name, List<double> related, List<double> unrelated, int n) {
  final bar = AiSettings.strongMatch;
  final sorted = [...related]..sort();
  String f(double v) => v.toStringAsFixed(2);
  return '$name | ${related.where((s) => s >= bar).length}/${related.length} '
      '| ${f(sorted.first)}/${f(sorted[sorted.length ~/ 2])} '
      '| ${unrelated.where((s) => s >= bar).length}/${unrelated.length} '
      '| ${f(unrelated.reduce(max))} | $n';
}

String _oneEnter(String body) => body.replaceAll(RegExp(r'\n\s*\n'), '\n');

Float32List _mean(List<Uint8List> vectors) {
  final out = Float32List(vectors.first.length);
  for (final v in vectors) {
    final x = Int8List.sublistView(v);
    for (var i = 0; i < x.length; i++) {
      out[i] += x[i];
    }
  }
  final norm = sqrt(out.fold<double>(0, (s, x) => s + x * x));
  for (var i = 0; i < out.length; i++) {
    out[i] /= norm;
  }
  return out;
}

double _dot(Float32List a, Float32List b) {
  var s = 0.0;
  for (var i = 0; i < a.length; i++) {
    s += a[i] * b[i];
  }
  return s;
}
