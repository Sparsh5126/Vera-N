import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vera_n/core/storage/files/desktop_folder_access.dart';
import 'package:vera_n/core/storage/files/folder_watcher.dart';

void main() {
  test(
    'a note arriving in the folder is picked up once, after it settles',
    () async {
      final dir = await Directory.systemTemp.createTemp('vera_watch');
      addTearDown(() => dir.delete(recursive: true));
      await Directory(p.join(dir.path, 'Notes')).create();
      var changes = 0;
      final settled = Completer<void>();
      final watcher = FolderWatcher(dir.path, () {
        changes++;
        if (!settled.isCompleted) settled.complete();
      })..start();
      addTearDown(watcher.stop);

      // A small burst, as a sync brings several files at once.
      for (var i = 0; i < 3; i++) {
        await File(p.join(dir.path, 'Notes', 'n$i.md')).writeAsString('N$i');
      }
      await settled.future.timeout(const Duration(seconds: 10));
      await Future<void>.delayed(FolderWatcher.settle * 2);
      expect(changes, 1);
    },
  );

  test('the laptop folder keeps notes in Notes/, as on the phone', () async {
    final dir = await Directory.systemTemp.createTemp('vera_pick');
    addTearDown(() => dir.delete(recursive: true));
    const access = DesktopFolderAccess();
    final store = access.storeFor(dir.path);
    await store.write('a.md', 'A');
    expect(File(p.join(dir.path, 'Notes', 'a.md')).existsSync(), isTrue);
    expect(await access.hasAccess(dir.path), isTrue);
    expect(await access.displayName(dir.path), p.basename(dir.path));
  });
}
