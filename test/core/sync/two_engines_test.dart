import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/sync/sync_setup.dart';

import '../../support/engine_pair.dart';

/// Two real engines on this computer, paired with the real pairing code
/// over loopback: a note written in one folder reaches the other, both
/// ways. Skipped where the engine hasn't been fetched.
void main() {
  test(
    'pair, then sync both ways',
    () async {
      final e = await EnginePair.create();
      try {
        await e.pair();
        expect((await SyncSetup(e.laptopApi).peer())!.name, 'Phone');
        expect((await SyncSetup(e.phoneApi).peer())!.name, 'Laptop');

        e.laptopFile('Notes/Trek.md')
          ..createSync(recursive: true)
          ..writeAsStringSync('Triund in spring.');
        await EnginePair.until(() => e.phoneFile('Notes/Trek.md').existsSync());
        e.phoneFile('Notes/Back.md').writeAsStringSync('Written on the phone.');
        await EnginePair.until(
          () => e.laptopFile('Notes/Back.md').existsSync(),
        );
        expect(
          e.laptopFile('Notes/Back.md').readAsStringSync(),
          'Written on the phone.',
        );

        await SyncSetup(e.phoneApi).unpair();
        expect(await SyncSetup(e.phoneApi).peer(), isNull);
      } finally {
        await e.dispose();
      }
    },
    skip: EnginePair.available ? false : 'sync engine not fetched',
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
