import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/plate_inventory.dart';
import 'package:sinew/core/units/units.dart';
import 'package:sinew/engines/plates/plates.dart';

const Bar _olympic = Bar(name: 'Olympic bar', weightKg: 20);
const Bar _handle = Bar(name: 'Handle', weightKg: 2, isDumbbell: true);

PlateInventory _inv(Map<double, int> stock) => PlateInventory(
  plates: <PlateStock>[
    for (final MapEntry<double, int> e in stock.entries)
      PlateStock(weightKg: e.key, count: e.value),
  ],
);

/// The metric default without the 15 kg pair, i.e. the usual gym set.
final PlateInventory _noFifteens = PlateInventory(
  plates: <PlateStock>[
    for (final PlateStock s in PlateInventory.metricDefault.plates)
      if (s.weightKg != 15) s,
  ],
);

PlateResult _solve(
  double target, {
  Bar bar = _olympic,
  PlateInventory? inv,
  bool pair = true,
}) => PlateEngine.solve(
  targetKg: target,
  bar: bar,
  inventory: inv ?? PlateInventory.metricDefault,
  pair: pair,
);

void main() {
  group('barbell', () {
    test('100 kg on a 20 kg bar is 25, 10, 5 per side (no 15s owned)', () {
      final PlateResult r = _solve(100, inv: _noFifteens);
      expect(r.exact, isTrue);
      expect(r.perSide, <double>[25, 10, 5]);
      expect(r.achievedKg, 100);
      expect(r.nearestBelow, isNull);
      expect(r.nearestAbove, isNull);
    });

    test('100 kg with the default inventory is greedy: 25, 15', () {
      // The default owns one pair of 15s, and greedy largest-first uses it.
      final PlateResult r = _solve(100);
      expect(r.exact, isTrue);
      expect(r.perSide, <double>[25, 15]);
    });

    test('102.5 kg is 25, 10, 5, 1.25 per side (no 15s owned)', () {
      final PlateResult r = _solve(102.5, inv: _noFifteens);
      expect(r.exact, isTrue);
      expect(r.perSide, <double>[25, 10, 5, 1.25]);
      expect(r.achievedKg, closeTo(102.5, 1e-9));
    });

    test('the empty bar is an exact load', () {
      final PlateResult r = _solve(20);
      expect(r.exact, isTrue);
      expect(r.perSide, isEmpty);
    });

    test('61 kg is not exact: below 60, above 62.5', () {
      final PlateResult r = _solve(61);
      expect(r.exact, isFalse);
      expect(r.nearestBelow!.totalKg, closeTo(60, 1e-9));
      expect(r.nearestAbove!.totalKg, closeTo(62.5, 1e-9));
      expect(r.nearestAbove!.perSide, <double>[20, 1.25]);
      // 60 is 1 away, 62.5 is 1.5 away: the closer one is described.
      expect(r.achievedKg, closeTo(60, 1e-9));
      expect(r.perSide, r.nearestBelow!.perSide);
    });

    test('count limits are respected: only 2 x 25 kg', () {
      final PlateInventory inv = _inv(<double, int>{25: 2});
      // 120 kg needs 50 kg a side but only one 25 fits on each side.
      final PlateResult r = _solve(120, inv: inv);
      expect(r.exact, isFalse);
      expect(r.nearestBelow!.perSide, <double>[25]);
      expect(r.nearestBelow!.totalKg, 70);
      expect(r.nearestAbove, isNull);
    });

    test('an odd plate count leaves one unused', () {
      final PlateInventory inv = _inv(<double, int>{10: 3});
      final PlateResult r = _solve(60, inv: inv);
      // 3 plates -> 1 per side -> max 40 kg.
      expect(r.exact, isFalse);
      expect(r.nearestBelow!.totalKg, 40);
    });

    test('bounded search finds a combination greedy cannot', () {
      // Side wants 40: greedy takes 25 and is stuck at 15 left, but 20+20 works.
      final PlateInventory inv = _inv(<double, int>{25: 2, 20: 4});
      final PlateResult r = _solve(100, inv: inv);
      expect(r.exact, isTrue);
      expect(r.perSide, <double>[20, 20]);
    });

    test('prefers more large plates when several combinations work', () {
      final PlateInventory inv = _inv(<double, int>{20: 4, 10: 4});
      final PlateResult r = _solve(80, inv: inv); // side 30
      expect(r.perSide, <double>[20, 10]);
    });

    test('target below the bar: nearest above is the empty bar', () {
      final PlateResult r = _solve(15);
      expect(r.exact, isFalse);
      expect(r.nearestBelow, isNull);
      expect(r.nearestAbove!.perSide, isEmpty);
      expect(r.nearestAbove!.totalKg, 20);
      expect(r.achievedKg, 20);
    });

    test('target above the maximum: only a nearest below', () {
      final PlateInventory inv = _inv(<double, int>{20: 2, 5: 2});
      final PlateResult r = _solve(500, inv: inv);
      expect(r.exact, isFalse);
      expect(r.nearestAbove, isNull);
      expect(r.nearestBelow!.perSide, <double>[20, 5]);
      expect(r.nearestBelow!.totalKg, 70);
    });

    test('no plates at all', () {
      final PlateResult r = _solve(50, inv: _inv(<double, int>{}));
      expect(r.exact, isFalse);
      expect(r.nearestBelow!.totalKg, 20);
      expect(r.nearestAbove, isNull);
    });

    test('totalFor adds both sides to the bar', () {
      expect(PlateEngine.totalFor(_olympic, <double>[25, 10, 5]), 100);
      expect(PlateEngine.totalFor(_olympic, <double>[]), 20);
    });

    test('duplicate stock entries of one weight are merged', () {
      final PlateInventory inv = _inv(<double, int>{20: 2}).copyWith(
        plates: const <PlateStock>[
          PlateStock(weightKg: 20, count: 2),
          PlateStock(weightKg: 20, count: 2),
        ],
      );
      expect(_solve(100, inv: inv).perSide, <double>[20, 20]);
    });
  });

  group('pounds', () {
    const double lb = UnitFactors.kgPerLb;
    const PlateInventory inv = PlateInventory(
      unit: WeightUnit.lb,
      plates: <PlateStock>[
        PlateStock(weightKg: 45 * lb, count: 4),
        PlateStock(weightKg: 35 * lb, count: 2),
        PlateStock(weightKg: 25 * lb, count: 2),
        PlateStock(weightKg: 10 * lb, count: 4),
        PlateStock(weightKg: 5 * lb, count: 2),
        PlateStock(weightKg: 2.5 * lb, count: 2),
      ],
    );
    const Bar bar = Bar(name: '45 lb bar', weightKg: 45 * lb);

    test('225 lb on a 45 lb bar is two 45s a side', () {
      final PlateResult r = _solve(
        Units.toKg(225, WeightUnit.lb),
        bar: bar,
        inv: inv,
      );
      expect(r.exact, isTrue);
      expect(r.perSide.length, 2);
      for (final double p in r.perSide) {
        expect(Units.fromKg(p, WeightUnit.lb), closeTo(45, 1e-9));
      }
    });

    test('135 lb is one 45 a side', () {
      final PlateResult r = _solve(
        Units.toKg(135, WeightUnit.lb),
        bar: bar,
        inv: inv,
      );
      expect(r.exact, isTrue);
      expect(r.perSide.length, 1);
    });

    test('a lb load with small plates still matches within tolerance', () {
      // 45 bar + 2 x (45 + 25 + 10 + 5 + 2.5) = 45 + 175 = 220 lb.
      final PlateResult r = _solve(
        Units.toKg(220, WeightUnit.lb),
        bar: bar,
        inv: inv,
      );
      expect(r.exact, isTrue);
      expect(r.perSide.length, 4); // greedy: 45, 35, 5, 2.5
    });
  });

  group('dumbbells', () {
    test('a pair shares the inventory: count ~/ 4 per handle side', () {
      // 25 kg: 2 plates -> 0 for a pair. 20: 4 -> 1. 10: 4 -> 1. 5: 4 -> 1.
      final PlateResult r = _solve(72, bar: _handle);
      expect(r.exact, isTrue);
      expect(r.perSide, <double>[20, 10, 5]);
      expect(r.achievedKg, 72);
    });

    test('pair mode cannot use a 25 kg plate that has only 2', () {
      final PlateResult r = _solve(82, bar: _handle);
      expect(r.exact, isFalse);
    });

    test('a single dumbbell (pair: false) can use it: count ~/ 2', () {
      final PlateResult r = _solve(52, bar: _handle, pair: false);
      expect(r.exact, isTrue);
      expect(r.perSide, <double>[25]);
    });

    test('pair flag does not affect barbells', () {
      expect(
        _solve(100, inv: _noFifteens, pair: true).perSide,
        _solve(100, inv: _noFifteens, pair: false).perSide,
      );
    });
  });

  group('machine stack', () {
    test('a multiple is exact', () {
      final StackSnap s = PlateEngine.snapToStack(45, 5);
      expect(s.exact, isTrue);
      expect(s.nearestBelow, 45);
      expect(s.nearestAbove, 45);
    });

    test('otherwise neighbours', () {
      final StackSnap s = PlateEngine.snapToStack(47, 5);
      expect(s.exact, isFalse);
      expect(s.nearestBelow, 45);
      expect(s.nearestAbove, 50);
    });

    test('under one step has no lower neighbour', () {
      final StackSnap s = PlateEngine.snapToStack(3, 5);
      expect(s.nearestBelow, isNull);
      expect(s.nearestAbove, 5);
    });

    test('fractional steps', () {
      final StackSnap s = PlateEngine.snapToStack(7.5, 2.5);
      expect(s.exact, isTrue);
      expect(PlateEngine.snapToStack(8, 2.5).nearestAbove, 10);
    });

    test('bad inputs never throw', () {
      expect(PlateEngine.snapToStack(50, 0).exact, isFalse);
      expect(PlateEngine.snapToStack(-5, 5).exact, isFalse);
    });
  });

  group('transition', () {
    test('kept is the common inner prefix, exiting is outermost first', () {
      final PlateTransition t = PlateEngine.transition(
        <double>[25, 10, 5, 1.25],
        <double>[25, 20],
      );
      expect(t.kept, <double>[25]);
      expect(t.exiting, <double>[1.25, 5, 10]);
      expect(t.entering, <double>[20]);
    });

    test('adding plates keeps everything', () {
      final PlateTransition t = PlateEngine.transition(
        <double>[20],
        <double>[20, 10, 5],
      );
      expect(t.kept, <double>[20]);
      expect(t.exiting, isEmpty);
      expect(t.entering, <double>[10, 5]);
    });

    test('identical loads move nothing', () {
      final PlateTransition t = PlateEngine.transition(
        <double>[25, 5],
        <double>[25, 5],
      );
      expect(t.kept, <double>[25, 5]);
      expect(t.exiting, isEmpty);
      expect(t.entering, isEmpty);
    });

    test('from empty and to empty', () {
      final PlateTransition up = PlateEngine.transition(<double>[], <double>[
        20,
        10,
      ]);
      expect(up.kept, isEmpty);
      expect(up.entering, <double>[20, 10]);
      final PlateTransition down = PlateEngine.transition(<double>[
        20,
        10,
      ], <double>[]);
      expect(down.exiting, <double>[10, 20]);
      expect(down.entering, isEmpty);
    });
  });
}
