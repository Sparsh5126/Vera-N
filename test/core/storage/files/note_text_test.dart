import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_text.dart';

void main() {
  test('title is the first non-empty line without heading marks', () {
    expect(NoteText.title('\n\n# Future Self\nMore'), 'Future Self');
    expect(NoteText.title('  2:17 AM  \nrest'), '2:17 AM');
    expect(NoteText.title('#tag is not a heading'), '#tag is not a heading');
    expect(NoteText.title('आज की बात\nतो'), 'आज की बात');
    expect(NoteText.title('   \n'), '');
  });

  test('preview is the text after the title line', () {
    expect(
      NoteText.preview('\n# Title\n\nFirst line\nSecond'),
      'First line\nSecond',
    );
    expect(NoteText.preview('Only a title'), '');
    expect(NoteText.preview(''), '');
  });

  test('content hash ignores line-ending style only', () {
    final lf = NoteText.contentHash('a\nb');
    expect(NoteText.contentHash('a\r\nb'), lf);
    expect(NoteText.contentHash('a\nb '), isNot(lf));
  });
}
