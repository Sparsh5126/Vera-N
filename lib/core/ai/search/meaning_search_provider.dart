import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/storage_providers.dart';
import '../embedder/embedder.dart';
import '../embedder/onnx_embedder.dart';
import 'meaning_search.dart';

/// Makes the on-device model; tests swap in a fake.
final embedderFactoryProvider = Provider<Embedder Function()>(
  (ref) => OnnxEmbedder.new,
);

/// Meaning search for the Search screen. Lives only while Search does,
/// and releases the model when it goes.
final meaningSearchProvider = Provider.autoDispose<MeaningSearch>((ref) {
  final storage = ref.watch(storageProvider);
  final search = MeaningSearch(
    storage.analysis,
    storage.notes,
    embedder: ref.watch(embedderFactoryProvider),
  );
  ref.onDispose(() => unawaited(search.close()));
  return search;
});
