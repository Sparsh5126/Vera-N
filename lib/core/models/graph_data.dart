import 'package:flutter/foundation.dart';

/// A note in the graph: a dot, with its title and the start of its text
/// for the preview card.
@immutable
class GraphNode {
  const GraphNode({
    required this.ref,
    required this.title,
    required this.preview,
  });

  final int ref;
  final String title;
  final String preview;
}

/// A confirmed link between two notes, either direction ([a] < [b]).
@immutable
class GraphEdge {
  const GraphEdge(this.a, this.b);

  /// The edge between [x] and [y], in either order.
  factory GraphEdge.of(int x, int y) =>
      x < y ? GraphEdge(x, y) : GraphEdge(y, x);

  final int a;
  final int b;

  @override
  bool operator ==(Object other) =>
      other is GraphEdge && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(a, b);
}

/// Every note not in the trash, and the links the user confirmed.
@immutable
class GraphData {
  const GraphData({required this.nodes, required this.edges});

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  /// How many links each note has.
  Map<int, int> get degrees {
    final d = <int, int>{};
    for (final e in edges) {
      d[e.a] = (d[e.a] ?? 0) + 1;
      d[e.b] = (d[e.b] ?? 0) + 1;
    }
    return d;
  }
}
