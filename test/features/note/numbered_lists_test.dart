import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/features/note/state/markdown_format.dart';
import 'package:vera_n/features/note/state/markup_editing.dart';
import 'package:vera_n/features/note/state/numbered_points.dart';

TextEditingValue at(String text, int cursor) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor),
);

TextEditingValue protect(TextEditingValue before, TextEditingValue after) =>
    MarkupEditing.protect(before, after);

void main() {
  group('typing (backlog #6)', () {
    test('numbered lines are found and stay visible', () {
      final s = NoteMarkup.find('1. milk').single;
      expect(s.kind, MarkupKind.numbered);
      expect(s.number, 1);
      expect(s.hides(0), isFalse);
      expect(s.blocksCaret(0), isFalse);
    });

    test('Enter after an item adds the next number', () {
      final v = protect(at('1. milk', 7), at('1. milk\n', 8));
      expect(v.text, '1. milk\n2. ');
      expect(v.selection.baseOffset, v.text.length);
    });

    test('Enter in the middle renumbers the items below', () {
      const t = '1. a\n2. b\n3. c';
      final v = protect(at(t, 4), at('1. a\n\n2. b\n3. c', 5));
      expect(v.text, '1. a\n2. \n3. b\n4. c');
      expect(v.selection.baseOffset, 8);
    });

    test('Enter on an empty item ends the list', () {
      final v = protect(at('1. a\n2. ', 8), at('1. a\n2. \n', 9));
      expect(v.text, '1. a\n');
    });

    test('backspace right after the number removes it; digits edit freely', () {
      expect(protect(at('3. milk', 3), at('3.milk', 2)).text, 'milk');
      expect(protect(at('13. milk', 1), at('3. milk', 0)).text, '3. milk');
    });

    test('renumbering stops at the end of the list', () {
      expect(
        MarkupEditing.renumberAfter('1. a\n5. b\nplain\n9. c', 0, 1),
        '1. a\n2. b\nplain\n9. c',
      );
    });
  });

  group('List button on numbered points (backlog #3)', () {
    test('points written on one line become one per line', () {
      expect(NumberedPoints.asList(['1. milk 2. eggs 3. bread']), [
        '1. milk',
        '2. eggs',
        '3. bread',
      ]);
    });

    test('text before the points stays; lines after become points', () {
      expect(NumberedPoints.asList(['Plan: 1. call 2. write', 'rest']), [
        'Plan:',
        '1. call',
        '2. write',
        '3. rest',
      ]);
    });

    test('numbers that do not count on are left alone', () {
      expect(NumberedPoints.asList(['1. costs 5. something 2. more']), [
        '1. costs 5. something',
        '2. more',
      ]);
    });

    test('no numbered points: not this rule', () {
      expect(NumberedPoints.asList(['milk', 'eggs']), isNull);
    });

    test('a numbered list loses its numbers (toggle)', () {
      expect(NumberedPoints.asList(['1. a', '2. b']), ['a', 'b']);
    });

    test('through the List button, Hindi included', () {
      const t = 'सूची: 1. दूध 2. अंडे';
      final v = MarkdownFormat.toggleLines(
        TextEditingValue(
          text: t,
          selection: const TextSelection(baseOffset: 0, extentOffset: t.length),
        ),
        LineMark.list,
      );
      expect(v.text, 'सूची:\n1. दूध\n2. अंडे');
    });
  });
}
