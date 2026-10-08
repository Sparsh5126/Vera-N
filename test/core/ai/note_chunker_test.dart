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
}
