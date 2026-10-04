import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  late AppHarness app;

  setUp(() => app = AppHarness());

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  testWidgets('Recent is the default and shows every note', (tester) async {
    await app.storage.notes.create('Loose thought');
    await app.storage.notes.create('In ideas', folder: 'Ideas');
    await app.pump(tester);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Loose thought'), findsOneWidget);
    expect(find.text('In ideas'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('Folders: pick a folder to see its notes, again to clear', (
    tester,
  ) async {
    await app.storage.notes.create('Loose thought');
    await app.storage.notes.create('Top idea', folder: 'Ideas');
    await app.storage.notes.create('Deep idea', folder: 'Ideas/Story');
    await app.pump(tester);

    await tapText(tester, 'Folders');
    expect(find.text('Ideas'), findsOneWidget);
    expect(find.text('Ideas/Story'), findsOneWidget);
    expect(find.text('Top idea'), findsNothing);

    await tapText(tester, 'Ideas');
    expect(find.text('Top idea'), findsOneWidget);
    expect(find.text('Deep idea'), findsOneWidget);
    expect(find.text('Loose thought'), findsNothing);

    await tapText(tester, 'Ideas');
    expect(find.text('Top idea'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('Tags: pick a tag to see its notes', (tester) async {
    final a = await app.storage.notes.create('Tagged one');
    await app.storage.notes.setTags(a, ['story']);
    await app.storage.notes.create('Untagged');
    await app.pump(tester);

    await tapText(tester, 'Tags');
    await tapText(tester, '#story');
    expect(find.text('Tagged one'), findsOneWidget);
    expect(find.text('Untagged'), findsNothing);
    await app.finish(tester);
  });

  testWidgets('empty folder and tag views say so', (tester) async {
    await app.storage.notes.create('Just one');
    await app.pump(tester);
    await tapText(tester, 'Folders');
    expect(find.text('No folders yet.'), findsOneWidget);
    await tapText(tester, 'Tags');
    expect(find.text('No tags yet.'), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('a picked folder stays picked after opening a note', (
    tester,
  ) async {
    await app.storage.notes.create('Top idea', folder: 'Ideas');
    await app.pump(tester);
    await tapText(tester, 'Folders');
    await tapText(tester, 'Ideas');
    await tapText(tester, 'Top idea');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Top idea'), findsOneWidget);
    await app.finish(tester);
  });
}
