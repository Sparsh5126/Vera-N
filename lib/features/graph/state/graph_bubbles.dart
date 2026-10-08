import 'package:flutter/foundation.dart';

import '../../../core/models/graph_data.dart';

/// One top-level folder of a very large library, drawn as a single bubble
/// sized by how many notes it holds (UI spec §10).
@immutable
class FolderBubble {
  const FolderBubble({required this.folder, required this.count});

  /// The top-level folder; '' for notes outside any folder.
  final String folder;
  final int count;
}

/// The bubbles view of a very large library: one bubble per top-level
/// folder, and a line between two bubbles when any of their notes link.
@immutable
class GraphBubbles {
  const GraphBubbles({required this.bubbles, required this.links});

  /// Past this many notes the whole-library Graph shows folder bubbles
  /// instead of dots, so it stays readable and quick to lay out.
  static const above = 200;

  /// Biggest first; a bubble's index is its id in the layout.
  final List<FolderBubble> bubbles;

  /// Pairs of bubble indexes (lower first) whose notes link.
  final List<(int, int)> links;

  factory GraphBubbles.of(List<GraphNode> nodes, List<GraphEdge> edges) {
    final counts = <String, int>{};
    for (final n in nodes) {
      counts[n.topFolder] = (counts[n.topFolder] ?? 0) + 1;
    }
    final bubbles = [
      for (final e in counts.entries)
        FolderBubble(folder: e.key, count: e.value),
    ]..sort((a, b) => b.count.compareTo(a.count));
    final index = {
      for (var i = 0; i < bubbles.length; i++) bubbles[i].folder: i,
    };
    final groupOf = {for (final n in nodes) n.ref: index[n.topFolder]!};
    final links = <(int, int)>{};
    for (final e in edges) {
      final a = groupOf[e.a], b = groupOf[e.b];
      if (a == null || b == null || a == b) continue;
      links.add(a < b ? (a, b) : (b, a));
    }
    return GraphBubbles(bubbles: bubbles, links: links.toList()..sort(_byPair));
  }

  static int _byPair((int, int) x, (int, int) y) =>
      x.$1 != y.$1 ? x.$1.compareTo(y.$1) : x.$2.compareTo(y.$2);
}
