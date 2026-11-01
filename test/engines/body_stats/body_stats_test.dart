import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/training.dart';
import 'package:sinew/core/units/units.dart';
import 'package:sinew/engines/body_stats/body_stats.dart';

final DateTime _now = DateTime(2026, 6, 1);

BodyStatsInput _in({
  double? weightKg,
  double? heightCm,
  double? waistCm,
  double? neckCm,
  double? hipsCm,
  double? bf,
  Sex? sex,
  int? birthYear,
  ActivityLevel? level,
  BmiCutoffs cutoffs = BmiCutoffs.who,
}) => BodyStatsInput(
  now: _now,
  weightKg: weightKg,
  heightCm: heightCm,
  waistCm: waistCm,
  neckCm: neckCm,
  hipsCm: hipsCm,
  loggedBodyFatPercent: bf,
  sex: sex,
  birthYear: birthYear,
  activityLevel: level,
  cutoffs: cutoffs,
);

double _v(StatResult<double> r) {
  expect(r, isA<StatValue<double>>());
  return (r as StatValue<double>).value;
}

void main() {
  group('BMI', () {
    test('80 kg at 180 cm is 24.691, WHO normal, Asian overweight', () {
      final double b = _v(BodyStats.bmi(_in(weightKg: 80, heightCm: 180)));
      expect(b, closeTo(24.691, 0.001));
      expect(BodyStats.bmiCategory(b, BmiCutoffs.who), BmiCategory.normal);
      expect(
        BodyStats.bmiCategory(b, BmiCutoffs.asian),
        BmiCategory.overweight,
      );
    });

    test('boundaries on the unrounded value, both systems', () {
      final Map<double, List<BmiCategory>>
      expected = <double, List<BmiCategory>>{
        // value: [WHO, Asian]
        18.4: <BmiCategory>[BmiCategory.underweight, BmiCategory.underweight],
        18.5: <BmiCategory>[BmiCategory.normal, BmiCategory.normal],
        22.9: <BmiCategory>[BmiCategory.normal, BmiCategory.normal],
        23: <BmiCategory>[BmiCategory.normal, BmiCategory.overweight],
        24.9: <BmiCategory>[BmiCategory.normal, BmiCategory.overweight],
        25: <BmiCategory>[BmiCategory.overweight, BmiCategory.obese],
        29.9: <BmiCategory>[BmiCategory.overweight, BmiCategory.obese],
        30: <BmiCategory>[BmiCategory.obese, BmiCategory.obese],
      };
      expected.forEach((double bmi, List<BmiCategory> cats) {
        expect(
          BodyStats.bmiCategory(bmi, BmiCutoffs.who),
          cats[0],
          reason: 'WHO $bmi',
        );
        expect(
          BodyStats.bmiCategory(bmi, BmiCutoffs.asian),
          cats[1],
          reason: 'Asian $bmi',
        );
      });
    });

    test('missing inputs are listed exactly', () {
      expect(
        BodyStats.bmi(_in()),
        const MissingInputs<double>(<StatInput>[
          StatInput.weight,
          StatInput.height,
        ]),
      );
      expect(
        BodyStats.bmi(_in(weightKg: 80)),
        const MissingInputs<double>(<StatInput>[StatInput.height]),
      );
      expect(
        BodyStats.bmi(_in(heightCm: 180)),
        const MissingInputs<double>(<StatInput>[StatInput.weight]),
      );
    });

    test('zero height is invalid, never NaN or infinity', () {
      expect(
        BodyStats.bmi(_in(weightKg: 80, heightCm: 0)),
        const InvalidInputs<double>(<StatInput>[StatInput.height]),
      );
    });

    test('unit round trip: 176.37 lb and 70.866 in give the same BMI', () {
      final double kg = Units.toKg(176.37, WeightUnit.lb);
      final double cm = Units.toCm(70.866, LengthUnit.inch);
      final double fromImperial = _v(
        BodyStats.bmi(_in(weightKg: kg, heightCm: cm)),
      );
      // Round trip back through the display unit lands on the same kg.
      final double back = Units.toKg(
        Units.fromKg(kg, WeightUnit.lb),
        WeightUnit.lb,
      );
      expect(back, closeTo(kg, 1e-12));
      expect(
        _v(BodyStats.bmi(_in(weightKg: back, heightCm: cm))),
        fromImperial,
      );
      // 176.37 lb = 80.0 kg, 70.866 in = 180.0 cm.
      expect(fromImperial, closeTo(24.691, 0.01));
    });
  });

  group('healthy weight range', () {
    test('180 cm: 18.5 to 24.9 times h squared', () {
      final StatResult<HealthyWeightRange> r = BodyStats.healthyWeightRange(
        _in(heightCm: 180),
      );
      final HealthyWeightRange range =
          (r as StatValue<HealthyWeightRange>).value;
      // 1.8^2 = 3.24; 18.5 * 3.24 = 59.94; 24.9 * 3.24 = 80.676
      expect(range.minKg, closeTo(59.94, 1e-9));
      expect(range.maxKg, closeTo(80.676, 1e-9));
    });

    test('Asian upper is 22.9', () {
      final StatResult<HealthyWeightRange> r = BodyStats.healthyWeightRange(
        _in(heightCm: 180, cutoffs: BmiCutoffs.asian),
      );
      // 22.9 * 3.24 = 74.196
      expect(
        (r as StatValue<HealthyWeightRange>).value.maxKg,
        closeTo(74.196, 1e-9),
      );
    });

    test('missing height', () {
      expect(
        BodyStats.healthyWeightRange(_in()),
        const MissingInputs<HealthyWeightRange>(<StatInput>[StatInput.height]),
      );
    });
  });

  group('BMR and TDEE', () {
    // Male: 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
    // Female: ... - 161 = 1614; unset: ... - 78 = 1697
    test('male 80 kg / 180 cm / 30 y is 1780', () {
      final StatResult<double> r = BodyStats.bmr(
        _in(weightKg: 80, heightCm: 180, birthYear: 1996, sex: Sex.male),
      );
      expect(_v(r), 1780);
      expect((r as StatValue<double>).approximate, isFalse);
    });

    test('female is 1614', () {
      expect(
        _v(
          BodyStats.bmr(
            _in(weightKg: 80, heightCm: 180, birthYear: 1996, sex: Sex.female),
          ),
        ),
        1614,
      );
    });

    test('sex unset is 1697 and approximate', () {
      final StatResult<double> r = BodyStats.bmr(
        _in(weightKg: 80, heightCm: 180, birthYear: 1996),
      );
      expect(_v(r), 1697);
      expect((r as StatValue<double>).approximate, isTrue);
    });

    test('age never goes negative', () {
      expect(_in(birthYear: 2030).age, 0);
      expect(_in(birthYear: 1996).age, 30);
      expect(_in().age, isNull);
    });

    test('missing inputs', () {
      expect(
        BodyStats.bmr(_in()),
        const MissingInputs<double>(<StatInput>[
          StatInput.weight,
          StatInput.height,
          StatInput.age,
        ]),
      );
      expect(
        BodyStats.bmr(_in(weightKg: 80, heightCm: 180)),
        const MissingInputs<double>(<StatInput>[StatInput.age]),
      );
    });

    test('TDEE moderate male is 1780 * 1.55 = 2759', () {
      expect(
        _v(
          BodyStats.tdee(
            _in(
              weightKg: 80,
              heightCm: 180,
              birthYear: 1996,
              sex: Sex.male,
              level: ActivityLevel.moderate,
            ),
          ),
        ),
        closeTo(2759, 1e-9),
      );
    });

    test('every activity factor', () {
      expect(BodyStats.activityFactor(ActivityLevel.sedentary), 1.2);
      expect(BodyStats.activityFactor(ActivityLevel.light), 1.375);
      expect(BodyStats.activityFactor(ActivityLevel.moderate), 1.55);
      expect(BodyStats.activityFactor(ActivityLevel.veryActive), 1.725);
      expect(BodyStats.activityFactor(ActivityLevel.extraActive), 1.9);
    });

    test('TDEE propagates approximate', () {
      final StatResult<double> r = BodyStats.tdee(
        _in(
          weightKg: 80,
          heightCm: 180,
          birthYear: 1996,
          level: ActivityLevel.sedentary,
        ),
      );
      // 1697 * 1.2 = 2036.4
      expect(_v(r), closeTo(2036.4, 1e-9));
      expect((r as StatValue<double>).approximate, isTrue);
    });

    test('TDEE missing lists BMR inputs plus activity level', () {
      expect(
        BodyStats.tdee(_in()),
        const MissingInputs<double>(<StatInput>[
          StatInput.weight,
          StatInput.height,
          StatInput.age,
          StatInput.activityLevel,
        ]),
      );
      expect(
        BodyStats.tdee(_in(weightKg: 80, heightCm: 180, birthYear: 1996)),
        const MissingInputs<double>(<StatInput>[StatInput.activityLevel]),
      );
    });
  });

  group('Navy body fat', () {
    // Male: waist - neck = 52; log10(52) = 1.71600; log10(180) = 2.25527
    // density = 1.0324 - 0.19077*1.71600 + 0.15456*2.25527 = 1.05358
    // 495 / 1.05358 - 450 = 19.81
    test('male 90 / 38 / 180 is about 19.81', () {
      final StatResult<double> r = BodyStats.navyBodyFat(
        _in(heightCm: 180, waistCm: 90, neckCm: 38, sex: Sex.male),
      );
      expect(_v(r), closeTo(19.81, 0.01));
      expect((r as StatValue<double>).estimated, isTrue);
    });

    // Female: 75 + 100 - 32 = 143; log10(143) = 2.15534; log10(165) = 2.21748
    // density = 1.29579 - 0.35004*2.15534 + 0.221*2.21748 = 1.03142
    // 495 / 1.03142 - 450 = 29.93
    test('female 75 / 100 / 32 / 165 is about 29.93', () {
      expect(
        _v(
          BodyStats.navyBodyFat(
            _in(
              heightCm: 165,
              waistCm: 75,
              neckCm: 32,
              hipsCm: 100,
              sex: Sex.female,
            ),
          ),
        ),
        closeTo(29.93, 0.01),
      );
    });

    test('sex required', () {
      expect(
        BodyStats.navyBodyFat(_in(heightCm: 180, waistCm: 90, neckCm: 38)),
        const MissingInputs<double>(<StatInput>[StatInput.sex]),
      );
    });

    test('male missing measurements; hips not required', () {
      expect(
        BodyStats.navyBodyFat(_in(sex: Sex.male)),
        const MissingInputs<double>(<StatInput>[
          StatInput.height,
          StatInput.waist,
          StatInput.neck,
        ]),
      );
    });

    test('female also needs hips', () {
      expect(
        BodyStats.navyBodyFat(
          _in(heightCm: 165, waistCm: 75, neckCm: 32, sex: Sex.female),
        ),
        const MissingInputs<double>(<StatInput>[StatInput.hips]),
      );
    });

    test('waist not larger than neck is invalid, not NaN', () {
      final StatResult<double> r = BodyStats.navyBodyFat(
        _in(heightCm: 180, waistCm: 38, neckCm: 38, sex: Sex.male),
      );
      expect(r, isA<InvalidInputs<double>>());
      expect(
        BodyStats.navyBodyFat(
          _in(heightCm: 180, waistCm: 30, neckCm: 38, sex: Sex.male),
        ),
        isA<InvalidInputs<double>>(),
      );
    });

    test('negative measurement is invalid', () {
      expect(
        BodyStats.navyBodyFat(
          _in(heightCm: 180, waistCm: -5, neckCm: 38, sex: Sex.male),
        ),
        const InvalidInputs<double>(<StatInput>[StatInput.waist]),
      );
    });
  });

  group('body fat resolution', () {
    final BodyStatsInput navyInput = _in(
      heightCm: 180,
      waistCm: 90,
      neckCm: 38,
      sex: Sex.male,
    );

    test('logged value is primary, Navy is secondary', () {
      final BodyFat bf = (BodyStats.bodyFat(
        _in(heightCm: 180, waistCm: 90, neckCm: 38, sex: Sex.male, bf: 15),
      ) as StatValue<BodyFat>).value;
      expect(bf.primary, 15);
      expect(bf.primaryIsLogged, isTrue);
      expect(bf.navyEstimate, closeTo(19.81, 0.01));
    });

    test('logged value alone has no Navy estimate', () {
      final BodyFat bf =
          (BodyStats.bodyFat(_in(bf: 15)) as StatValue<BodyFat>).value;
      expect(bf.primary, 15);
      expect(bf.navyEstimate, isNull);
    });

    test('without a logged value Navy is primary and estimated', () {
      final StatResult<BodyFat> r = BodyStats.bodyFat(navyInput);
      final StatValue<BodyFat> v = r as StatValue<BodyFat>;
      expect(v.value.primaryIsLogged, isFalse);
      expect(v.value.primary, closeTo(19.81, 0.01));
      expect(v.estimated, isTrue);
    });

    test('nothing available lists the Navy inputs', () {
      expect(
        BodyStats.bodyFat(_in()),
        const MissingInputs<BodyFat>(<StatInput>[StatInput.sex]),
      );
    });
  });

  group('ratios', () {
    test('waist to height and the marker', () {
      expect(kWaistToHeightMarker, 0.5);
      expect(_v(BodyStats.waistToHeight(_in(waistCm: 90, heightCm: 180))), 0.5);
      expect(
        BodyStats.waistToHeight(_in()),
        const MissingInputs<double>(<StatInput>[
          StatInput.waist,
          StatInput.height,
        ]),
      );
    });

    test('waist to hip', () {
      expect(
        _v(BodyStats.waistToHip(_in(waistCm: 80, hipsCm: 100))),
        closeTo(0.8, 1e-12),
      );
      expect(
        BodyStats.waistToHip(_in(waistCm: 80)),
        const MissingInputs<double>(<StatInput>[StatInput.hips]),
      );
      expect(
        BodyStats.waistToHip(_in(waistCm: 80, hipsCm: 0)),
        const InvalidInputs<double>(<StatInput>[StatInput.hips]),
      );
    });
  });

  group('lean body mass', () {
    test('uses the logged body fat: 80 * (1 - 0.2) = 64', () {
      expect(_v(BodyStats.leanBodyMass(_in(weightKg: 80, bf: 20))), 64);
    });

    test('falls back to Navy', () {
      final StatResult<double> r = BodyStats.leanBodyMass(
        _in(
          weightKg: 80,
          heightCm: 180,
          waistCm: 90,
          neckCm: 38,
          sex: Sex.male,
        ),
      );
      // 80 * (1 - 0.1981) = 64.15
      expect(_v(r), closeTo(64.15, 0.01));
      expect((r as StatValue<double>).estimated, isTrue);
    });

    test('missing weight with a logged body fat', () {
      expect(
        BodyStats.leanBodyMass(_in(bf: 20)),
        const MissingInputs<double>(<StatInput>[StatInput.weight]),
      );
    });

    test('missing weight and body fat inputs', () {
      expect(
        BodyStats.leanBodyMass(_in()),
        const MissingInputs<double>(<StatInput>[
          StatInput.weight,
          StatInput.sex,
        ]),
      );
    });

    test('invalid Navy geometry propagates', () {
      expect(
        BodyStats.leanBodyMass(
          _in(
            weightKg: 80,
            heightCm: 180,
            waistCm: 30,
            neckCm: 38,
            sex: Sex.male,
          ),
        ),
        isA<InvalidInputs<double>>(),
      );
    });
  });

  group('calories burned', () {
    test('MET 5 x 80 kg x 0.5 h = 200', () {
      expect(BodyStats.caloriesForWork(5, 80, 1800), closeTo(200, 1e-9));
    });

    test('zero or negative inputs give 0', () {
      expect(BodyStats.caloriesForWork(0, 80, 1800), 0);
      expect(BodyStats.caloriesForWork(5, 80, 0), 0);
    });

    SetEntry set(
      String id, {
      int? reps,
      int? durationSec,
      int? holdSec,
      int? rounds,
      bool completed = true,
      bool warmup = false,
    }) => SetEntry(
      id: id,
      position: 0,
      reps: reps,
      durationSec: durationSec,
      holdSec: holdSec,
      rounds: rounds,
      completed: completed,
      isWarmup: warmup,
    );

    WorkoutSession session(List<SessionExercise> ex) => WorkoutSession(
      id: 's',
      startedAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      exercises: ex,
    );

    test('work seconds per set', () {
      expect(BodyStats.workSecondsForSet(set('a', reps: 10)), 30);
      expect(BodyStats.workSecondsForSet(set('a', durationSec: 45)), 45);
      expect(BodyStats.workSecondsForSet(set('a', holdSec: 20)), 20);
      expect(
        BodyStats.workSecondsForSet(set('a', durationSec: 45, reps: 10)),
        45,
      );
      expect(BodyStats.workSecondsForSet(set('a', rounds: 3)), 180);
      expect(
        BodyStats.workSecondsForSet(set('a', rounds: 3, durationSec: 540)),
        540,
      );
      expect(BodyStats.workSecondsForSet(set('a')), 0);
    });

    test('sums completed non-warm-up sets of exercises with a known MET', () {
      // Squat: 2 working sets x 600 reps-seconds => 1200 s. Warm-up and
      // incomplete sets are ignored. 6 * 80 * (1200/3600) = 160.
      // Plank: 1800 s at MET 5 => 5 * 80 * 0.5 = 200.
      // Mystery: unknown MET, skipped.
      final WorkoutSession s = session(<SessionExercise>[
        SessionExercise(
          id: 'e1',
          exerciseId: 'squat',
          position: 0,
          sets: <SetEntry>[
            set('a', reps: 200),
            set('b', reps: 200),
            set('c', reps: 100, warmup: true),
            set('d', reps: 100, completed: false),
          ],
        ),
        SessionExercise(
          id: 'e2',
          exerciseId: 'plank',
          position: 1,
          sets: <SetEntry>[set('e', holdSec: 1800)],
        ),
        SessionExercise(
          id: 'e3',
          exerciseId: 'mystery',
          position: 2,
          sets: <SetEntry>[set('f', reps: 50)],
        ),
      ]);
      final StatResult<double> r = BodyStats.estimateSessionCalories(
        s,
        <String, double?>{'squat': 6, 'plank': 5, 'mystery': null},
        80,
      );
      expect(_v(r), closeTo(360, 1e-9));
      expect((r as StatValue<double>).estimated, isTrue);
    });

    test('missing weight', () {
      expect(
        BodyStats.estimateSessionCalories(
          session(<SessionExercise>[]),
          <String, double?>{},
          0,
        ),
        const MissingInputs<double>(<StatInput>[StatInput.weight]),
      );
    });
  });
}
