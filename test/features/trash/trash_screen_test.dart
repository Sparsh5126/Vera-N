import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/styles/app_styles.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  Future<int> trashed(String body) async {
    final ref = await app.storage.notes.create(body);
    await app.storage.notes.trash(ref);
    return ref;
  }

  Future<void> openTrash(WidgetTester tester) async {
    await app.pump(tester);
    await tester.tap(find.bySemanticsLabel(AppCopy.navSettings).last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(AppCopy.trash),
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, -3000),
      3000,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppCopy.trash));
    await tester.pumpAndSettle();
  }

  testWidgets('empty trash says so', (tester) async {
    await openTrash(tester);
    expect(find.text(AppCopy.emptyTrash), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Restore puts the note back on Home', (tester) async {
    await trashed('Lost idea\nWorth keeping.');
    await openTrash(tester);
    expect(find.text('Lost idea'), findsOneWidget);
    await tester.tap(find.text(AppCopy.restore));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.emptyTrash), findsOneWidget);
    expect(find.text(AppCopy.restored), findsOneWidget);
    final home = await app.storage.notes.watchNotes().first;
    expect(home.single.title, 'Lost idea');
    await app.finish(tester);
  });

  testWidgets('Delete forever waits for its Undo; Undo keeps the note', (
    tester,
  ) async {
    await trashed('Draft\nOld text.');
    await openTrash(tester);
    await tester.tap(find.text(AppCopy.deleteForever));
    await tester.pumpAndSettle();
    expect(find.text('Draft'), findsNothing);
    await tester.tap(find.text(AppCopy.undo));
    await tester.pumpAndSettle();
    expect(find.text('Draft'), findsOneWidget);
    // Reading a live query inside the test's fake clock would leave its
    // clean-up timer stuck there; read in real time instead.
    final kept = await tester.runAsync(() => app.storage.trash.watch().first);
    expect(kept, hasLength(1));

    await tester.tap(find.text(AppCopy.deleteForever));
    await tester.pumpAndSettle();
    await tester.pump(AppMotion.undoWindow);
    await tester.pumpAndSettle();
    // The deletion runs once the Undo has gone; let it finish.
    await tester.runAsync(() => Future<void>.delayed(AppMotion.standard));
    final left = await tester.runAsync(() => app.storage.trash.watch().first);
    expect(left, isEmpty);
    await app.finish(tester);
  });
}
