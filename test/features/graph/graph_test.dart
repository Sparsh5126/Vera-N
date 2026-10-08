import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/graph_data.dart';
import 'package:vera_n/core/models/suggestion_draft.dart';
import 'package:vera_n/core/storage/repositories/graph_repository.dart';
import 'package:vera_n/features/graph/state/graph_layout.dart';

import '../../support/app_harness.dart';
import '../../support/storage_harness.dart';

void main() {
  group('GraphRepository', () {
    late StorageHarness h;
    setUp(() => h = StorageHarness());
    tearDown(() => h.dispose());

    Future<String> nameOf(int ref) async =>
        (await h.row(ref)).path.split('/').last.replaceAll('.md', '');

    test(
      'one edge per linked pair, either direction; trash left out',
      () async {
        final a = await h.repo.create('Alpha');
        final b = await h.repo.create('Beta');
        final c = await h.repo.create('Gamma');
        await h.repo.updateBody(a, 'Alpha\n[[${await nameOf(b)}]]');
        await h.repo.updateBody(
          b,
          'Beta\n[[${await nameOf(a)}]] [[${await nameOf(c)}]]',
        );
        final data = await GraphRepository(h.db).watch().first;
        expect(data.nodes, hasLength(3));
        expect(data.edges.toSet(), {GraphEdge(a, b), GraphEdge(b, c)});
        expect(data.degrees, {a: 1, b: 2, c: 1});

        await h.repo.trash(c);
        final after = await GraphRepository(h.db).watch().first;
        expect(after.edges, [GraphEdge(a, b)]);
      },
    );
  });

  group('GraphLayout', () {
    test('same input, same picture, inside the area', () {
      final edges = [(1, 2), (2, 3)];
      final one = GraphLayout.compute([1, 2, 3, 4], edges);
      final two = GraphLayout.compute([1, 2, 3, 4], edges);
      expect(one, two);
      for (final p in one.values) {
        expect(p.x, inInclusiveRange(0, 1));
        expect(p.y, inInclusiveRange(0, 1));
      }
    });
  });

  group('Graph screen', () {
    late AppHarness app;
    setUp(() => app = AppHarness());

    Future<void> openGraph(WidgetTester tester) async {
      await app.pump(tester);
      await tester.tap(find.bySemanticsLabel(AppCopy.navGraph).last);
      await tester.pumpAndSettle();
    }

    testWidgets('no links: the empty message', (tester) async {
      await app.storage.notes.create('Alone\nNo links here.');
      await openGraph(tester);
      expect(find.text(AppCopy.emptyGraph), findsOneWidget);
      await app.finish(tester);
    });

    testWidgets('tapping a dot shows its preview; Open opens it', (
      tester,
    ) async {
      final notes = app.storage.notes;
      final a = await notes.create('Alpha\nFirst note.');
      final b = await notes.create('Beta\nSecond note.');
      final path = (await notes.getNote(a))!.path;
      final name = path.split('/').last.replaceAll('.md', '');
      await notes.updateBody(b, 'Beta\nSee [[$name]].');
      final semantics = tester.ensureSemantics();
      await openGraph(tester);

      // Dots are drawn; the screen-reader item selects one.
      tester.semantics.tap(find.semantics.byLabel('Alpha, 1 link'));
      await tester.pumpAndSettle();
      expect(find.text('First note.'), findsOneWidget);
      await tester.tap(find.text(AppCopy.open));
      await tester.pumpAndSettle();
      expect(find.text(AppCopy.emptyGraph), findsNothing);
      expect(find.textContaining('First note.'), findsWidgets);
      semantics.dispose();
      await app.finish(tester);
    });

    /// Links [from] to [to] in [from]'s text.
    Future<void> link(int from, int to) async {
      final notes = app.storage.notes;
      final name = (await notes.getNote(to))!.path.split('/').last;
      final body = (await notes.getNote(from))!.body;
      await notes.updateBody(from, '$body\n[[${name.replaceAll('.md', '')}]]');
    }

    testWidgets('Focus shows the note and its near neighbours only', (
      tester,
    ) async {
      final notes = app.storage.notes;
      final a = await notes.create('Alpha\nOne.');
      final b = await notes.create('Beta\nTwo.');
      final c = await notes.create('Gamma\nThree.');
      await link(a, b);
      await link(b, c);
      final semantics = tester.ensureSemantics();
      await openGraph(tester);
      tester.semantics.tap(find.semantics.byLabel('Alpha, 1 link'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppCopy.focus));
      await tester.pumpAndSettle();
      expect(find.text(AppCopy.focusOn('Alpha')), findsOneWidget);
      expect(find.semantics.byLabel('Gamma, 1 link'), findsNothing);

      await tester.tap(find.text(AppCopy.hops(2)));
      await tester.pumpAndSettle();
      expect(find.semantics.byLabel('Gamma, 1 link'), findsOne);
      await tester.tap(find.text(AppCopy.focusOff));
      await tester.pumpAndSettle();
      expect(find.text(AppCopy.focusOn('Alpha')), findsNothing);
      semantics.dispose();
      await app.finish(tester);
    });

    testWidgets('Show suggestions: a dashed line opens the sheet', (
      tester,
    ) async {
      final notes = app.storage.notes;
      final a = await notes.create('Alpha\nOne.');
      final b = await notes.create('Beta\nTwo.');
      await app.storage.suggestions.add(
        [
          SuggestionDraft(
            kind: 'link',
            noteA: a,
            noteB: b,
            score: .7,
            chunkA: 0,
            chunkB: 0,
          ),
        ],
        DateTime.now(),
        const Duration(days: 30),
      );
      final semantics = tester.ensureSemantics();
      await openGraph(tester);
      expect(find.text(AppCopy.emptyGraph), findsOneWidget);

      await tester.tap(find.text(AppCopy.showSuggestions));
      await tester.pumpAndSettle();
      final line = find.semantics.byLabel(
        AppCopy.suggestedLinkBetween('Alpha', 'Beta'),
      );
      expect(line, findsOne);
      tester.semantics.tap(line);
      await tester.pumpAndSettle();
      expect(find.byTooltip(AppCopy.accept), findsOneWidget);
      semantics.dispose();
      await app.finish(tester);
    });
  });
}
