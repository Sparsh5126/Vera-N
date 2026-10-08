import 'package:flutter_test/flutter_test.dart';
import 'package:vera_n/core/copy/app_copy.dart';
import 'package:vera_n/core/models/graph_data.dart';
import 'package:vera_n/features/graph/state/graph_bubbles.dart';
import 'package:vera_n/features/graph/widgets/graph_bubble.dart';

import '../../support/app_harness.dart';

void main() {
  group('GraphBubbles.of', () {
    GraphNode note(int ref, String folder) =>
        GraphNode(ref: ref, title: '$ref', preview: '', folder: folder);

    test('one bubble per top-level folder, biggest first; a line where '
        'notes link across folders', () {
      final nodes = [
        note(1, 'Ideas'),
        note(2, 'Ideas/Story'),
        note(3, 'Ideas'),
        note(4, 'Work'),
        note(5, ''),
      ];
      final b = GraphBubbles.of(nodes, [
        const GraphEdge(1, 2), // inside Ideas: no line
        const GraphEdge(1, 4),
        const GraphEdge(3, 4), // same two folders: one line
        const GraphEdge(4, 5),
      ]);
      expect(
        [for (final x in b.bubbles) (x.folder, x.count)],
        [('Ideas', 3), ('Work', 1), ('', 1)],
      );
      expect(b.links, [(0, 1), (1, 2)]);
    });
  });

  group('Graph screen', () {
    late AppHarness app;
    setUp(() => app = AppHarness());

    Future<void> library() async {
      for (var i = 0; i <= GraphBubbles.above; i++) {
        await app.storage.notes.create(
          'Note $i',
          folder: i.isEven ? 'Ideas' : (i % 3 == 0 ? '' : 'Work/Plans'),
        );
      }
    }

    Future<void> openGraph(WidgetTester tester) async {
      await app.pump(tester);
      await tester.tap(find.bySemanticsLabel(AppCopy.navGraph).last);
      await tester.pumpAndSettle();
    }

    testWidgets('a very large library shows folder bubbles; tapping one '
        'shows that folder', (tester) async {
      await tester.runAsync(library);
      await openGraph(tester);
      expect(find.byType(GraphBubble), findsNWidgets(3));
      expect(find.text(AppCopy.noFolder), findsOneWidget);

      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      expect(find.byType(GraphBubble), findsNothing);
      // The Folder pill now names the folder.
      expect(find.text('Work'), findsOneWidget);
      await app.finish(tester);
    });

    testWidgets('a small library shows dots, not bubbles', (tester) async {
      await app.storage.notes.create('Only\nOne.', folder: 'Ideas');
      await openGraph(tester);
      expect(find.byType(GraphBubble), findsNothing);
      await app.finish(tester);
    });
  });
}
