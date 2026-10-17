import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether notes are being dragged on Home (UI spec §5): the folder tray
/// shows while true. Set once the finger moves, so holding a card and
/// letting go (which selects it) never flashes the tray.
class HomeDrag extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;
  void stop() => state = false;
}

final homeDragProvider = NotifierProvider<HomeDrag, bool>(HomeDrag.new);
