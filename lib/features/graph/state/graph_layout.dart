import 'dart:math';

/// Where each dot sits, as fractions (0–1) of the graph's area.
typedef GraphPositions = Map<int, ({double x, double y})>;

/// A force layout (Fruchterman–Reingold): linked notes pull together, all
/// notes push apart, and a firm pull to the middle keeps separate groups
/// close. Pure and deterministic (the same notes and links always give
/// the same picture), so it runs in a background isolate and is cached.
abstract final class GraphLayout {
  static const _iterations = 300;
  static const _startHeat = 0.1;
  static const _gravity = 1.0;
  static const _margin = 0.06;

  static GraphPositions compute(List<int> nodes, List<(int, int)> edges) {
    final n = nodes.length;
    if (n == 0) return {};
    if (n == 1) return {nodes.first: (x: 0.5, y: 0.5)};
    final index = {for (var i = 0; i < n; i++) nodes[i]: i};
    final random = Random(n * 31 + edges.length);
    final x = List.generate(n, (_) => random.nextDouble());
    final y = List.generate(n, (_) => random.nextDouble());
    final k = sqrt(1 / n);
    final links = [
      for (final (a, b) in edges)
        if (index[a] != null && index[b] != null) (index[a]!, index[b]!),
    ];
    for (var step = 0; step < _iterations; step++) {
      final heat = _startHeat * (1 - step / _iterations);
      final dx = List.filled(n, 0.0);
      final dy = List.filled(n, 0.0);
      _repel(x, y, dx, dy, k);
      for (final (i, j) in links) {
        final ox = x[i] - x[j], oy = y[i] - y[j];
        final d = max(sqrt(ox * ox + oy * oy), 1e-4);
        final f = d * d / k;
        dx[i] -= ox / d * f;
        dy[i] -= oy / d * f;
        dx[j] += ox / d * f;
        dy[j] += oy / d * f;
      }
      for (var i = 0; i < n; i++) {
        dx[i] -= (x[i] - 0.5) * _gravity;
        dy[i] -= (y[i] - 0.5) * _gravity;
        final d = max(sqrt(dx[i] * dx[i] + dy[i] * dy[i]), 1e-9);
        final move = min(d, heat);
        x[i] += dx[i] / d * move;
        y[i] += dy[i] / d * move;
      }
    }
    return _fit(nodes, x, y);
  }

  static void _repel(
    List<double> x,
    List<double> y,
    List<double> dx,
    List<double> dy,
    double k,
  ) {
    final n = x.length;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final ox = x[i] - x[j], oy = y[i] - y[j];
        final d = max(sqrt(ox * ox + oy * oy), 1e-4);
        final f = k * k / d;
        dx[i] += ox / d * f;
        dy[i] += oy / d * f;
        dx[j] -= ox / d * f;
        dy[j] -= oy / d * f;
      }
    }
  }

  /// Scales the picture to fill 0–1, keeping its shape, with a margin.
  static GraphPositions _fit(List<int> nodes, List<double> x, List<double> y) {
    final minX = x.reduce(min), maxX = x.reduce(max);
    final minY = y.reduce(min), maxY = y.reduce(max);
    final span = max(max(maxX - minX, maxY - minY), 1e-9);
    final scale = (1 - 2 * _margin) / span;
    final padX = (1 - (maxX - minX) * scale) / 2;
    final padY = (1 - (maxY - minY) * scale) / 2;
    return {
      for (var i = 0; i < nodes.length; i++)
        nodes[i]: (
          x: padX + (x[i] - minX) * scale,
          y: padY + (y[i] - minY) * scale,
        ),
    };
  }
}
