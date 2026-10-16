import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/sync_conflict.dart';
import 'package:vera_n/core/sync/mirror_bridge.dart';

import '../../support/memory_note_file_store.dart';

void main() {
  late MemoryNoteFileStore folder;
  late MemoryNoteFileStore mirror;
  late Directory tmp;
  late MirrorBridge bridge;

  setUp(() async {
    folder = MemoryNoteFileStore();
    mirror = MemoryNoteFileStore();
    tmp = await Directory.systemTemp.createTemp('vera_n_bridge');
    bridge = MirrorBridge(
      folder: folder,
      mirror: mirror,
      stateFile: File('${tmp.path}/state.json'),
      clock: () => DateTime(2026, 10, 16, 18, 30, 5),
    );
  });
  tearDown(() => tmp.delete(recursive: true));

  test('first run: the folder\'s notes, attachments and app files go to '
      'the mirror; a second run copies nothing', () async {
    folder.put('Trek.md', 'Triund in spring.');
    folder.put('Work/Plan.md', 'Finish the layout.');
    await folder.writeAttachment('photo.jpg', Uint8List.fromList([1, 2, 3]));
    await folder.writeAppFile('rejections-phone1.jsonl', '{"a":1}\n');
    final first = await bridge.run();
    expect(first.toMirror, 4);
    expect(mirror.text('Trek.md'), 'Triund in spring.');
    expect(mirror.text('Work/Plan.md'), 'Finish the layout.');
    expect(await mirror.readAttachment('photo.jpg'), [1, 2, 3]);
    expect(await mirror.readAppFile('rejections-phone1.jsonl'), '{"a":1}\n');

    final second = await bridge.run();
    expect(second.toMirror + second.toFolder, 0);
  });

  test('what sync brings into the mirror reaches the folder', () async {
    folder.put('Trek.md', 'Triund in spring.');
    await bridge.run();
    mirror.put('Trek.md', 'Triund in spring. Book the train.');
    mirror.put('FromLaptop.md', 'Written on the laptop.');
    await mirror.writeAppFile('laptop-ab12.jsonl', '{"kind":"why"}\n');
    final r = await bridge.run();
    expect(r.toFolder, 3);
    expect(folder.text('Trek.md'), 'Triund in spring. Book the train.');
    expect(folder.text('FromLaptop.md'), 'Written on the laptop.');
    expect(await folder.readAppFile('laptop-ab12.jsonl'), '{"kind":"why"}\n');
  });

  test('a deletion on either side is carried over', () async {
    folder.put('A.md', 'one');
    folder.put('B.md', 'two');
    await bridge.run();
    await folder.delete('A.md');
    await mirror.delete('B.md');
    await bridge.run();
    expect(mirror.text('A.md'), isNull);
    expect(folder.text('B.md'), isNull);
  });

  test('changed on both sides: the folder keeps its version and the other '
      'becomes a conflict copy', () async {
    folder.put('Trek.md', 'Triund.');
    await bridge.run();
    folder.put('Trek.md', 'Triund. Edited on the phone.');
    mirror.put('Trek.md', 'Triund. Edited on the laptop.');
    final r = await bridge.run();
    expect(r.conflicts, 1);
    expect(folder.text('Trek.md'), 'Triund. Edited on the phone.');
    expect(mirror.text('Trek.md'), 'Triund. Edited on the phone.');
    final copy = folder.files.keys.singleWhere(SyncConflict.isCopy);
    expect(copy, 'Trek.sync-conflict-20261016-183005-VERAPHN.md');
    expect(folder.text(copy), 'Triund. Edited on the laptop.');
    // The copy travels to the laptop too.
    await bridge.run();
    expect(mirror.text(copy), 'Triund. Edited on the laptop.');
  });

  test('deleted on one side, edited on the other: the edit is kept', () async {
    folder.put('Trek.md', 'Triund.');
    await bridge.run();
    await folder.delete('Trek.md');
    mirror.put('Trek.md', 'Triund. Still going.');
    await bridge.run();
    expect(folder.text('Trek.md'), 'Triund. Still going.');
  });

  test('the same edit on both sides is not a conflict', () async {
    folder.put('Trek.md', 'Triund.');
    await bridge.run();
    folder.put('Trek.md', 'Triund in May.');
    mirror.put('Trek.md', 'Triund in May.');
    final r = await bridge.run();
    expect(r.conflicts, 0);
    expect(folder.files.keys.where(SyncConflict.isCopy), isEmpty);
  });
}
