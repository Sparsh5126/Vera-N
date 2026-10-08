import 'dart:typed_data';

import 'package:dart_sentencepiece_tokenizer/dart_sentencepiece_tokenizer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import '../matching/vectors.dart';
import 'embedder.dart';
import 'model_files.dart';

/// The bundled multilingual MiniLM, run on the phone with ONNX Runtime
/// (ARCHITECTURE.md §8). Tokenized in Dart; vectors are mean-pooled.
class OnnxEmbedder implements Embedder {
  @override
  String get model => '${ModelFiles.name}@${ModelFiles.version}';

  static const _maxTokens = 128;
  static const _bos = 0; // <s>
  static const _eos = 2; // </s>

  /// A small batch job in the background: two threads are enough and
  /// leave the phone responsive.
  static const _threads = 2;

  SentencePieceTokenizer? _tokenizer;
  OrtSession? _session;
  List<String> _inputs = const [];

  @override
  Future<void> load() async {
    final json = await rootBundle.loadString(ModelFiles.tokenizerAsset);
    _tokenizer = HuggingFaceTokenizerLoader.fromJsonString(json);
    final session = await OnnxRuntime().createSession(
      await ModelFiles.modelPath(),
      options: OrtSessionOptions(intraOpNumThreads: _threads),
    );
    _session = session;
    _inputs = [
      for (final i in await session.getInputInfo()) i['name'] as String,
    ];
  }

  @override
  int countTokens(String text) => _ids(text).length;

  @override
  Future<Float32List> embed(String text) async {
    final session = _session!;
    final body = _ids(text);
    final ids = [_bos, ...body.take(_maxTokens - 2), _eos];
    final n = ids.length;
    final inputs = <String, OrtValue>{};
    for (final name in _inputs) {
      final data = switch (name) {
        'input_ids' => Int64List.fromList(ids),
        'attention_mask' => Int64List.fromList(List.filled(n, 1)),
        _ => Int64List(n), // token_type_ids
      };
      inputs[name] = await OrtValue.fromList(data, [1, n]);
    }
    final outputs = await session.run(inputs);
    try {
      final hidden = outputs.values.first;
      final flat = await hidden.asFlattenedList();
      return Vectors.meanPool(
        [for (final x in flat) (x as num).toDouble()],
        n,
        hidden.shape.last,
      );
    } finally {
      for (final v in [...inputs.values, ...outputs.values]) {
        await v.dispose();
      }
    }
  }

  /// Token ids without `<s>` / `</s>`, whatever the tokenizer adds.
  List<int> _ids(String text) {
    final ids = _tokenizer!.encode(text).ids.toList();
    if (ids.isNotEmpty && ids.first == _bos) ids.removeAt(0);
    if (ids.isNotEmpty && ids.last == _eos) ids.removeLast();
    return ids;
  }

  @override
  Future<void> close() async {
    await _session?.close();
    _session = null;
    _tokenizer = null;
  }
}
