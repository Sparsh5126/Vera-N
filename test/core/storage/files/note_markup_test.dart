import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';

void main() {
  MarkupSpan only(String text, MarkupKind kind) =>
      NoteMarkup.find(text).singleWhere((s) => s.kind == kind);

  test('bold: the stars are hidden, the words are the content', () {
    const t = 'a **big** idea';
    final s = only(t, MarkupKind.bold);
    expect(t.substring(s.contentStart, s.contentEnd), 'big');
    expect(s.hides(2), isTrue);
    expect(s.hides(4), isFalse);
    expect(s.hides(7), isTrue);
  });

  test('bold needs words right inside the stars, on one line', () {
    expect(NoteMarkup.find('** not bold **'), isEmpty);
    expect(NoteMarkup.find('**a\nb**'), isEmpty);
    expect(NoteMarkup.find('2 ** 3 = 8'), isEmpty);
  });

  test('checklist lines: glyph, hidden symbols, ticked state', () {
    const t = 'list\n- [ ] milk\n- [x] bread';
    final spans = NoteMarkup.find(t)
        .where((s) => s.kind == MarkupKind.checkbox)
        .toList();
    expect(spans, hasLength(2));
    final milk = spans.first;
    expect(t.substring(milk.contentStart, milk.contentEnd), 'milk');
    expect(milk.checked, isFalse);
    expect(spans.last.checked, isTrue);
    expect(t[milk.glyphAt], ' ');
    expect(milk.hides(milk.start), isTrue);
    expect(milk.hides(milk.glyphAt), isFalse);
    expect(milk.hides(milk.contentStart - 1), isFalse);
  });

  test('bullet lines, and checklists are not bullets', () {
    const t = '- one\n- [ ] task';
    expect(NoteMarkup.find(t).map((s) => s.kind), [
      MarkupKind.bullet,
      MarkupKind.checkbox,
    ]);
  });

  test('links keep their target for opening', () {
    final s = only('see [[n1|Loop]]', MarkupKind.link);
    expect(s.target, 'n1');
  });

  test('display text: what cards and search show', () {
    expect(
      NoteMarkup.display(
        'see [[n1|Time Loop]] and **this**\n- [ ] milk\n- [x] eggs\n- note',
      ),
      'see Time Loop and this\n☐ milk\n☑ eggs\n• note',
    );
    expect(NoteMarkup.display('[[Old Note]]'), 'Old Note');
  });
}
