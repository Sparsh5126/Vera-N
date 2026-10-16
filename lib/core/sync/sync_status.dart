/// Where built-in sync stands, for Settings (docs/LAPTOP_PLAN.md, S4).
enum SyncState {
  /// No engine in this build (or this platform).
  unavailable,

  /// Not paired: a normal state.
  notPaired,

  /// Paired, and the other device isn't reachable on this network now.
  waiting,

  /// Paired and connected.
  connected,

  /// The engine couldn't start.
  problem,
}

class SyncStatus {
  const SyncStatus(this.state, {this.peerName, this.lastSynced});

  final SyncState state;
  final String? peerName;

  /// When the two were last connected.
  final DateTime? lastSynced;

  bool get paired => state == SyncState.waiting || state == SyncState.connected;
}
