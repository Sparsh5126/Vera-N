import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Watches the notes folder on a laptop while the app is open, so changes
/// Syncthing brings in reach the index within a second or two, without
/// polling (docs/LAPTOP_PLAN.md, L0). Bursts of events (a sync of many
/// files) end in one call to [onChange].
class FolderWatcher {
  FolderWatcher(this.root, this.onChange);

  /// Quiet time after the last event before [onChange] runs.
  static const settle = Duration(seconds: 1);

  /// `MyNotes/`: notes, attachments and `.app/` all live under it.
  final String root;
  final void Function() onChange;
  StreamSubscription<FileSystemEvent>? _events;
  Timer? _settling;

  void start() {
    _events ??= Directory(root)
        .watch(recursive: true)
        .where((e) => !ignored(p.relative(e.path, from: root)))
        .listen((_) {
          _settling?.cancel();
          _settling = Timer(settle, onChange);
        }, onError: (Object _) {});
  }

  Future<void> stop() async {
    _settling?.cancel();
    await _events?.cancel();
    _events = null;
  }

  /// Syncthing's own folders, its and the app's temporary files: not
  /// changes to notes. `.app/` is watched: another device's rejections
  /// and the laptop's results arrive there.
  static bool ignored(String relative) {
    final parts = p.split(relative);
    if (parts.any((s) => s == '.stfolder' || s == '.stversions')) return true;
    final name = parts.last;
    return name.endsWith('.tmp') ||
        name.startsWith('~syncthing~') ||
        name.startsWith('.syncthing.');
  }
}
