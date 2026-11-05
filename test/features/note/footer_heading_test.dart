import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/storage/files/note_footer.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/features/note/state/markup_editing.dart';
import 'package:vera_n/features/note/state/markup_semantics.dart';

import '../../support/app_harness.dart';

/// The "Linked notes" footer's heading shows as a heading, "Linked Notes",
/// never as `## Linked notes` (user, 2026-11-05). The file is unchanged.
void main() {
  const note = 'Quotes\nsome words\n\n## Linked notes\n- [[n2|Poems]]\n';
  final headingAt = note.indexOf(NoteFooter.heading);
  final headingEnd = headingAt + NoteFooter.heading.length;

  test('the heading line is one block; a "## " line elsewhere is not', () {
    final footer = NoteMarkup.find(note)
        .where((s) => s.kind == MarkupKind.footer)
        .single;
    expect((footer.start, footer.end), (headingAt, headingEnd));
    expect(footer.isBlock, isTrue);
    expect(
      NoteMarkup.find('x\n## Linked notes and more')
          .where((s) => s.kind == MarkupKind.footer),
      isEmpty,
    );
  });

  test('a screen reader hears the heading as shown', () {
    final spoken = MarkupSemantics.of(note, NoteMarkup.find(note));
    expect(spoken.length, note.length);
    expect(
      spoken.substring(headingAt + 1, headingEnd).trim(),
      AppCopy.linkedNotes,
    );
  });

  test('the cursor steps over it, and backspace into it removes the line', () {
    final inside = MarkupEditing.protect(
      TextEditingValue(
        text: note,
        selection: TextSelection.collapsed(offset: headingAt),
      ),
      TextEditingValue(
        text: note,
        selection: TextSelection.collapsed(offset: headingAt + 3),
      ),
    );
    expect(inside.selection.baseOffset, headingEnd);

    final cut = note.replaceRange(headingEnd - 1, headingEnd, '');
    final fixed = MarkupEditing.protect(
      TextEditingValue(
        text: note,
        selection: TextSelection.collapsed(offset: headingEnd),
      ),
      TextEditingValue(
        text: cut,
        selection: TextSelection.collapsed(offset: headingEnd - 1),
      ),
    );
    expect(fixed.text, 'Quotes\nsome words\n\n- [[n2|Poems]]\n');
  });

  testWidgets('the editor shows "Linked Notes", not the Markdown', (
    tester,
  ) async {
    final app = AppHarness();
    await app.storage.notes.create(note);
    await app.pump(tester);
    await tester.tap(find.text('Quotes').first);
    await tester.pumpAndSettle();

    expect(find.text(AppCopy.linkedNotes), findsOneWidget);
    await app.finish(tester);
  });
}
