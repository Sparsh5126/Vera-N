import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_document.dart';

void main() {
  void expectRoundTrip(String text) {
    expect(NoteDocument.parse(text).serialize(), text);
  }

  test('file with header', () {
    const text = '---\nid: a\ntags: [x]\n---\nHello\nworld\n';
    final doc = NoteDocument.parse(text);
    expect(doc.headerLines, ['id: a', 'tags: [x]']);
    expect(doc.body, 'Hello\nworld\n');
    expectRoundTrip(text);
  });

  test('file without header is all body', () {
    const text = 'Just a thought\n';
    final doc = NoteDocument.parse(text);
    expect(doc.hasHeader, isFalse);
    expect(doc.body, text);
    expectRoundTrip(text);
  });

  test('unclosed fence is not a header', () {
    const text = '---\nnot closed\nbody';
    expect(NoteDocument.parse(text).hasHeader, isFalse);
    expectRoundTrip(text);
  });

  test('Windows line endings round-trip', () {
    const text = '---\r\nid: a\r\n---\r\nLine one\r\nLine two';
    final doc = NoteDocument.parse(text);
    expect(doc.headerLines, ['id: a']);
    expect(doc.body, 'Line one\r\nLine two');
    expectRoundTrip(text);
  });

  test('empty header, empty file, header with no body', () {
    expectRoundTrip('---\n---\n');
    expectRoundTrip('');
    expectRoundTrip('---');
    expect(NoteDocument.parse('---\n---\n').headerLines, isEmpty);
  });

  test('Hindi and English body is kept exactly', () {
    const text = '---\nid: a\n---\nआज की बात — today\n';
    expect(NoteDocument.parse(text).body, 'आज की बात — today\n');
    expectRoundTrip(text);
  });
}
