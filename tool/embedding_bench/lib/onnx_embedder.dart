import 'dart:io';
import 'dart:typed_data';

import 'package:dart_sentencepiece_tokenizer/dart_sentencepiece_tokenizer.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import 'embedder.dart';

/// An XLM-R style ONNX model (multilingual-e5-small, multilingual MiniLM):
/// SentencePiece Unigram tokenizer from tokenizer.json, mean pooling.
class OnnxEmbedder implements Embedder {
  OnnxEmbedder({
    required this.name,
    required this.dir,
    this.prefix = '',
    this.maxTokens = 256,
    this.threads = 4,
  });

  @override
  final String name;
  final String dir;

  /// Text put before every input (e5 expects "query: ").
  final String prefix;
  final int maxTokens;
  final int threads;

  static const _bos = 0; // <s> in XLM-R
  static const _eos = 2; // </s> in XLM-R

  late SentencePieceTokenizer _tokenizer;
  late OrtSession _session;
  late List<String> _inputNames;

  @override
  Future<void> load() async {
    final json = await File('$dir/tokenizer.json').readAsString();
    _tokenizer = HuggingFaceTokenizerLoader.fromJsonString(json);
    _session = await OnnxRuntime().createSession(
      '$dir/model_int8.onnx',
      options: OrtSessionOptions(intraOpNumThreads: threads),
    );
    _inputNames = [
      for (final i in await _session.getInputInfo()) i['name'] as String,
    ];
  }

  @override
  List<int> tokenize(String text) {
    final ids = _tokenizer.encode('$prefix$text').ids.toList();
    // Make sure the sequence is <s> … </s>, whatever the loader added.
    if (ids.isEmpty || ids.first != _bos) ids.insert(0, _bos);
    if (ids.last != _eos) ids.add(_eos);
    if (ids.length > maxTokens) {
      return [...ids.sublist(0, maxTokens - 1), _eos];
    }
    return ids;
  }

  @override
  Future<Float32List> embedIds(List<int> ids) async {
    final n = ids.length;
    final inputs = <String, OrtValue>{};
    for (final name in _inputNames) {
      final data = switch (name) {
        'input_ids' => Int64List.fromList(ids),
        'attention_mask' => Int64List.fromList(List.filled(n, 1)),
        _ => Int64List(n), // token_type_ids, if the export has it
      };
      inputs[name] = await OrtValue.fromList(data, [1, n]);
    }
    final outputs = await _session.run(inputs);
    final hidden = outputs.values.first;
    final flat = (await hidden.asFlattenedList()).cast<num>();
    final dim = hidden.shape.last;
    final vector = meanPool([for (final x in flat) x.toDouble()], n, dim);
    for (final v in [...inputs.values, ...outputs.values]) {
      await v.dispose();
    }
    return vector;
  }

  @override
  Future<void> close() => _session.close();
}
