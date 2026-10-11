import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/features/note/state/markup_editing.dart';

TextEditingValue at(String text, int cursor) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor),
);

int caret(TextEditingValue v) => v.selection.baseOffset;

TextEditingValue protect(TextEditingValue before, TextEditingValue after) =>
    MarkupEditing.protect(before, after);

void main() {
  group('links', () {
    const t = 'see [[n1|Loop]] now'; // link 4..15, title 9..13

    test('the cursor steps over hidden parts both ways', () {
      expect(caret(protect(at(t, 4), at(t, 5))), 9);
      expect(caret(protect(at(t, 13), at(t, 14))), 15);
      expect(caret(protect(at(t, 15), at(t, 14))), 13);
      expect(caret(protect(at(t, 9), at(t, 8))), 4);
    });

    test('backspace into a link removes it; editing the title is fine', () {
      expect(protect(at(t, 15), at('see [[n1|Loop] now', 14)).text, 'see  now');
      expect(protect(at(t, 9), at('see [[n1Loop]] now', 8)).text, 'see  now');
      expect(
        protect(at(t, 13), at('see [[n1|Loo]] now', 12)).text,
        'see [[n1|Loo]] now',
      );
    });

    test('a tap inside the title finds the link, its edges do not', () {
      expect(MarkupEditing.linkAt(t, 11)?.target, 'n1');
      expect(MarkupEditing.linkAt(t, 9), isNull);
      expect(MarkupEditing.linkAt(t, 13), isNull);
    });
  });

  group('bold', () {
    const t = 'a **big** idea'; // bold 2..9, words 4..7

    test('the cursor steps over the stars', () {
      expect(caret(protect(at(t, 2), at(t, 3))), 4);
      expect(caret(protect(at(t, 7), at(t, 8))), 9);
    });

    test('backspace after bold words removes the bold, keeps the words', () {
      final v = protect(at(t, 9), at('a **big* idea', 8));
      expect(v.text, 'a big idea');
      expect(caret(v), 5);
    });

    test('backspace at the start of bold words does the same', () {
      final v = protect(at(t, 4), at('a *big** idea', 3));
      expect(v.text, 'a big idea');
      expect(caret(v), 2);
    });
  });

  group('checklists and bullets', () {
    const t = 'Groceries\n- [ ] milk';
    // Line starts at 10, the item text "milk" at 16.

    test('the cursor never rests before the checkbox', () {
      expect(caret(protect(at(t, 9), at(t, 10))), 16);
      expect(caret(protect(at(t, 16), at(t, 15))), 9);
    });

    test('backspace at the start of an item removes the checkbox only', () {
      final v = protect(at(t, 16), at('Groceries\n- [ ]milk', 15));
      expect(v.text, 'Groceries\nmilk');
      expect(caret(v), 10);
    });

    test('Enter starts the next checklist item', () {
      final v = protect(at(t, 20), at('$t\n', 21));
      expect(v.text, 'Groceries\n- [ ] milk\n- [ ] ');
      expect(caret(v), v.text.length);
    });

    test('Enter on an empty item ends the list', () {
      const empty = 'Groceries\n- [ ] milk\n- [ ] ';
      final v = protect(
        at(empty, empty.length),
        at('$empty\n', empty.length + 1),
      );
      expect(v.text, 'Groceries\n- [ ] milk\n');
    });

    test('Enter after a bullet starts the next bullet', () {
      final v = protect(at('- one', 5), at('- one\n', 6));
      expect(v.text, '- one\n- ');
    });

    test('ticking and unticking', () {
      final span = NoteMarkup.find(t).single;
      final ticked = MarkupEditing.toggleCheckbox(at(t, 0), span);
      expect(ticked.text, 'Groceries\n- [x] milk');
      final again = MarkupEditing.toggleCheckbox(
        ticked,
        NoteMarkup.find(ticked.text).single,
      );
      expect(again.text, t);
    });
  });

  test('keyboard composing passes through untouched', () {
    const composing = TextEditingValue(
      text: 'a **big* idea',
      selection: TextSelection.collapsed(offset: 8),
      composing: TextRange(start: 4, end: 8),
    );
    expect(protect(at('a **big** idea', 9), composing), composing);
  });

  group('web link cards', () {
    const card = '[Dreams](https://ex.com/a)'; // 26 characters
    const t = 'Read\n$card\nlater'; // card 5..31

    test('backspace into the card removes the whole line', () {
      final after = t.replaceRange(30, 31, '');
      expect(protect(at(t, 31), at(after, 30)).text, 'Read\nlater');
    });

    test('backspace at the start of the next line removes it too', () {
      final after = t.replaceRange(31, 32, '');
      expect(protect(at(t, 32), at(after, 31)).text, 'Read\nlater');
    });

    test('the cursor never rests inside the card', () {
      expect(caret(protect(at(t, 5), at(t, 6))), 31);
      expect(caret(protect(at(t, 31), at(t, 30))), 5);
    });

    test('typing after a pasted link turns it back into text', () {
      const pasted = 'https://ex.com/a';
      final typed = protect(at(pasted, 16), at('$pasted x', 18));
      expect(typed.text, '$pasted x');
      expect(
        NoteMarkup.find(typed.text).where((s) => s.kind == MarkupKind.webLink),
        isEmpty,
      );
    });
  });
}
