import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/graph_data.dart';
import '../../../core/models/search_filters.dart';
import '../../../core/models/suggestion.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../core/storage/storage_providers.dart';
import 'graph_layout.dart';
import 'graph_view.dart';

/// What the Graph shows: the dots, links and where they sit.
@immutable
class GraphPicture {
  const GraphPicture({
    required this.all,
    required this.nodes,
    required this.edges,
    required this.suggested,
    required this.degrees,
    required this.positions,
    this.inFolder = false,
  });

  /// Every note the filters allow, shown or not (for the search jump).
  final Map<int, GraphNode> all;
  final Map<int, GraphNode> nodes;
  final List<GraphEdge> edges;

  /// Waiting suggestions between shown notes, as dashed lines.
  final List<Suggestion> suggested;
  final Map<int, int> degrees;
  final GraphPositions positions;

  /// A Folder filter is on: dots take the folder color (UI spec §10).
  final bool inFolder;

  bool get isEmpty => nodes.isEmpty;
}

final _graphDataProvider = StreamProvider.autoDispose
    .family<GraphData, SearchFilters>(
      (ref, filters) =>
          ref.watch(graphRepositoryProvider).watch(filters: filters),
    );

final _pendingProvider = StreamProvider.autoDispose<List<Suggestion>>(
  (ref) => ref.watch(storageProvider).suggestions.watchPending(),
);

/// The picture for the current data and choices. The layout uses the
/// confirmed links only, so showing suggestions never moves the dots. It
/// is computed once per set of notes and links and cached for the session.
final graphPictureProvider = FutureProvider.autoDispose<GraphPicture>((
  ref,
) async {
  final view = ref.watch(graphViewProvider);
  final data = await ref.watch(_graphDataProvider(view.filters).future);
  final pending = ref.watch(suggestionsOnProvider)
      ? [
          for (final s in await ref.watch(_pendingProvider.future))
            if (s.isLink) s,
        ]
      : const <Suggestion>[];
  final all = {for (final n in data.nodes) n.ref: n};
  final linked = data.edges.toSet();
  final suggested = [
    for (final s in pending)
      if (all.containsKey(s.noteA) &&
          all.containsKey(s.noteB) &&
          !linked.contains(GraphEdge.of(s.noteA, s.noteB)))
        s,
  ];
  final degrees = data.degrees;
  final visible = {
    for (final n in data.nodes)
      if (view.showUnlinked || degrees.containsKey(n.ref)) n.ref,
  };
  // Notes with suggestions are always placed, and drawn only while
  // suggestions are shown, so turning them on never moves the dots.
  var placed = {
    ...visible,
    for (final s in suggested) ...[s.noteA, s.noteB],
  };
  final focus = view.focus;
  if (focus != null && all.containsKey(focus)) {
    placed = _near(
      focus,
      view.hops,
      data.edges,
    ).intersection({...placed, focus});
  }
  final shown = view.showSuggestions
      ? placed
      : placed.intersection({...visible, ?focus});
  final edges = [
    for (final e in data.edges)
      if (shown.contains(e.a) && shown.contains(e.b)) e,
  ];
  final ids = placed.toList()..sort();
  final layoutEdges = [
    for (final e in data.edges)
      if (placed.contains(e.a) && placed.contains(e.b)) e,
  ];
  final pairs = [for (final e in layoutEdges) (e.a, e.b)];
  final key =
      '${ids.join(',')}|${pairs.map((p) => '${p.$1}-${p.$2}').join(',')}';
  final positions = _cache.remove(key) ?? await _layout(ids, pairs);
  // Most recent last; only a few are kept.
  _cache[key] = positions;
  if (_cache.length > _cacheSize) _cache.remove(_cache.keys.first);
  return GraphPicture(
    all: all,
    nodes: {
      for (final id in ids)
        if (shown.contains(id)) id: all[id]!,
    },
    edges: edges,
    suggested: [
      if (view.showSuggestions)
        for (final s in suggested)
          if (shown.contains(s.noteA) && shown.contains(s.noteB)) s,
    ],
    degrees: degrees,
    positions: positions,
    inFolder: view.filters.folder != null,
  );
});

/// [start] and every note up to [hops] confirmed links away.
Set<int> _near(int start, int hops, List<GraphEdge> edges) {
  final next = <int, List<int>>{};
  for (final e in edges) {
    (next[e.a] ??= []).add(e.b);
    (next[e.b] ??= []).add(e.a);
  }
  final seen = {start};
  var ring = [start];
  for (var i = 0; i < hops && ring.isNotEmpty; i++) {
    ring = [
      for (final n in ring)
        for (final m in next[n] ?? const <int>[])
          if (seen.add(m)) m,
    ];
  }
  return seen;
}

/// Small graphs take a few milliseconds, so they are laid out in place;
/// larger ones in a background isolate, keeping scrolling smooth.
Future<GraphPositions> _layout(List<int> ids, List<(int, int)> pairs) async {
  if (ids.length <= _inPlaceNodes) return GraphLayout.compute(ids, pairs);
  return Isolate.run<GraphPositions>(() => GraphLayout.compute(ids, pairs));
}

const _inPlaceNodes = 30;

/// Layouts already computed this session, by notes-and-links key.
final _cache = <String, GraphPositions>{};
const _cacheSize = 4;
