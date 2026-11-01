import 'dart:math' as math;

import '../../core/models/enums.dart';
import '../../core/models/training.dart';
import 'stat_result.dart';

export 'stat_result.dart';

// PURE DART. Metric in, metric out: kg, cm, seconds.

/// Seconds a rep is assumed to take when a set has no duration.
const double kSecondsPerRep = 3;

/// Seconds credited to one round when a rounds set has no duration.
const double kSecondsPerRound = 60;

/// The waist-to-height reference marker: below 0.5 is the common guidance.
const double kWaistToHeightMarker = 0.5;

/// Everything the stats can use. Absent values are null.
class BodyStatsInput {
  const BodyStatsInput({
    required this.now,
    this.weightKg,
    this.heightCm,
    this.waistCm,
    this.neckCm,
    this.hipsCm,
    this.loggedBodyFatPercent,
    this.sex,
    this.birthYear,
    this.activityLevel,
    this.cutoffs = BmiCutoffs.who,
  });

  final double? weightKg;
  final double? heightCm;
  final double? waistCm;
  final double? neckCm;
  final double? hipsCm;
  final double? loggedBodyFatPercent;
  final Sex? sex;
  final int? birthYear;
  final ActivityLevel? activityLevel;
  final BmiCutoffs cutoffs;
  final DateTime now;

  /// Whole years from [birthYear] and [now]; never negative.
  int? get age {
    final int? y = birthYear;
    if (y == null) return null;
    return math.max(0, now.year - y);
  }
}

enum BmiCategory { underweight, normal, overweight, obese }

class HealthyWeightRange {
  const HealthyWeightRange({required this.minKg, required this.maxKg});
  final double minKg;
  final double maxKg;
}

/// The resolved body fat: the logged value wins; the Navy estimate is kept
/// alongside when it can be computed.
class BodyFat {
  const BodyFat({
    required this.primary,
    required this.primaryIsLogged,
    this.navyEstimate,
  });

  final double primary;
  final bool primaryIsLogged;
  final double? navyEstimate;
}

abstract final class BodyStats {
  static bool _valid(double? v) => v != null && v.isFinite && v > 0;

  static List<StatInput> _missing(List<(StatInput, double?)> pairs) {
    return <StatInput>[
      for (final (StatInput i, double? v) in pairs)
        if (v == null) i,
    ];
  }

  static List<StatInput> _invalid(List<(StatInput, double?)> pairs) {
    return <StatInput>[
      for (final (StatInput i, double? v) in pairs)
        if (v != null && !_valid(v)) i,
    ];
  }

  // ── BMI ────────────────────────────────────────────────────────────────────

  static double bmiOf(double weightKg, double heightCm) {
    final double m = heightCm / 100;
    return weightKg / (m * m);
  }

  static StatResult<double> bmi(BodyStatsInput i) {
    final List<(StatInput, double?)> p = <(StatInput, double?)>[
      (StatInput.weight, i.weightKg),
      (StatInput.height, i.heightCm),
    ];
    final List<StatInput> missing = _missing(p);
    if (missing.isNotEmpty) return MissingInputs<double>(missing);
    final List<StatInput> bad = _invalid(p);
    if (bad.isNotEmpty) return InvalidInputs<double>(bad);
    return StatValue<double>(bmiOf(i.weightKg!, i.heightCm!));
  }

  /// Boundaries apply to the unrounded value.
  static BmiCategory bmiCategory(double bmi, BmiCutoffs cutoffs) {
    final double normalTop = cutoffs == BmiCutoffs.who ? 25 : 23;
    final double overweightTop = cutoffs == BmiCutoffs.who ? 30 : 25;
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < normalTop) return BmiCategory.normal;
    if (bmi < overweightTop) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  static StatResult<HealthyWeightRange> healthyWeightRange(BodyStatsInput i) {
    final double? h = i.heightCm;
    if (h == null) {
      return const MissingInputs<HealthyWeightRange>(<StatInput>[
        StatInput.height,
      ]);
    }
    if (!_valid(h)) {
      return const InvalidInputs<HealthyWeightRange>(<StatInput>[
        StatInput.height,
      ]);
    }
    final double m = h / 100;
    final double upper = i.cutoffs == BmiCutoffs.who ? 24.9 : 22.9;
    return StatValue<HealthyWeightRange>(
      HealthyWeightRange(minKg: 18.5 * m * m, maxKg: upper * m * m),
    );
  }

  // ── BMR and TDEE ───────────────────────────────────────────────────────────

  /// Mifflin-St Jeor. Sex unset uses the midpoint offset (-78) and marks the
  /// result approximate.
  static StatResult<double> bmr(BodyStatsInput i) {
    final List<(StatInput, double?)> p = <(StatInput, double?)>[
      (StatInput.weight, i.weightKg),
      (StatInput.height, i.heightCm),
    ];
    final List<StatInput> missing = _missing(p);
    if (i.age == null) missing.add(StatInput.age);
    if (missing.isNotEmpty) return MissingInputs<double>(missing);
    final List<StatInput> bad = _invalid(p);
    if (bad.isNotEmpty) return InvalidInputs<double>(bad);
    final double s = switch (i.sex) {
      Sex.male => 5,
      Sex.female => -161,
      null => -78,
    };
    final double v = 10 * i.weightKg! + 6.25 * i.heightCm! - 5 * i.age! + s;
    return StatValue<double>(v, approximate: i.sex == null);
  }

  static double activityFactor(ActivityLevel l) => switch (l) {
    ActivityLevel.sedentary => 1.2,
    ActivityLevel.light => 1.375,
    ActivityLevel.moderate => 1.55,
    ActivityLevel.veryActive => 1.725,
    ActivityLevel.extraActive => 1.9,
  };

  static StatResult<double> tdee(BodyStatsInput i) {
    final StatResult<double> b = bmr(i);
    final ActivityLevel? level = i.activityLevel;
    switch (b) {
      case StatValue<double>():
        if (level == null) {
          return const MissingInputs<double>(<StatInput>[
            StatInput.activityLevel,
          ]);
        }
        return StatValue<double>(
          b.value * activityFactor(level),
          approximate: b.approximate,
        );
      case MissingInputs<double>():
        return MissingInputs<double>(<StatInput>[
          ...b.missing,
          if (level == null) StatInput.activityLevel,
        ]);
      case InvalidInputs<double>():
        return b;
    }
  }

  // ── Body fat ───────────────────────────────────────────────────────────────

  /// US Navy estimate (cm). Sex is required.
  static StatResult<double> navyBodyFat(BodyStatsInput i) {
    final Sex? sex = i.sex;
    if (sex == null) {
      return const MissingInputs<double>(<StatInput>[StatInput.sex]);
    }
    final List<(StatInput, double?)> p = <(StatInput, double?)>[
      (StatInput.height, i.heightCm),
      (StatInput.waist, i.waistCm),
      (StatInput.neck, i.neckCm),
      if (sex == Sex.female) (StatInput.hips, i.hipsCm),
    ];
    final List<StatInput> missing = _missing(p);
    if (missing.isNotEmpty) return MissingInputs<double>(missing);
    final List<StatInput> bad = _invalid(p);
    if (bad.isNotEmpty) return InvalidInputs<double>(bad);
    final double h = i.heightCm!;
    final double waist = i.waistCm!;
    final double neck = i.neckCm!;
    final double girth = sex == Sex.male
        ? waist - neck
        : waist + i.hipsCm! - neck;
    if (girth <= 0) {
      return const InvalidInputs<double>(<StatInput>[
        StatInput.waist,
        StatInput.neck,
      ]);
    }
    final double density = sex == Sex.male
        ? 1.0324 - 0.19077 * _log10(girth) + 0.15456 * _log10(h)
        : 1.29579 - 0.35004 * _log10(girth) + 0.22100 * _log10(h);
    final double bf = 495 / density - 450;
    if (!bf.isFinite) {
      return const InvalidInputs<double>(<StatInput>[StatInput.waist]);
    }
    return StatValue<double>(bf, estimated: true);
  }

  static double _log10(double x) => math.log(x) / math.ln10;

  /// The logged value is primary when present; the Navy estimate rides along.
  static StatResult<BodyFat> bodyFat(BodyStatsInput i) {
    final double? logged = i.loggedBodyFatPercent;
    final StatResult<double> navy = navyBodyFat(i);
    if (logged != null && logged.isFinite && logged > 0 && logged < 100) {
      return StatValue<BodyFat>(
        BodyFat(
          primary: logged,
          primaryIsLogged: true,
          navyEstimate: navy.valueOrNull,
        ),
      );
    }
    switch (navy) {
      case StatValue<double>():
        return StatValue<BodyFat>(
          BodyFat(
            primary: navy.value,
            primaryIsLogged: false,
            navyEstimate: navy.value,
          ),
          estimated: true,
        );
      case MissingInputs<double>():
        return MissingInputs<BodyFat>(navy.missing);
      case InvalidInputs<double>():
        return InvalidInputs<BodyFat>(navy.invalid);
    }
  }

  // ── Ratios ─────────────────────────────────────────────────────────────────

  static StatResult<double> waistToHeight(BodyStatsInput i) =>
      _ratio(StatInput.waist, i.waistCm, StatInput.height, i.heightCm);

  static StatResult<double> waistToHip(BodyStatsInput i) =>
      _ratio(StatInput.waist, i.waistCm, StatInput.hips, i.hipsCm);

  static StatResult<double> _ratio(
    StatInput an,
    double? a,
    StatInput bn,
    double? b,
  ) {
    final List<(StatInput, double?)> p = <(StatInput, double?)>[
      (an, a),
      (bn, b),
    ];
    final List<StatInput> missing = _missing(p);
    if (missing.isNotEmpty) return MissingInputs<double>(missing);
    final List<StatInput> bad = _invalid(p);
    if (bad.isNotEmpty) return InvalidInputs<double>(bad);
    return StatValue<double>(a! / b!);
  }

  // ── Lean body mass ─────────────────────────────────────────────────────────

  static StatResult<double> leanBodyMass(BodyStatsInput i) {
    final StatResult<BodyFat> bf = bodyFat(i);
    final double? w = i.weightKg;
    switch (bf) {
      case StatValue<BodyFat>():
        if (w == null) {
          return const MissingInputs<double>(<StatInput>[StatInput.weight]);
        }
        if (!_valid(w)) {
          return const InvalidInputs<double>(<StatInput>[StatInput.weight]);
        }
        return StatValue<double>(
          w * (1 - bf.value.primary / 100),
          approximate: bf.approximate,
          estimated: bf.estimated,
        );
      case MissingInputs<BodyFat>():
        return MissingInputs<double>(<StatInput>[
          if (w == null) StatInput.weight,
          ...bf.missing,
        ]);
      case InvalidInputs<BodyFat>():
        return InvalidInputs<double>(bf.invalid);
    }
  }

  // ── Calories burned ────────────────────────────────────────────────────────

  /// kcal = MET x kg x hours of work. Rest is excluded by the caller.
  static double caloriesForWork(
    double met,
    double weightKg,
    double workSeconds,
  ) {
    if (met <= 0 || weightKg <= 0 || workSeconds <= 0) return 0;
    return met * weightKg * (workSeconds / 3600);
  }

  /// Seconds of work in one set, or 0 when it carries nothing countable.
  static double workSecondsForSet(SetEntry s) {
    final int? d = s.durationSec;
    if (d != null) return d.toDouble();
    final int? hold = s.holdSec;
    if (hold != null) return hold.toDouble();
    final int? reps = s.reps;
    if (reps != null) return reps * kSecondsPerRep;
    final int? rounds = s.rounds;
    if (rounds != null) return rounds * kSecondsPerRound;
    return 0;
  }

  /// Sums completed, non-warm-up sets of exercises with a known MET.
  /// Always flagged estimated.
  static StatResult<double> estimateSessionCalories(
    WorkoutSession session,
    Map<String, double?> metByExerciseId,
    double weightKg,
  ) {
    if (!_valid(weightKg)) {
      return const MissingInputs<double>(<StatInput>[StatInput.weight]);
    }
    double total = 0;
    for (final SessionExercise e in session.exercises) {
      final double? met = metByExerciseId[e.exerciseId];
      if (met == null) continue;
      double seconds = 0;
      for (final SetEntry s in e.sets) {
        if (!s.completed || s.isWarmup) continue;
        seconds += workSecondsForSet(s);
      }
      total += caloriesForWork(met, weightKg, seconds);
    }
    return StatValue<double>(total, estimated: true);
  }
}
