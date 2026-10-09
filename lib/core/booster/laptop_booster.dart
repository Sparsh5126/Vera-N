import 'package:flutter/foundation.dart';

import '../ai/embedder/onnx_embedder.dart';
import '../models/booster_prefs.dart';
import '../storage/repositories/analysis_repository.dart';
import '../storage/repositories/booster_repository.dart';
import '../storage/repositories/settings_repository.dart';
import '../storage/repositories/suggestions_repository.dart';
import 'ai_server_address.dart';
import 'ai_server_client.dart';
import 'booster_run.dart';

/// What a connection check found, for Settings (docs/LAPTOP_PLAN.md, L4).
enum BoosterReach {
  /// An AI app answered; [BoosterCheck.models] lists what it offers.
  found,

  /// Nothing answered there: a normal state, not an error.
  nothing,

  /// The address leads off this computer (or the user's own network).
  notLocal,

  /// Not an address at all.
  invalid,
}

typedef BoosterCheck = ({BoosterReach reach, List<String> models});

/// The laptop booster's entry point (docs/LAPTOP_PLAN.md, L2, L4): after
/// the on-device analysis, while idle and on mains power, asks the local
/// AI app for the jobs switched on in Settings. Off, or with no AI app
/// running, it does nothing, which is a normal state; the phone never
/// waits for it.
class LaptopBooster {
  LaptopBooster({
    required this.booster,
    required this.analysis,
    required this.suggestions,
    required this.settings,
  });

  final BoosterRepository booster;
  final AnalysisRepository analysis;
  final SuggestionsRepository suggestions;
  final SettingsRepository settings;

  /// Returns true when there is nothing more to do now (off, all done, or
  /// no AI app), false when stopped early with jobs left.
  Future<bool> runOnce(bool Function() stopRequested) async {
    final prefs = await settings.boosterPrefs();
    if (!prefs.on || prefs.jobs.isEmpty) return true;
    final AiServerClient client;
    try {
      client = AiServerClient(_address(prefs));
    } on AddressRefused {
      return true;
    }
    try {
      final model = pickModel(await client.models(), prefs.model);
      if (model == null) return true;
      final done = await BoosterRun(
        client: client,
        model: model,
        booster: booster,
        analysis: analysis,
        suggestions: suggestions,
        deviceId: await settings.deviceId(),
        embedderModel: OnnxEmbedder().model,
        jobs: prefs.jobs,
        stopRequested: stopRequested,
      ).run();
      debugPrint('VeraN booster: run with $model, all done: $done');
      return done;
    } on AiServerUnavailable catch (e) {
      debugPrint('VeraN booster: no AI app ($e)');
      return true;
    } on AddressRefused catch (e) {
      debugPrint('VeraN booster: address refused ($e)');
      return true;
    } finally {
      client.close();
    }
  }

  /// Asks the AI app at [prefs]' address what it offers (Settings' "Check").
  static Future<BoosterCheck> check(BoosterPrefs prefs) async {
    final AiServerClient client;
    try {
      client = AiServerClient(_address(prefs));
    } on AddressRefused {
      return (reach: BoosterReach.invalid, models: const <String>[]);
    }
    try {
      final models = [
        for (final m in await client.models())
          if (!_isEmbedding(m)) m,
      ];
      return (reach: BoosterReach.found, models: models);
    } on AddressRefused catch (e) {
      return (
        reach: e.problem == AddressProblem.notLocal
            ? BoosterReach.notLocal
            : BoosterReach.nothing,
        models: const <String>[],
      );
    } on AiServerUnavailable {
      return (reach: BoosterReach.nothing, models: const <String>[]);
    } finally {
      client.close();
    }
  }

  /// [preferred] if the app has it, else its first chat model (apps also
  /// list embedding models, which can't answer).
  static String? pickModel(List<String> ids, String? preferred) {
    if (preferred != null && ids.contains(preferred)) return preferred;
    for (final id in ids) {
      if (!_isEmbedding(id)) return id;
    }
    return null;
  }

  static bool _isEmbedding(String id) => id.toLowerCase().contains('embed');

  static AiServerAddress _address(BoosterPrefs prefs) =>
      AiServerAddress.parse(prefs.address, ownNetwork: prefs.ownNetwork);
}
