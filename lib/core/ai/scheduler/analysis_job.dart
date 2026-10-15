import '../../storage/storage_services.dart';
import '../embedder/onnx_embedder.dart';
import '../suggestions/suggestion_learning.dart';
import 'analysis_run.dart';

/// One analysis run with the learned match bars, shared by the phone's
/// background task and the laptop's in-app runner. Returns true when every
/// changed note was analysed.
Future<bool> runAnalysisOnce(
  AnalysisStorage storage, {
  required bool Function() stopRequested,
}) async {
  final links = await storage.settings.learning('link');
  final tags = await storage.settings.learning('tag');
  final done = await AnalysisRun(
    analysis: storage.analysis,
    suggestions: storage.suggestions,
    embedder: OnnxEmbedder(),
    stopRequested: stopRequested,
    linkThreshold: SuggestionLearning.thresholdFor(
      links,
      SuggestionLearning.baseFor('link'),
    ),
    tagThreshold: SuggestionLearning.thresholdFor(
      tags,
      SuggestionLearning.baseFor('tag'),
    ),
  ).run();
  // "Last looked" in Settings, so waiting and finding nothing differ.
  await storage.settings.setLastAnalysis(DateTime.now());
  return done;
}
