import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/ai/chunking/note_chunker.dart';

int words(String text) => RegExp(r'\S+').allMatches(text).length;

void main() {
  test('a short note is one chunk', () {
    const body = 'Time loop\nWhat if every day repeats. I would learn piano.';
    final chunks = NoteChunker.split(body, words, maxTokens: 50);
    expect(chunks, hasLength(1));
    expect(chunks.single.start, 0);
    expect(chunks.single.end, body.length);
  });

  test('long notes split between sentences, within the token limit', () {
    final body = List.filled(10, 'one two three four five.').join(' ');
    final chunks = NoteChunker.split(body, words, maxTokens: 12);
    expect(chunks.length, greaterThan(1));
    for (final c in chunks) {
      expect(words(c.text), lessThanOrEqualTo(12));
      expect(c.text, endsWith('.'));
      expect(body.substring(c.start, c.end).trim(), c.text);
    }
  });

  test('a sentence longer than the limit is cut at words', () {
    final body = List.filled(30, 'word').join(' ');
    final chunks = NoteChunker.split(body, words, maxTokens: 8);
    expect(
      chunks.map((c) => words(c.text)),
      everyElement(lessThanOrEqualTo(8)),
    );
    expect(chunks.map((c) => words(c.text)).reduce((a, b) => a + b), 30);
  });

  test('the Linked notes footer is left out', () {
    const body =
        'Time loop\nWhat if every day repeats. I would learn piano.\n\n'
        '## Linked notes\n'
        '- [[20261003-153228-a7f3|Shopping list for Sunday]]\n'
        '- [[20261004-101010-b8e2|Morning routine plan]]\n';
    final chunks = NoteChunker.split(body, words, maxTokens: 50);
    final text = chunks.map((c) => c.text).join(' ');
    expect(text, contains('piano'));
    expect(text, isNot(contains('Linked notes')));
    expect(text, isNot(contains('Shopping')));
    expect(text, isNot(contains('Morning')));
    for (final c in chunks) {
      expect(c.end, lessThanOrEqualTo(body.indexOf('## Linked notes')));
    }
  });

  test('chunks hold the text as read: links as titles, no symbols', () {
    const body = '- [ ] buy **milk**, see [[20261003-153228-a7f3|Shopping]]';
    final chunk = NoteChunker.split(body, words, maxTokens: 50).single;
    expect(chunk.text, '☐ buy milk, see Shopping');
  });

  test('Hindi sentences end at the danda', () {
    const body = 'आज बारिश हुई। कल धूप होगी। हम पार्क जाएंगे।';
    final chunks = NoteChunker.split(body, words, maxTokens: 3);
    expect(chunks.map((c) => c.text), [
      'आज बारिश हुई।',
      'कल धूप होगी।',
      'हम पार्क जाएंगे।',
    ]);
  });

  test('empty and blank notes have no chunks', () {
    expect(NoteChunker.split('', words, maxTokens: 10), isEmpty);
    expect(NoteChunker.split('\n\n  \n', words, maxTokens: 10), isEmpty);
  });

  group('paragraphs', () {
    // Twelve words: enough to stand alone (minParagraphTokens).
    const trek =
        'We fixed the trek dates for December with five friends from the hostel.';
    const money =
        'The budget per person is nine thousand rupees plus train tickets and food.';

    test('each paragraph starts its own chunk, even with room left', () {
      const body = '$trek\n\n$money';
      final chunks = NoteChunker.split(body, words, maxTokens: 126);
      expect(chunks.map((c) => c.text), [trek, money]);
    });

    test('a short title or date stays with the paragraph after it', () {
      const body = 'Tuesday\n\n$trek\n\n$money';
      final chunks = NoteChunker.split(body, words, maxTokens: 126);
      expect(chunks, hasLength(2));
      expect(chunks.first.text, startsWith('Tuesday'));
      expect(chunks.first.text, endsWith(trek));
    });

    test('a heading starts a new chunk', () {
      const body = '$trek\n# Money\n$money';
      final chunks = NoteChunker.split(body, words, maxTokens: 126);
      expect(chunks, hasLength(2));
      expect(chunks.first.text, trek);
      expect(chunks.last.text, contains(money));
    });

    test('one Enter is enough: each line starts its own chunk', () {
      const body = '$trek\n$money';
      final chunks = NoteChunker.split(body, words, maxTokens: 126);
      expect(chunks.map((c) => c.text), [trek, money]);
    });

    test('the items of a list stay together', () {
      for (final item in ['- ', '- [ ] ', '1. ']) {
        final body = List.filled(
          6,
          '${item}buy milk eggs bread rice',
        ).join('\n');
        final chunks = NoteChunker.split(body, words, maxTokens: 126);
        expect(chunks, hasLength(1), reason: item);
      }
    });

    test('a list after a line of text is a chunk of its own', () {
      final list = List.filled(3, '- buy milk eggs bread rice').join('\n');
      final chunks = NoteChunker.split('$trek\n$list', words, maxTokens: 126);
      expect(chunks, hasLength(2));
      expect(chunks.first.text, trek);
    });
  });
}
