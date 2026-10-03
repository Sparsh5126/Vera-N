import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/features/note/state/link_markup.dart';

TextEditingValue at(String text, int cursor) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor),
);

void main() {
  const text = 'see [[n1|Loop]] now';
  // Offsets:     4 = start, 9 = label start, 13 = label end, 15 = end.

  test('finds the hidden and visible parts of each link', () {
    final l = LinkMarkup.find(text).single;
    expect([l.start, l.labelStart, l.labelEnd, l.end], [4, 9, 13, 15]);
    expect(text.substring(l.labelStart, l.labelEnd), 'Loop');
    final plain = LinkMarkup.find('[[Old Note]]').single;
    expect(
      '[[Old Note]]'.substring(plain.labelStart, plain.labelEnd),
      'Old Note',
    );
  });

  test('moving right steps over the hidden start and end', () {
    expect(
      LinkMarkup.protect(at(text, 4), at(text, 5)).selection.baseOffset,
      9,
    );
    expect(
      LinkMarkup.protect(at(text, 13), at(text, 14)).selection.baseOffset,
      15,
    );
  });

  test('moving left steps over them the other way', () {
    expect(
      LinkMarkup.protect(at(text, 15), at(text, 14)).selection.baseOffset,
      13,
    );
    expect(
      LinkMarkup.protect(at(text, 9), at(text, 8)).selection.baseOffset,
      4,
    );
  });

  test('backspace right after a link removes the whole link', () {
    final next = LinkMarkup.protect(at(text, 15), at('see [[n1|Loop] now', 14));
    expect(next.text, 'see  now');
    expect(next.selection.baseOffset, 4);
  });

  test('backspace at the start of the title removes the whole link', () {
    final next = LinkMarkup.protect(at(text, 9), at('see [[n1Loop]] now', 8));
    expect(next.text, 'see  now');
  });

  test('editing the visible title is allowed', () {
    final next = LinkMarkup.protect(at(text, 13), at('see [[n1|Loo]] now', 12));
    expect(next.text, 'see [[n1|Loo]] now');
  });

  test('ordinary typing and keyboard composing pass through', () {
    final typed = LinkMarkup.protect(at('ab', 2), at('abc', 3));
    expect(typed.text, 'abc');
    const composing = TextEditingValue(
      text: 'see [[n1|Loop] now',
      selection: TextSelection.collapsed(offset: 14),
      composing: TextRange(start: 10, end: 14),
    );
    expect(LinkMarkup.protect(at(text, 15), composing), composing);
  });
}
