import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/styles/app_styles.dart';
import 'package:vera_n/features/note/state/attachment_insert.dart';
import 'package:vera_n/features/note/widgets/note_editor_view.dart';
import 'package:vera_n/features/note/widgets/titled_text_controller.dart';

void main() {
  testWidgets('after attaching at the end, the cursor sits right under '
      'the picture, not several lines lower', (tester) async {
    final inserted = AttachmentInsert.insert(
      const TextEditingValue(
        text: 'Title',
        selection: TextSelection.collapsed(offset: 5),
      ),
      'a.drawing.svg',
    );
    final text = TitledTextController();
    text.embedBuilder = (_) =>
        const SizedBox(key: Key('embed'), width: 100, height: 200);
    text.value = inserted;
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
    final editable = tester
        .state<EditableTextState>(find.byType(EditableText))
        .renderEditable;
    final caret = editable.getLocalRectForCaret(text.selection.extent);
    final caretTop = editable.localToGlobal(caret.topLeft).dy;
    final embedBottom = tester.getRect(find.byKey(const Key('embed'))).bottom;
    expect(caretTop - embedBottom, inInclusiveRange(-1, AppSpace.l));
  });
}
