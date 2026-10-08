import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/features/note/state/markdown_format.dart';

TextEditingValue sel(String text, int start, int end) => TextEditingValue(
  text: text,
  selection: TextSelection(baseOffset: start, extentOffset: end),
);

void main() {
  group('bold', () {
    test('wraps the selection and keeps it selected', () {
      final v = MarkdownFormat.toggleBold(sel('a big idea', 2, 5));
      expect(v.text, 'a **big** idea');
      expect(v.text.substring(v.selection.start, v.selection.end), 'big');
    });

    test('a second tap unwraps it', () {
      final once = MarkdownFormat.toggleBold(sel('a big idea', 2, 5));
      expect(MarkdownFormat.toggleBold(once).text, 'a big idea');
    });

    test('nothing selected between words: nothing happens', () {
      final v = sel('ab  cd', 3, 3);
      expect(MarkdownFormat.toggleBold(v).text, 'ab  cd');
    });

    test('Hindi text', () {
      final v = MarkdownFormat.toggleBold(sel('यह कहानी है', 3, 8));
      expect(v.text, 'यह **कहानी** है');
    });
  });

  group('bold at the cursor', () {
    test('the word the cursor is in, Hindi too; nothing between words', () {
      final v = MarkdownFormat.toggleBold(sel('a big idea', 3, 3));
      expect(v.text, 'a **big** idea');
      expect(v.selection.isCollapsed, isTrue);
      final hindi = MarkdownFormat.toggleBold(sel('आज की बात', 1, 1));
      expect(hindi.text, '**आज** की बात');
      final gap = MarkdownFormat.toggleBold(sel('a  b', 2, 2));
      expect(gap.text, 'a  b');
    });
  });

  group('lines', () {
    const text = 'Title\nmilk\n\nbread\nend';
    // Select from inside "milk" to inside "bread".
    final block = sel(text, 7, 15);

    test('list marks every non-empty selected line', () {
      final v = MarkdownFormat.toggleLines(block, LineMark.list);
      expect(v.text, 'Title\n- milk\n\n- bread\nend');
    });

    test('toggling again removes the marks', () {
      final once = MarkdownFormat.toggleLines(block, LineMark.list);
      final twice = MarkdownFormat.toggleLines(once, LineMark.list);
      expect(twice.text, text);
    });

    test('a list becomes a checklist instead of getting both', () {
      final list = MarkdownFormat.toggleLines(block, LineMark.list);
      final check = MarkdownFormat.toggleLines(list, LineMark.checklist);
      expect(check.text, 'Title\n- [ ] milk\n\n- [ ] bread\nend');
      final back = MarkdownFormat.toggleLines(check, LineMark.list);
      expect(back.text, 'Title\n- milk\n\n- bread\nend');
    });

    test('done items count as checklist lines', () {
      final v = sel('- [x] done\n- [ ] todo', 0, 20);
      expect(
        MarkdownFormat.toggleLines(v, LineMark.checklist).text,
        'done\ntodo',
      );
    });

    test('works with just a cursor on one line', () {
      final v = MarkdownFormat.toggleLines(sel('a\nb\nc', 2, 2), LineMark.list);
      expect(v.text, 'a\n- b\nc');
    });
  });

  test('replacing the selection with a link', () {
    final v = MarkdownFormat.replaceSelection(
      sel('see that', 4, 8),
      '[[n1|that]]',
    );
    expect(v.text, 'see [[n1|that]]');
    expect(v.selection.baseOffset, v.text.length);
  });
}
