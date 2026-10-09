import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/booster/laptop_booster.dart';
import '../../../core/models/booster_prefs.dart';
import '../../../core/storage/storage_providers.dart';

/// The laptop helper's settings (docs/LAPTOP_PLAN.md, L4).
class BoosterPrefsController extends AsyncNotifier<BoosterPrefs> {
  @override
  Future<BoosterPrefs> build() =>
      ref.read(storageProvider).settings.boosterPrefs();

  Future<void> change(BoosterPrefs Function(BoosterPrefs) edit) async {
    final next = edit(state.value ?? const BoosterPrefs());
    state = AsyncData(next);
    await ref.read(storageProvider).settings.saveBoosterPrefs(next);
  }
}

final boosterPrefsProvider =
    AsyncNotifierProvider<BoosterPrefsController, BoosterPrefs>(
      BoosterPrefsController.new,
    );

/// What answers at the chosen address; checked when Settings opens, when
/// the address changes, and on "Check". A local request only.
final boosterCheckProvider = FutureProvider.autoDispose<BoosterCheck>((
  ref,
) async {
  final prefs = await ref.watch(boosterPrefsProvider.future);
  return LaptopBooster.check(prefs);
});

/// When a laptop last finished a job, from the synced results files.
final lastHelpedProvider = FutureProvider.autoDispose<DateTime?>(
  (ref) => ref.watch(storageProvider).booster.lastHelped(),
);
