import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/scheduler/desktop_analysis.dart';
import 'package:vera_n/core/storage/files/folder_watcher.dart';
import 'package:vera_n/core/storage/repositories/analysis_repository.dart';
import 'package:vera_n/core/storage/repositories/settings_repository.dart';
import 'package:vera_n/core/storage/repositories/suggestions_repository.dart';
import 'package:vera_n/core/storage/storage_services.dart';

import '../../support/storage_harness.dart';

void main() {
  late StorageHarness h;
  late AnalysisStorage storage;
  setUp(() {
    h = StorageHarness();
    storage = (
      analysis: AnalysisRepository(h.db),
      suggestions: SuggestionsRepository(h.db),
      settings: SettingsRepository(h.db),
      close: () async {},
    );
  });
  tearDown(() => h.dispose());

  group('laptop analysis', () {
    late int runs;
    late bool power;
    late bool enabled;
    late bool stoppedEarly;

    DesktopAnalysis make({int batches = 1}) {
      var left = batches;
      return DesktopAnalysis(
        storage,
        enabled: () => enabled,
        onPower: () async => power,
        run: (_, stop) async {
          runs++;
          await Future<void>.delayed(const Duration(seconds: 1));
          if (stop()) stoppedEarly = true;
          return --left <= 0;
        },
      );
    }

    setUp(() {
      runs = 0;
      power = true;
      enabled = true;
      stoppedEarly = false;
    });

    test('runs only after the user has been idle', () {
      fakeAsync((time) {
        make().activity();
        time.elapse(DesktopAnalysis.idleFor - const Duration(seconds: 1));
        expect(runs, 0);
        time.elapse(const Duration(seconds: 2));
        expect(runs, 1);
      });
    });

    test('a key press or click stops a run and waits again', () {
      fakeAsync((time) {
        final a = make(batches: 5)..activity();
        time.elapse(DesktopAnalysis.idleFor);
        expect(runs, 1);
        a.activity();
        time.elapse(const Duration(seconds: 2));
        expect(stoppedEarly, isTrue);
        expect(runs, 1);
      });
    });

    test('a big library carries on in batches while idle', () {
      fakeAsync((time) {
        make(batches: 3).activity();
        time.elapse(DesktopAnalysis.idleFor + const Duration(seconds: 5));
        expect(runs, 3);
      });
    });

    test('never on battery, never with suggestions off', () {
      fakeAsync((time) {
        power = false;
        make().activity();
        time.elapse(DesktopAnalysis.idleFor * 2);
        power = true;
        enabled = false;
        make().activity();
        time.elapse(DesktopAnalysis.idleFor * 2);
        expect(runs, 0);
      });
    });
  });

  test('the watcher ignores Syncthing\'s folders and temporary files', () {
    expect(FolderWatcher.ignored('Notes/a.md'), isFalse);
    expect(FolderWatcher.ignored('.app/rejections-x.jsonl'), isFalse);
    expect(FolderWatcher.ignored('.stversions/Notes/a.md'), isTrue);
    expect(FolderWatcher.ignored('.stfolder'), isTrue);
    expect(FolderWatcher.ignored('Notes/.a.md.tmp'), isTrue);
    expect(FolderWatcher.ignored('Notes/~syncthing~a.md.tmp'), isTrue);
  });
}
