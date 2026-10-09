import 'package:flutter/foundation.dart';

import '../ai/embedder/onnx_embedder.dart';
import '../storage/repositories/analysis_repository.dart';
import '../storage/repositories/booster_repository.dart';
import '../storage/repositories/settings_repository.dart';
import '../storage/repositories/suggestions_repository.dart';
import 'ai_server_address.dart';
import 'ai_server_client.dart';
import 'booster_run.dart';

/// The laptop booster's entry point (docs/LAPTOP_PLAN.md, L2): after the
/// on-device analysis, while idle and on mains power, asks the local AI
/// server for the four jobs. With no server running it does nothing, which
/// is a normal state; the phone never waits for it.
class LaptopBooster {
  LaptopBooster({
    required this.booster,
    required this.analysis,
    required this.suggestions,
    required this.settings,
    this.address,
    this.preferredModel,
  });

  final BoosterRepository booster;
  final AnalysisRepository analysis;
  final SuggestionsRepository suggestions;
  final SettingsRepository settings;

  /// Settings come in L4; until then, LM Studio's default address and the
  /// first chat model it offers.
  final AiServerAddress? address;
  final String? preferredModel;

  /// Returns true when there is nothing more to do now (all done, or no
  /// server), false when stopped early with jobs left.
  Future<bool> runOnce(bool Function() stopRequested) async {
    final client = AiServerClient(
      address ?? AiServerAddress.parse(AiServerAddress.fallback),
    );
    try {
      final model = pickModel(await client.models(), preferredModel);
      if (model == null) return true;
      final done = await BoosterRun(
        client: client,
        model: model,
        booster: booster,
        analysis: analysis,
        suggestions: suggestions,
        deviceId: await settings.deviceId(),
        embedderModel: OnnxEmbedder().model,
        stopRequested: stopRequested,
      ).run();
      debugPrint('VeraN booster: run with $model, all done: $done');
      return done;
    } on AiServerUnavailable catch (e) {
      debugPrint('VeraN booster: no AI server ($e)');
      return true;
    } on AddressRefused catch (e) {
      debugPrint('VeraN booster: address refused ($e)');
      return true;
    } finally {
      client.close();
    }
  }

  /// [preferred] if the server has it, else its first chat model (servers
  /// also list embedding models, which can't answer).
  static String? pickModel(List<String> ids, String? preferred) {
    if (preferred != null && ids.contains(preferred)) return preferred;
    for (final id in ids) {
      if (!id.toLowerCase().contains('embed')) return id;
    }
    return null;
  }
}
