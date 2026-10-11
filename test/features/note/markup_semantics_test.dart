import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/features/note/state/markup_semantics.dart';
import 'package:vera_n/features/note/widgets/titled_text_controller.dart';

String spoken(String text) => MarkupSemantics.of(text, NoteMarkup.find(text));

/// Collapses the silent spaces, the way a screen reader skips them.
String heard(String s) => s.replaceAll(RegExp(r' {2,}'), ' ').trim();

void main() {
  test('the spoken text is as long as the text, so the cursor lines up', () {
    const texts = [
      'a **big** idea',
      'see [[n1|Loop]] now',
      '- [ ] milk\n- [x] eggs',
      '[Octopus](https://en.wikipedia.org/wiki/Octopus)',
      '![](Attachments/a.drawing.svg)',
    ];
    for (final t in texts) {
      expect(spoken(t).length, t.length, reason: t);
    }
  });

  test('hidden symbols are silent', () {
    expect(heard(spoken('a **big** idea')), 'a big idea');
    expect(heard(spoken('see [[n1|Loop]] now')), 'see Loop now');
  });

  test('checkboxes say whether they are ticked', () {
    expect(spoken('- [ ] milk'), startsWith('☐'));
    expect(spoken('- [x] eggs'), startsWith('☑'));
    expect(spoken('- [ ] milk'), endsWith('milk'));
  });

  test('a link card says its title and site, not the address', () {
    final s = spoken(
      'Read\n[Octopus - Wikipedia](https://en.wikipedia.org/wiki/Octopus)',
    );
    expect(heard(s), contains('Link: Octopus - Wikipedia, en.wikipedia.org'));
    expect(s, isNot(contains('https')));
  });

  test('a bare link with no words in it says its site once', () {
    expect(heard(spoken('https://youtu.be/dQw4w9WgXcQ')), endsWith('youtu.be'));
    expect(heard(spoken('https://youtu.be/dQw4w9WgXcQ')), contains('Link:'));
  });

  test('attachments say what they are', () {
    expect(heard(spoken('![](Attachments/a.jpg)')), endsWith('Photo'));
    expect(
      heard(spoken('![](Attachments/a.drawing.svg)')),
      endsWith('Drawing'),
    );
    expect(heard(spoken('![](Attachments/a.m4a)')), endsWith('Voice note'));
  });

  test('plain text, Hindi included, is read as it is', () {
    const t = 'आज का दिन\nA good day';
    expect(spoken(t), t);
  });

  testWidgets('the editor reports the spoken text to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = TitledTextController(
      text: 'Reading\n[Octopus](https://ex.com/a)\nsee [[n1|Loop]]',
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TextField(controller: controller, maxLines: null),
        ),
      ),
    );
    final value = tester.getSemantics(find.byType(EditableText)).value;
    expect(value, contains('Link: Octopus, ex.com'));
    expect(value, contains('Loop'));
    expect(value, isNot(contains('https')));
    expect(value, isNot(contains('[[')));
    handle.dispose();
  });
}
