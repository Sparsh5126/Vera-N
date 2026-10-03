import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/features/note/state/link_typing.dart';

TextEditingValue at(String text, [int? cursor]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor ?? text.length),
);

void main() {
  test('opens only on a freshly typed [[', () {
    expect(LinkTyping.justOpened('See [', at('See [[')), isTrue);
    expect(LinkTyping.justOpened('ab', at('a[[b', 3)), isFalse);
    expect(LinkTyping.justOpened('See [[x', at('See [[')), isFalse);
    expect(LinkTyping.justOpened('', at('[[')), isFalse);
    const composing = TextEditingValue(
      text: 'x[[',
      selection: TextSelection.collapsed(offset: 3),
      composing: TextRange(start: 0, end: 3),
    );
    expect(LinkTyping.justOpened('x[', composing), isFalse);
  });

  test('inserting replaces the [[ and puts the cursor after the link', () {
    final v = LinkTyping.insert(at('See [[ now', 6), '[[n1|Loop]]');
    expect(v.text, 'See [[n1|Loop]] now');
    expect(v.selection.baseOffset, 'See [[n1|Loop]]'.length);
  });

  test('inserting without a [[ before the cursor just adds the link', () {
    final v = LinkTyping.insert(at('See '), '[[n1]]');
    expect(v.text, 'See [[n1]]');
  });
}
