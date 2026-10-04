import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  Future<void> longPress(WidgetTester tester, String title) async {
    await tester.longPress(find.text(title).first);
    await tester.pumpAndSettle();
  }

  testWidgets('long-press, Delete: the note leaves Home; Undo brings it back', (
    tester,
  ) async {
    final ref = await app.storage.notes.create('Old thought');
    await app.storage.notes.create('Keep me');
    await app.pump(tester);

    await longPress(tester, 'Old thought');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Old thought'), findsNothing);
    expect(find.text('Keep me'), findsOneWidget);
    expect(find.text('Moved to trash'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Old thought'), findsOneWidget);
    expect(
      (await app.storage.notes.getNote(ref))!.path,
      isNot(startsWith('.trash')),
    );
    await app.finish(tester);
  });

  testWidgets('long-press, Pin: the note moves to the pinned row', (
    tester,
  ) async {
    final ref = await app.storage.notes.create('Important');
    await app.pump(tester);
    expect(find.text('Pinned'), findsNothing);

    await longPress(tester, 'Important');
    await tester.tap(find.text('Pin'));
    await tester.pumpAndSettle();
    expect(find.text('Pinned'), findsOneWidget);
    expect((await app.storage.notes.getNote(ref))!.pinned, isTrue);

    await longPress(tester, 'Important');
    expect(find.text('Unpin'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('backing out of the menu changes nothing', (tester) async {
    await app.storage.notes.create('Untouched');
    await app.pump(tester);
    await longPress(tester, 'Untouched');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Untouched'), findsOneWidget);
    expect(find.text('Moved to trash'), findsNothing);
    await app.finish(tester);
  });
}
