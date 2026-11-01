import '../../core/models/plate_inventory.dart';

// PURE DART. Plate maths in kilograms; comparisons in integer grams so lb
// plates (stored as kg) still match their targets.

/// Two weights closer than this many grams are the same weight.
const int kPlateToleranceGrams = 5;

/// Upper bound on distinct per-side sums the search keeps. Real inventories
/// stay far below it; it only guards a pathological one.
const int kPlateSearchLimit = 60000;

/// A loadable weight: the plates on ONE side (innermost first, largest first)
/// and the resulting total including the bar.
class PlateLoad {
  const PlateLoad({required this.perSide, required this.totalKg});

  final List<double> perSide;
  final double totalKg;

  @override
  bool operator ==(Object other) =>
      other is PlateLoad &&
      other.totalKg == totalKg &&
      _sameList(other.perSide, perSide);

  @override
  int get hashCode => Object.hash(totalKg, Object.hashAll(perSide));

  @override
  String toString() => 'PlateLoad($perSide per side, $totalKg kg)';
}

/// The answer for one target.
///
/// [exact] is true when the target is achievable; then [perSide] and
/// [achievedKg] describe it and [nearestBelow] / [nearestAbove] are null.
/// Otherwise [perSide] / [achievedKg] describe the closer of the two
/// neighbours (the lower on a tie), and each neighbour is null when it does
/// not exist (above the maximum load, or below the empty bar).
class PlateResult {
  const PlateResult({
    required this.exact,
    required this.perSide,
    required this.achievedKg,
    this.nearestBelow,
    this.nearestAbove,
  });

  final bool exact;
  final List<double> perSide;
  final double achievedKg;
  final PlateLoad? nearestBelow;
  final PlateLoad? nearestAbove;
}

/// The answer for a machine weight stack.
class StackSnap {
  const StackSnap({required this.exact, this.nearestBelow, this.nearestAbove});

  final bool exact;

  /// Exact: the target itself. Otherwise the multiple below, null under one
  /// step.
  final double? nearestBelow;

  /// Exact: the target itself. Otherwise the multiple above.
  final double? nearestAbove;
}

/// How the plates on one side change between two loads. All lists run in the
/// order the UI should animate them.
class PlateTransition {
  const PlateTransition({
    required this.kept,
    required this.exiting,
    required this.entering,
  });

  /// The common inner prefix. These never move.
  final List<double> kept;

  /// Plates leaving, outermost first.
  final List<double> exiting;

  /// Plates arriving, inside to out.
  final List<double> entering;
}

abstract final class PlateEngine {
  static int _grams(double kg) => (kg * 1000).round();

  /// Total bar plus both sides.
  static double totalFor(Bar bar, List<double> perSide) {
    double sum = 0;
    for (final double p in perSide) {
      sum += p;
    }
    return bar.weightKg + 2 * sum;
  }

  /// Solves one target.
  ///
  /// Barbells put `count ~/ 2` of each plate on a side. A dumbbell handle
  /// also has two sides; with [pair] (the default) two dumbbells share the
  /// inventory, so a side gets `count ~/ 4`.
  static PlateResult solve({
    required double targetKg,
    required Bar bar,
    required PlateInventory inventory,
    bool pair = true,
  }) {
    final int divisor = bar.isDumbbell && pair ? 4 : 2;
    final Map<int, int> available = <int, int>{};
    final Map<int, double> kgOf = <int, double>{};
    for (final PlateStock s in inventory.plates) {
      final int g = _grams(s.weightKg);
      final int n = s.count ~/ divisor;
      if (g <= 0 || n <= 0) continue;
      available[g] = (available[g] ?? 0) + n;
      kgOf.putIfAbsent(g, () => s.weightKg);
    }
    final List<int> weights = available.keys.toList()
      ..sort((int a, int b) => b.compareTo(a));

    final int barG = _grams(bar.weightKg);
    final int targetG = _grams(targetKg);
    final PlateLoad emptyBar = PlateLoad(
      perSide: const <double>[],
      totalKg: bar.weightKg,
    );

    if (targetG - barG < -kPlateToleranceGrams) {
      return PlateResult(
        exact: false,
        perSide: const <double>[],
        achievedKg: bar.weightKg,
        nearestAbove: emptyBar,
      );
    }

    // Reachable per-side sums (grams) -> plate counts per weight, in
    // `weights` order. On a tie the lexicographically larger count vector
    // wins, which is the greedy largest-first loading.
    Map<int, List<int>> reachable = <int, List<int>>{0: <int>[]};
    for (final int w in weights) {
      final int maxCount = available[w]!;
      final Map<int, List<int>> next = <int, List<int>>{};
      for (final MapEntry<int, List<int>> e in reachable.entries) {
        for (int k = 0; k <= maxCount; k++) {
          final int sum = e.key + k * w;
          final List<int> counts = <int>[...e.value, k];
          final List<int>? existing = next[sum];
          if (existing != null) {
            if (_lexGreater(counts, existing)) next[sum] = counts;
          } else if (next.length < kPlateSearchLimit) {
            next[sum] = counts;
          }
        }
      }
      reachable = next;
    }

    PlateLoad loadFor(int sum) {
      final List<int> counts = reachable[sum]!;
      final List<double> side = <double>[];
      for (int i = 0; i < weights.length; i++) {
        for (int c = 0; c < counts[i]; c++) {
          side.add(kgOf[weights[i]]!);
        }
      }
      return PlateLoad(perSide: side, totalKg: totalFor(bar, side));
    }

    int? exactSum;
    int? belowSum;
    int? aboveSum;
    int bestExactDiff = 1 << 30;
    for (final int sum in reachable.keys) {
      final int diff = barG + 2 * sum - targetG;
      if (diff.abs() <= kPlateToleranceGrams) {
        if (diff.abs() < bestExactDiff) {
          bestExactDiff = diff.abs();
          exactSum = sum;
        }
      } else if (diff < 0) {
        if (belowSum == null || sum > belowSum) belowSum = sum;
      } else {
        if (aboveSum == null || sum < aboveSum) aboveSum = sum;
      }
    }

    if (exactSum != null) {
      final PlateLoad l = loadFor(exactSum);
      return PlateResult(
        exact: true,
        perSide: l.perSide,
        achievedKg: l.totalKg,
      );
    }

    final PlateLoad? below = belowSum == null ? null : loadFor(belowSum);
    final PlateLoad? above = aboveSum == null ? null : loadFor(aboveSum);
    final PlateLoad? closer = switch ((below, above)) {
      (null, null) => null,
      (final PlateLoad b, null) => b,
      (null, final PlateLoad a) => a,
      (final PlateLoad b, final PlateLoad a) =>
        (targetKg - b.totalKg) <= (a.totalKg - targetKg) ? b : a,
    };
    return PlateResult(
      exact: false,
      perSide: closer?.perSide ?? const <double>[],
      achievedKg: closer?.totalKg ?? bar.weightKg,
      nearestBelow: below,
      nearestAbove: above,
    );
  }

  /// Machine stack: exact when [targetKg] is a multiple of [stepKg].
  static StackSnap snapToStack(double targetKg, double stepKg) {
    if (stepKg <= 0 || !targetKg.isFinite || targetKg <= 0) {
      return const StackSnap(exact: false);
    }
    final int stepG = _grams(stepKg);
    if (stepG <= 0) return const StackSnap(exact: false);
    final int targetG = _grams(targetKg);
    final int nearest = (targetG / stepG).round();
    if ((nearest * stepG - targetG).abs() <= kPlateToleranceGrams &&
        nearest > 0) {
      final double v = nearest * stepKg;
      return StackSnap(exact: true, nearestBelow: v, nearestAbove: v);
    }
    final int floor = targetG ~/ stepG;
    return StackSnap(
      exact: false,
      nearestBelow: floor >= 1 ? floor * stepKg : null,
      nearestAbove: (floor + 1) * stepKg,
    );
  }

  /// Plates are listed inside to out. [kept] is the common prefix.
  static PlateTransition transition(
    List<double> fromSide,
    List<double> toSide,
  ) {
    int common = 0;
    while (common < fromSide.length &&
        common < toSide.length &&
        _grams(fromSide[common]) == _grams(toSide[common])) {
      common++;
    }
    return PlateTransition(
      kept: List<double>.unmodifiable(fromSide.sublist(0, common)),
      exiting: List<double>.unmodifiable(
        fromSide.sublist(common).reversed.toList(),
      ),
      entering: List<double>.unmodifiable(toSide.sublist(common)),
    );
  }

  static bool _lexGreater(List<int> a, List<int> b) {
    for (int i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) return a[i] > b[i];
    }
    return false;
  }
}

bool _sameList(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
