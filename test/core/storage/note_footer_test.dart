import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_footer.dart';

void main() {
  const link = '[[20261001-090000-aaaa|Time Loop]]';
  const link2 = '[[20261002-090000-bbbb|Piano]]';

  test('starts the footer after the text, keeping the text as is', () {
    expect(
      NoteFooter.append('Idea\nSome words.\n\n', link),
      'Idea\nSome words.\n\n## Linked notes\n- $link\n',
    );
  });

  test('adds to an existing footer at the end', () {
    final once = NoteFooter.append('Idea', link);
    expect(
      NoteFooter.append(once, link2),
      'Idea\n\n## Linked notes\n- $link\n- $link2\n',
    );
  });

  test('a footer with text written after it starts a new one', () {
    final once = NoteFooter.append('Idea', link);
    final edited = '${once}More thoughts.';
    expect(
      NoteFooter.append(edited, link2),
      endsWith('## Linked notes\n- $link2\n'),
    );
    expect(NoteFooter.append(edited, link2), startsWith(edited));
  });
}
