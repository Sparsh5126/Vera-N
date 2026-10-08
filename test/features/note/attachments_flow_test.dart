import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/storage/files/attachment_name.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/features/note/drawing/drawing.dart';
import 'package:vera_n/features/note/drawing/drawing_canvas.dart';
import 'package:vera_n/features/note/widgets/drawing_embed.dart';
import 'package:vera_n/features/note/widgets/photo_embed.dart';
import 'package:vera_n/features/note/widgets/voice_embed.dart';

import '../../support/app_harness.dart';
import '../../support/memory_note_file_store.dart';

void main() {
  late AppHarness app;
  setUp(() => app = AppHarness());

  MemoryNoteFileStore files() =>
      app.storage.store.current as MemoryNoteFileStore;

  String editorText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  Future<void> newNote(WidgetTester tester, String words) async {
    await app.pump(tester);
    await tester.tap(find.text(AppCopy.newNote));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), words);
    await tester.pumpAndSettle();
  }

  Future<void> attach(WidgetTester tester, String how) async {
    await tester.tap(find.byTooltip(AppCopy.attach));
    await tester.pumpAndSettle();
    await tester.tap(find.text(how));
    await tester.pumpAndSettle();
  }

  group('drawing model', () {
    test('strokes survive the file; reopening fits another canvas', () {
      const d = Drawing(
        size: Size(100, 50),
        strokes: [
          [Offset(0, 0), Offset(100, 50)],
        ],
      );
      final back = Drawing.fromJson(d.toJson())!;
      expect(back.size, d.size);
      expect(back.strokes.single, d.strokes.single);
      final fitted = d.fittedTo(const Size(200, 200));
      // Twice as big, centred vertically.
      expect(fitted.strokes.single, [
        const Offset(0, 50),
        const Offset(200, 150),
      ]);
      expect(Drawing.fromJson('not json'), isNull);
    });
  });

  testWidgets('the paperclip shows while editing; a photo goes in on its '
      'own line and shows as a picture', (tester) async {
    await newNote(tester, 'Trip');
    await attach(tester, AppCopy.attachCamera);
    final name = files().attachments.keys.single;
    expect(AttachmentName.kindOf(name), isNotNull);
    expect(editorText(tester), 'Trip\n${NoteMarkup.embed(name)}\n');
    expect(find.byType(PhotoEmbed), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('a voice note records, saves and shows a play button', (
    tester,
  ) async {
    await newNote(tester, 'Idea');
    await attach(tester, AppCopy.attachVoice);
    expect(find.text(AppCopy.recording), findsOneWidget);
    expect(app.capture.recording, isTrue);
    await tester.tap(find.text(AppCopy.save));
    await tester.pumpAndSettle();
    final name = files().attachments.keys.single;
    expect(name, endsWith(AttachmentName.voiceExtension));
    expect(find.byType(VoiceEmbed), findsOneWidget);
    expect(find.byTooltip(AppCopy.play), findsOneWidget);
    await app.finish(tester);
  });

  testWidgets('no microphone: says how to allow it, attaches nothing', (
    tester,
  ) async {
    app.capture.micAllowed = false;
    await newNote(tester, 'Idea');
    await attach(tester, AppCopy.attachVoice);
    expect(find.text(AppCopy.microphoneNeeded), findsOneWidget);
    await tester.tap(find.text(AppCopy.cancel));
    await tester.pumpAndSettle();
    expect(files().attachments, isEmpty);
    expect(editorText(tester), 'Idea');
    await app.finish(tester);
  });

  testWidgets('a drawing is saved as a picture with its strokes', (
    tester,
  ) async {
    await newNote(tester, 'Sketch');
    await attach(tester, AppCopy.attachDrawing);
    final canvas = tester.getCenter(find.byType(DrawingCanvas));
    await tester.dragFrom(canvas, const Offset(80, 40));
    await tester.pumpAndSettle();
    final save = find.widgetWithText(TextButton, AppCopy.save);
    expect(tester.widget<TextButton>(save).onPressed, isNotNull);
    // Making the picture is real image work: let it run.
    await tester.tap(save);
    await tester.pump();
    await tester.runAsync(() async {
      for (var i = 0; i < 100 && files().attachments.length < 2; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    final names = files().attachments.keys.toSet();
    final picture = names.firstWhere((n) => n.endsWith('.drawing.png'));
    expect(names, {picture, AttachmentName.strokesOf(picture)});
    expect(editorText(tester), contains(NoteMarkup.embed(picture)));
    expect(find.byType(DrawingEmbed), findsOneWidget);
    await app.finish(tester);
  });
}
