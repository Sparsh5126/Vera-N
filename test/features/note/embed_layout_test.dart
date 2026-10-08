import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/core/styles/app_styles.dart';
import 'package:vera_n/features/note/widgets/note_editor_view.dart';
import 'package:vera_n/features/note/widgets/titled_text_controller.dart';

void main() {
  testWidgets('a tall attachment preview gets its own room in the text', (
    tester,
  ) async {
    final text =
        TitledTextController(
            text: 'Title\n${NoteMarkup.embed('a.drawing.svg')}\nAfter',
          )
          ..embedBuilder = (_) =>
              const SizedBox(key: Key('embed'), width: 100, height: 200);
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: NoteEditorView(
            text: text,
            focus: focus,
            autofocus: false,
            onChanged: (_) {},
            onTap: () {},
            onTapBelow: () {},
            details: const SizedBox.shrink(),
          ),
        ),
      ),
    );
    final field = tester.getRect(find.byType(TextField));
    final embed = tester.getRect(find.byKey(const Key('embed')));
    final title = tester.getRect(find.byType(EditableText));
    expect(field.height, greaterThan(200));
    expect(embed.top, greaterThan(title.top));
    expect(embed.bottom, lessThanOrEqualTo(field.bottom));
  });
}
