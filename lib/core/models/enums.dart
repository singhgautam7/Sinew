/// Enumerations shared by the user database, the library, the engines and
/// backups. Pure Dart: no Flutter imports, so engines can depend on them.
///
/// Every enum is persisted by `name`. Reading an unknown name (a newer
/// library, a newer backup) never throws: [enumByName] falls back.
library;

T enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final T v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

T? enumByNameOrNull<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final T v in values) {
    if (v.name == name) return v;
  }
  return null;
}

/// Which inputs a set row shows. Drives the active-workout UI.
enum TrackingType {
  weightReps,
  reps,
  time,
  distanceTime,
  rounds,
  hold,
  flow,

  /// A tracking type this build does not know (from a newer library).
  /// Rendered as `reps`.
  unknown,
}

enum Difficulty { beginner, intermediate, advanced }

enum Sex { male, female }

/// Mifflin-St Jeor activity multipliers live in `engines/body_stats`.
enum ActivityLevel { sedentary, light, moderate, veryActive, extraActive }

/// WHO or Asian BMI cut-offs.
enum BmiCutoffs { who, asian }

enum WeightUnit { kg, lb }

enum LengthUnit { cm, inch }

enum DistanceUnit { km, mi }

/// The kind of set. Warm-up is a separate flag so a warm-up drop set is
/// expressible.
enum SetType { normal, drop, failure, amrap }

enum MeasurementUnitType { length, mass, percent, count, custom }

enum BodySide { none, left, right }

/// Where a measurement sits on the silhouette.
enum BodyAnchor {
  neck,
  shoulders,
  chest,
  upperArm,
  forearm,
  aboveNavel,
  waist,
  belowNavel,
  hips,
  thigh,
  calf,
}

enum TimerMode {
  stopwatch,
  countdown,
  interval,
  tabata,
  emom,
  amrap,
  boxing,
  yogaFlow,
  custom,
}

enum TimerPhase { prepare, work, rest, roundRest, cooldown, open }

/// Where a workout session came from.
enum SessionSource { manual, routine, timer, import }
