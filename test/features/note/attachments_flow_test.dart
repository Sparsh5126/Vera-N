import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/storage/files/attachment_name.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/features/note/drawing/drawing.dart';
import 'package:vera_n/features/note/drawing/drawing_canvas.dart';
import 'package:vera_n/features/note/drawing/drawing_svg.dart';
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
    test('lines survive the SVG; a tap stays a dot; others are refused', () {
      const d = Drawing(
        size: Size(100, 50),
        strokes: [
          [Offset(0, 0), Offset(100, 50.25)],
          [Offset(10, 10)],
        ],
      );
      final svg = DrawingSvg.encode(d);
      expect(svg, contains('<path d="M0 0 L100 50.3"/>'));
      final back = DrawingSvg.decode(svg)!;
      expect(back.size, d.size);
      expect(back.strokes, [
        [const Offset(0, 0), const Offset(100, 50.3)],
        [const Offset(10, 10)],
      ]);
      // Curves from other apps can't be drawn on.
      expect(
        DrawingSvg.decode('<svg viewBox="0 0 10 10"><path d="C1 2 3 4"/>'),
        isNull,
      );
      final fitted = d.fittedTo(const Size(200, 200));
      // Twice as big, centred vertically.
      expect(fitted.strokes.first.first, const Offset(0, 50));
    });
  });

  testWidgets('the paperclip shows while editing; a photo goes in on its '
      'own line and shows as a picture', (tester) async {
    await newNote(tester, 'Trip');
    await attach(tester, AppCopy.attachCamera);
    final name = files().attachments.keys.single;
    expect(AttachmentName.kindOf(name), isNotNull);
    expect(editorText(tester), 'Trip\n${NoteMarkup.embed(name)}\n\n');
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

  testWidgets('a drawing is saved as one vector file', (tester) async {
    await newNote(tester, 'Sketch');
    await attach(tester, AppCopy.attachDrawing);
    final canvas = tester.getCenter(find.byType(DrawingCanvas));
    await tester.dragFrom(canvas, const Offset(80, 40));
    await tester.pumpAndSettle();
    final save = find.widgetWithText(TextButton, AppCopy.save);
    expect(tester.widget<TextButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final picture = files().attachments.keys.single;
    expect(picture, endsWith(AttachmentName.drawingExtension));
    expect(utf8.decode(files().attachments[picture]!), startsWith('<svg'));
    expect(editorText(tester), contains(NoteMarkup.embed(picture)));
    expect(find.byType(DrawingEmbed), findsOneWidget);
    await app.finish(tester);
  });
}
