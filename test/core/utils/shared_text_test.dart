import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/web_link.dart';
import 'package:vera_n/core/utils/shared_text.dart';

WebLink? linkOf(String? body) => WebLink.parse(body!.split('\n').first);

void main() {
  test('a browser share: the subject is the title', () {
    final body = SharedText.toNoteBody(
      text: 'https://ex.com/a',
      subject: 'Octopus dreams',
    );
    expect(body, '[Octopus dreams](https://ex.com/a)\n');
  });

  test('words around the link become title and description', () {
    final body = SharedText.toNoteBody(
      text:
          'Why octopuses dream\nA study of sleep in cephalopods. '
          'https://ex.com/a',
    );
    final link = linkOf(body)!;
    expect(link.title, 'Why octopuses dream');
    expect(link.description, 'A study of sleep in cephalopods.');
  });

  test('a subject plus extra text: the text is the description', () {
    final link = linkOf(
      SharedText.toNoteBody(
        text: 'Check this out https://ex.com/a',
        subject: 'Octopus dreams',
      ),
    )!;
    expect(link.title, 'Octopus dreams');
    expect(link.description, 'Check this out');
  });

  test('only a link: a bare line, labelled offline', () {
    expect(
      SharedText.toNoteBody(text: 'https://ex.com/a'),
      'https://ex.com/a\n',
    );
  });

  test('the body ends on an empty line for the user to type on', () {
    expect(SharedText.toNoteBody(text: 'https://ex.com/a'), endsWith('\n'));
  });

  test('text without a link is kept as it is', () {
    expect(SharedText.toNoteBody(text: 'Buy milk'), 'Buy milk\n');
    expect(
      SharedText.toNoteBody(text: 'Buy milk', subject: 'List'),
      'List\nBuy milk\n',
    );
  });

  test('nothing shared gives no note', () {
    expect(SharedText.toNoteBody(), isNull);
    expect(SharedText.toNoteBody(text: '  ', subject: ''), isNull);
  });

  test('very long descriptions are cut', () {
    final link = linkOf(
      SharedText.toNoteBody(
        text: 'https://ex.com/a ${'word ' * 200}',
        subject: 'T',
      ),
    )!;
    expect(link.description!.length, lessThanOrEqualTo(300));
    expect(link.description, endsWith('…'));
  });
}
