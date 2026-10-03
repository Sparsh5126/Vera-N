import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/storage/files/note_links.dart';

void main() {
  test('finds plain, labelled, folder, heading and embed links', () {
    final links = NoteLinks.parse(
      'See [[20261003-153228-a7f3|Time Loop]] and [[Ideas/Old Note.md]].\n'
      'Also [[Causality#Part 2]], ![[sketch]] and [[time loop]].',
    );
    expect(links.map((l) => l.targetKey), [
      '20261003-153228-a7f3',
      'ideas/old note',
      'causality',
      'sketch',
      'time loop',
    ]);
    expect(links.first.label, 'Time Loop');
    expect(links[1].label, isNull);
  });

  test('repeats count once; empty and broken links are ignored', () {
    final links = NoteLinks.parse('[[a]] [[A|again]] [[ ]] [[x [[b]]');
    expect(links.map((l) => l.targetKey), ['a', 'b']);
  });

  test('Hindi names work', () {
    expect(NoteLinks.parse('[[कहानी]]').single.targetKey, 'कहानी');
  });

  test('name key is the file name without .md, lower case', () {
    expect(NoteLinks.nameKey('Ideas/Old Note.md'), 'old note');
    expect(
      NoteLinks.nameKey('20261003-153228-a7f3.md'),
      '20261003-153228-a7f3',
    );
  });

  test('writing a link: name, or folder path when ambiguous', () {
    expect(
      NoteLinks.write(
        'Ideas/20261003-153228-a7f3.md',
        'Time Loop',
        ambiguous: false,
      ),
      '[[20261003-153228-a7f3|Time Loop]]',
    );
    expect(
      NoteLinks.write('Ideas/idea.md', 'Idea', ambiguous: true),
      '[[Ideas/idea|Idea]]',
    );
    expect(NoteLinks.write('a.md', 'x | [y]', ambiguous: false), '[[a|x - y]]');
    expect(NoteLinks.write('a.md', '  ', ambiguous: false), '[[a]]');
  });

  test('long titles are cut to keep links short', () {
    final long = 'This whole first line is a long sentence about many things';
    final link = NoteLinks.write('a.md', long, ambiguous: false);
    final label = link.substring('[[a|'.length, link.length - 2);
    expect(label.characters.length, NoteLinks.labelMaxLength);
    expect(label, endsWith('…'));
  });

  test('display text shows link titles, or names without one', () {
    expect(
      NoteLinks.displayText('see [[n1|Time Loop]] and [[Old Note]] now'),
      'see Time Loop and Old Note now',
    );
    expect(NoteLinks.displayText('no links'), 'no links');
  });
}
