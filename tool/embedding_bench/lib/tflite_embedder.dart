import 'dart:io';
import 'dart:typed_data';

import 'package:dart_sentencepiece_tokenizer/dart_sentencepiece_tokenizer.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'embedder.dart';

/// EmbeddingGemma as LiteRT (TFLite): Gemma SentencePiece tokenizer, fixed
/// sequence length. The model's inputs and output shape are read from the
/// file and logged, so the runner can confirm what it is feeding.
class TfliteEmbedder implements Embedder {
  TfliteEmbedder({
    required this.name,
    required this.dir,
    required this.modelFile,
    this.prefix = 'task: sentence similarity | query: ',
    this.threads = 4,
  });

  @override
  final String name;
  final String dir;
  final String modelFile;
  final String prefix;
  final int threads;

  static const _pad = 0;
  static const _eos = 1;

  late SentencePieceTokenizer _tokenizer;
  late Interpreter _interpreter;
  late int _seqLen;

  /// What the model expects and returns, for the log.
  String describe() {
    final ins = _interpreter.getInputTensors();
    final outs = _interpreter.getOutputTensors();
    return 'inputs ${ins.map((t) => '${t.name}${t.shape}${t.type}')} '
        'outputs ${outs.map((t) => '${t.name}${t.shape}${t.type}')}';
  }

  @override
  Future<void> load() async {
    _tokenizer = await SentencePieceTokenizer.fromModelFile(
      '$dir/sentencepiece.model',
      config: SentencePieceConfig.gemma,
    );
    final options = InterpreterOptions()..threads = threads;
    _interpreter = Interpreter.fromFile(
      File('$dir/$modelFile'),
      options: options,
    );
    _seqLen = _interpreter.getInputTensors().first.shape.last;
  }

  @override
  List<int> tokenize(String text) {
    final ids = _tokenizer.encode('$prefix$text').ids.toList();
    if (ids.isEmpty || ids.last != _eos) ids.add(_eos);
    if (ids.length > _seqLen) return [...ids.sublist(0, _seqLen - 1), _eos];
    return ids;
  }

  @override
  Future<Float32List> embedIds(List<int> ids) async {
    final padded = List<int>.filled(_seqLen, _pad)..setAll(0, ids);
    final mask = List<int>.filled(_seqLen, 0)..fillRange(0, ids.length, 1);
    final inputTensors = _interpreter.getInputTensors();
    final inputs = <Object>[
      for (var i = 0; i < inputTensors.length; i++) [i == 0 ? padded : mask],
    ];
    final outShape = _interpreter.getOutputTensors().first.shape;
    final dim = outShape.last;
    final seq = outShape.length == 3 ? outShape[1] : 1;
    final output = List.generate(
      1,
      (_) => outShape.length == 3
          ? List.generate(seq, (_) => List<double>.filled(dim, 0))
          : List<double>.filled(dim, 0),
    );
    _interpreter.runForMultipleInputs(inputs, {0: output});
    if (outShape.length == 2) {
      return normalize(Float32List.fromList(output.first as List<double>));
    }
    // Per-token output: mean over the real (unpadded) tokens.
    final rows = output.first as List<List<double>>;
    return meanPool(
      [for (var t = 0; t < ids.length; t++) ...rows[t]],
      ids.length,
      dim,
    );
  }

  @override
  Future<void> close() async => _interpreter.close();
}
