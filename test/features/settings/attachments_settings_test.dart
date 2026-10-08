import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/core/styles/app_styles.dart';

import '../../support/app_harness.dart';
import '../../support/memory_note_file_store.dart';

void main() {
  late AppHarness app;
  setUp(() => app = AppHarness());

  MemoryNoteFileStore files() =>
      app.storage.store.current as MemoryNoteFileStore;

  final page = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );

  Future<void> openAt(WidgetTester tester, Finder row) async {
    await app.pump(tester);
    await tester.tap(find.bySemanticsLabel(AppCopy.navSettings).last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(row, 200, scrollable: page.first);
    await tester.runAsync(
      () => Scrollable.ensureVisible(tester.element(row), alignment: 0.5),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('unused attachments go only once Undo is gone', (tester) async {
    await files().writeAttachment('used.jpg', Uint8List(10));
    await files().writeAttachment('loose.jpg', Uint8List(10));
    await app.storage.notes.create('Trip\n${NoteMarkup.embed('used.jpg')}');
    await openAt(tester, find.text(AppCopy.removeUnused));
    expect(find.text(AppCopy.attachmentsUnused(1)), findsOneWidget);

    await tester.tap(find.text(AppCopy.removeUnused));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.attachmentsAllUsed), findsOneWidget);
    await tester.tap(find.text(AppCopy.undo));
    await tester.pumpAndSettle();
    expect(files().attachments.keys, containsAll(['used.jpg', 'loose.jpg']));

    await tester.tap(find.text(AppCopy.removeUnused));
    await tester.pumpAndSettle();
    await tester.pump(AppMotion.undoWindow);
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(files().attachments.keys, ['used.jpg']);
    await app.finish(tester);
  });

  testWidgets('automatic clean-up is off until switched on', (tester) async {
    await openAt(tester, find.text(AppCopy.cleanAttachmentsAuto));
    final tile = find.widgetWithText(
      SwitchListTile,
      AppCopy.cleanAttachmentsAuto,
    );
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    final prefs = await tester.runAsync(app.storage.settings.prefs);
    expect(prefs!.cleanAttachments, isTrue);
    await app.finish(tester);
  });
}
