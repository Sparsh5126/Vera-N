import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/models/note_header.dart';
import 'package:vera_n/core/storage/files/note_document.dart';
import 'package:vera_n/core/storage/files/note_header_codec.dart';

void main() {
  NoteHeader read(String text) =>
      NoteHeaderCodec.read(NoteDocument.parse(text));

  String write(String text, NoteHeader header) =>
      NoteHeaderCodec.write(NoteDocument.parse(text), header).serialize();

  group('read', () {
    test('all known fields', () {
      final h = read(
        '---\nid: 20261003-153228-a7f3\ncreated: 2026-10-03T15:32:28+05:30\n'
        'tags: [story, idea]\npinned: true\n---\nBody',
      );
      expect(h.id, '20261003-153228-a7f3');
      expect(h.created, DateTime.utc(2026, 10, 3, 10, 2, 28).toLocal());
      expect(h.tags, ['story', 'idea']);
      expect(h.pinned, isTrue);
    });

    test('block list, string list, and # prefixes', () {
      expect(read('---\ntags:\n  - a\n  - "#b"\n---\n').tags, ['a', 'b']);
      expect(read('---\ntags: "#a, b c"\n---\n').tags, ['a', 'b', 'c']);
    });

    test('no header or unreadable header gives empty fields', () {
      expect(read('Just text'), const NoteHeader());
      expect(read('---\n: : [\n---\nx'), const NoteHeader());
      expect(read('---\njust a line\n---\nx'), const NoteHeader());
    });
  });

  group('write', () {
    final created = DateTime(2026, 10, 3, 15, 32, 28);
    final created1 = NoteHeaderCodec.formatDate(created);

    test('new note gets a minimal header', () {
      final out = write('Hello', NoteHeader(id: 'n1', created: created));
      expect(out, '---\nid: n1\ncreated: $created1\n---\nHello');
    });

    test('adding a header to an imported note keeps its text', () {
      const body = 'Imported\n\nfrom Keep\n';
      final out = write(body, const NoteHeader(pinned: true));
      expect(out, '---\npinned: true\n---\n$body');
    });

    test('unknown fields keep their text and order', () {
      const text =
          '---\naliases:\n  - Loop\ntags:\n  - old\n  - older\n'
          'cssclass: wide\n---\nBody';
      final out = write(text, const NoteHeader(tags: ['new'], pinned: true));
      expect(
        out,
        '---\naliases:\n  - Loop\ntags: [new]\ncssclass: wide\n'
        'pinned: true\n---\nBody',
      );
    });

    test('unpinning a note that had pinned keeps the key', () {
      final out = write('---\npinned: true\n---\nB', const NoteHeader());
      expect(out, '---\npinned: false\n---\nB');
    });

    test('tags that need quotes are quoted; Hindi tags are not', () {
      final out = write('B', const NoteHeader(tags: ['a: b', 'कहानी']));
      expect(out, '---\ntags: ["a: b", कहानी]\n---\nB');
      expect(read(out).tags, ['a: b', 'कहानी']);
    });

    test('a leading --- block that is not a header stays in the body', () {
      const text = '---\njust a line\n---\nrest';
      final out = write(text, const NoteHeader(pinned: true));
      expect(out, '---\npinned: true\n---\n$text');
    });

    test('Windows line endings are kept', () {
      final out = write(
        '---\r\nid: a\r\n---\r\nB',
        const NoteHeader(id: 'a', pinned: true),
      );
      expect(out, '---\r\nid: a\r\npinned: true\r\n---\r\nB');
    });

    test('round trip through read', () {
      final h = NoteHeader(
        id: 'x',
        created: created,
        tags: const ['t'],
        pinned: true,
      );
      expect(read(write('B', h)), h);
    });
  });
}
