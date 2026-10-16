import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_service.dart';
import 'sync_status.dart';

/// Built-in sync; set in main.dart. Null in tests and builds without it.
final syncServiceProvider = Provider<SyncService?>((ref) => null);

/// Where sync stands, for Settings.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final sync = ref.watch(syncServiceProvider);
  if (sync == null) {
    yield const SyncStatus(SyncState.unavailable);
    return;
  }
  yield sync.current;
  yield* sync.status;
});
