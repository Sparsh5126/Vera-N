import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  /// A note edited here while its file was changed in another app.
  Future<int> conflicted() async {
    final s = app.storage;
    final ref = await s.notes.create('Plan\nOriginal text.');
    await s.writer.flush();
    final path = (await s.notes.getNote(ref))!.path;
    final file = await s.store.read(path);
    await s.store.write(
      path,
      file.replaceFirst('Original text.', 'Changed outside.'),
    );
    await s.notes.updateBody(ref, 'Plan\nChanged in the app.');
    await s.reconcile();
    return ref;
  }

  testWidgets('Home marks it; the note offers the choices; Keep both '
      'keeps both versions as notes', (tester) async {
    await tester.runAsync(conflicted);
    await app.pump(tester);
    expect(
      find.bySemanticsLabel(RegExp(AppCopy.changedInTwoPlaces)),
      findsOneWidget,
    );

    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.conflictNotice), findsOneWidget);

    await tester.tap(find.text(AppCopy.keepBothVersions));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.conflictNotice), findsNothing);
    final notes = await tester.runAsync(
      () => app.storage.notes.watchNotes().first,
    );
    expect(notes, hasLength(2));
    expect(
      notes!.map((n) => n.preview),
      containsAll(['Changed in the app.', 'Changed outside.']),
    );
    await app.finish(tester);
  });
}
