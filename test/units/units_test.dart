import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/units/units.dart';

void main() {
  group('exact factors', () {
    test('1 lb is 0.45359237 kg; 100 kg is 220.462 lb', () {
      expect(Units.toKg(1, WeightUnit.lb), 0.45359237);
      expect(Units.fromKg(100, WeightUnit.lb), closeTo(220.462262, 1e-6));
    });

    test('1 in is 2.54 cm; 180 cm is 70.866 in', () {
      expect(Units.toCm(1, LengthUnit.inch), 2.54);
      expect(Units.fromCm(180, LengthUnit.inch), closeTo(70.866142, 1e-6));
    });

    test('1 mi is 1609.344 m; 5 km is 5000 m', () {
      expect(Units.toMetres(1, DistanceUnit.mi), 1609.344);
      expect(Units.toMetres(5, DistanceUnit.km), 5000);
      expect(Units.fromMetres(1609.344, DistanceUnit.mi), 1);
    });

    test('metric is the identity', () {
      expect(Units.toKg(82.5, WeightUnit.kg), 82.5);
      expect(Units.toCm(91.4, LengthUnit.cm), 91.4);
    });
  });

  group('round trips are lossless to 1e-9', () {
    for (final double v in <double>[0, 0.5, 1.25, 45, 82.5, 102.06, 315.7]) {
      test('$v', () {
        for (final WeightUnit u in WeightUnit.values) {
          expect(Units.fromKg(Units.toKg(v, u), u), closeTo(v, 1e-9));
        }
        for (final LengthUnit u in LengthUnit.values) {
          expect(Units.fromCm(Units.toCm(v, u), u), closeTo(v, 1e-9));
        }
        for (final DistanceUnit u in DistanceUnit.values) {
          expect(Units.fromMetres(Units.toMetres(v, u), u), closeTo(v, 1e-9));
        }
      });
    }
  });

  group('display', () {
    test('roundTo snaps to the step', () {
      expect(Units.roundTo(82.4, 0.5), 82.5);
      expect(Units.roundTo(82.2, 0.5), 82.0);
      expect(Units.roundTo(176.37, 1), 176);
    });

    test('trim drops trailing zeros and the dot', () {
      expect(Units.trim(80), '80');
      expect(Units.trim(82.5), '82.5');
      expect(Units.trim(82.25), '82.25');
      expect(Units.trim(82.256), '82.26');
      expect(Units.trim(82.04, maxDecimals: 1), '82');
    });

    test('formatters show the chosen unit', () {
      expect(Units.formatWeight(100, WeightUnit.kg), '100 kg');
      expect(Units.formatWeight(100, WeightUnit.lb), '220.5 lb');
      expect(Units.formatLength(2.54, LengthUnit.inch), '1 in');
      expect(Units.formatDistance(1609.344, DistanceUnit.mi), '1 mi');
    });
  });
}
