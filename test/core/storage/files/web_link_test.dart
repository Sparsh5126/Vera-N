import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_markup.dart';
import 'package:vera_n/core/storage/files/web_link.dart';

void main() {
  group('parse', () {
    test('a titled link with a description', () {
      final l = WebLink.parse(
        '[Octopus dreams](https://ex.com/a "Sleep, colour")',
      );
      expect(l?.url, 'https://ex.com/a');
      expect(l?.title, 'Octopus dreams');
      expect(l?.description, 'Sleep, colour');
    });

    test('a bare link; anything else on the line is not a card', () {
      expect(WebLink.parse('https://ex.com/a')?.url, 'https://ex.com/a');
      expect(WebLink.parse('see https://ex.com/a'), isNull);
      expect(WebLink.parse('https://ex.com/a and more'), isNull);
      expect(WebLink.parse('ftp://ex.com/a'), isNull);
    });

    test('Markdown round-trips titles and descriptions with symbols', () {
      const link = WebLink(
        url: 'https://en.wikipedia.org/wiki/Mercury_(planet)',
        title: 'Notes [draft] \\ ideas',
        description: 'He said "hi"',
      );
      final back = WebLink.parse(link.markdown)!;
      expect(back.title, link.title);
      expect(back.description, link.description);
      expect(back.url, 'https://en.wikipedia.org/wiki/Mercury_%28planet%29');
    });

    test('Hindi titles are kept', () {
      const link = WebLink(url: 'https://ex.in/x', title: 'सपनों की बातें');
      expect(WebLink.parse(link.markdown)?.title, 'सपनों की बातें');
    });
  });

  group('label and site (offline)', () {
    test('the site drops www and m', () {
      expect(
        const WebLink(url: 'https://www.youtube.com/watch?v=1').site,
        'youtube.com',
      );
      expect(
        const WebLink(url: 'https://m.wikipedia.org/x').site,
        'wikipedia.org',
      );
    });

    test('words from the address when there is no title', () {
      expect(
        const WebLink(url: 'https://ex.com/blog/how-octopuses-dream.html')
            .label,
        'How octopuses dream',
      );
    });

    test('ids and short paths fall back to the site', () {
      expect(
        const WebLink(url: 'https://youtu.be/dQw4w9WgXcQ').label,
        'youtu.be',
      );
      expect(
        const WebLink(url: 'https://ex.com/p/a8f3k29x-77b1c2d9').label,
        'ex.com',
      );
      expect(const WebLink(url: 'https://ex.com/').label, 'ex.com');
    });

    test('findUrl drops trailing punctuation', () {
      expect(WebLink.findUrl('look (https://ex.com/a).'), 'https://ex.com/a');
      expect(WebLink.findUrl('no link here'), isNull);
    });
  });

  group('in a note', () {
    const body = 'Reading list\n[Octopus dreams](https://ex.com/a)\nlater';

    test('a link line is one block span', () {
      final spans = NoteMarkup.find(body)
          .where((s) => s.kind == MarkupKind.webLink)
          .toList();
      expect(spans, hasLength(1));
      expect(spans.single.isBlock, isTrue);
      expect(spans.single.target, 'https://ex.com/a');
      expect(
        body.substring(spans.single.start, spans.single.end),
        '[Octopus dreams](https://ex.com/a)',
      );
    });

    test('readers and the AI see the title; copies keep the address', () {
      expect(NoteMarkup.display(body), 'Reading list\nOctopus dreams\nlater');
      expect(
        NoteMarkup.display(body, keepUrls: true),
        'Reading list\nOctopus dreams\nhttps://ex.com/a\nlater',
      );
    });

    test('a bare link line is a block span too', () {
      const t = 'Later\nhttps://ex.com/a';
      final span = NoteMarkup.find(t)
          .singleWhere((s) => s.kind == MarkupKind.webLink);
      expect(span.target, 'https://ex.com/a');
      expect(span.start, 6);
      expect(span.end, t.length);
    });

    test('a link inside a sentence stays text', () {
      const t = 'read https://ex.com/a today';
      expect(
        NoteMarkup.find(t).where((s) => s.kind == MarkupKind.webLink),
        isEmpty,
      );
      expect(NoteMarkup.display(t), t);
    });
  });
}
