import '../../core/models/enums.dart';
import '../../core/models/measurement.dart';
import '../../core/models/profile.dart';
import '../../engines/body_stats/body_stats.dart';
import '../../engines/silhouette/silhouette_engine.dart';

// PURE DART. Everything here is metric; units convert at the widgets' edge.

/// Stable ids of the built-in fields the stats read.
abstract final class BodyFieldIds {
  static const String weight = 'weight';
  static const String height = 'height';
  static const String neck = 'neck';
  static const String waist = 'waist';
  static const String hips = 'hips';
  static const String bodyFat = 'body-fat';
}

/// One field's value on a day.
typedef DatedValue = ({double value, DateTime date});

/// A field's newest value and the one before it (the delta basis).
class LatestValue {
  const LatestValue({required this.value, required this.date, this.previous});

  final double value;
  final DateTime date;
  final DatedValue? previous;

  double? get delta => previous == null ? null : value - previous!.value;
}

/// The latest value of every field as of [upTo] (all time when null), each
/// taken from the newest entry that has it. [entriesNewestFirst] must be
/// sorted newest first, as the repository returns them.
Map<String, DatedValue> valuesAsOf(
  List<MeasurementEntry> entriesNewestFirst, {
  DateTime? upTo,
}) {
  final Map<String, DatedValue> out = <String, DatedValue>{};
  for (final MeasurementEntry e in entriesNewestFirst) {
    if (upTo != null && e.date.isAfter(upTo)) continue;
    for (final MapEntry<String, double> v in e.values.entries) {
      out.putIfAbsent(v.key, () => (value: v.value, date: e.date));
    }
  }
  return out;
}

/// Newest and previous value per field.
Map<String, LatestValue> latestWithPrevious(
  List<MeasurementEntry> entriesNewestFirst,
) {
  final Map<String, LatestValue> out = <String, LatestValue>{};
  for (final MeasurementEntry e in entriesNewestFirst) {
    for (final MapEntry<String, double> v in e.values.entries) {
      final LatestValue? have = out[v.key];
      if (have == null) {
        out[v.key] = LatestValue(value: v.value, date: e.date);
      } else if (have.previous == null) {
        out[v.key] = LatestValue(
          value: have.value,
          date: have.date,
          previous: (value: v.value, date: e.date),
        );
      }
    }
  }
  return out;
}

/// The height to use: the logged Height field or the profile's, whichever
/// was set last (the profile wins when its date is unknown).
double? resolveHeightCm(Map<String, DatedValue> values, Profile profile) {
  final DatedValue? logged = values[BodyFieldIds.height];
  final double? fromProfile = profile.heightCm;
  if (logged == null) return fromProfile;
  if (fromProfile == null) return logged.value;
  final DateTime? profileAt = profile.updatedAt;
  if (profileAt != null && logged.date.isAfter(profileAt)) {
    return logged.value;
  }
  return fromProfile;
}

/// Everything the stats engine reads, from the latest values and the profile.
BodyStatsInput bodyStatsInputFor(
  Map<String, DatedValue> values,
  Profile profile,
  DateTime now,
) {
  double? v(String id) => values[id]?.value;
  return BodyStatsInput(
    now: now,
    weightKg: v(BodyFieldIds.weight),
    heightCm: resolveHeightCm(values, profile),
    waistCm: v(BodyFieldIds.waist),
    neckCm: v(BodyFieldIds.neck),
    hipsCm: v(BodyFieldIds.hips),
    loggedBodyFatPercent: v(BodyFieldIds.bodyFat),
    sex: profile.sex,
    birthYear: profile.birthYear,
    activityLevel: profile.activityLevel,
    cutoffs: profile.bmiCutoffs,
  );
}

/// The silhouette input: length fields with a body anchor, the two sides of a
/// pair averaged.
SilhouetteInput silhouetteInputFor(
  List<MeasurementField> fields,
  Map<String, DatedValue> values,
  Profile profile,
) {
  final Map<BodyAnchor, List<double>> byAnchor = <BodyAnchor, List<double>>{};
  for (final MeasurementField f in fields) {
    final BodyAnchor? a = f.bodyAnchor;
    if (a == null || f.archived || f.unitType != MeasurementUnitType.length) {
      continue;
    }
    final DatedValue? v = values[f.id];
    if (v == null) continue;
    byAnchor.putIfAbsent(a, () => <double>[]).add(v.value);
  }
  return SilhouetteInput(
    measurements: <BodyAnchor, double>{
      for (final MapEntry<BodyAnchor, List<double>> e in byAnchor.entries)
        e.key: e.value.reduce((double a, double b) => a + b) / e.value.length,
    },
    heightCm: resolveHeightCm(values, profile),
    sex: profile.sex,
  );
}

/// The silhouette geometry for the state of the body on [upTo].
SilhouetteGeometry geometryAsOf(
  List<MeasurementField> fields,
  List<MeasurementEntry> entriesNewestFirst,
  Profile profile, {
  DateTime? upTo,
  double? heightOverrideCm,
}) {
  final SilhouetteInput input = silhouetteInputFor(
    fields,
    valuesAsOf(entriesNewestFirst, upTo: upTo),
    profile,
  );
  return buildSilhouette(
    SilhouetteInput(
      measurements: input.measurements,
      heightCm: heightOverrideCm ?? input.heightCm,
      sex: input.sex,
    ),
  );
}

/// Fields shown on an entry form: enabled and live, plus any field that
/// already has a value in the entry (so editing never drops data).
List<MeasurementField> formFields(
  List<MeasurementField> all,
  Map<String, double> existingValues, {
  Set<String> alsoShow = const <String>{},
}) {
  return <MeasurementField>[
    for (final MeasurementField f in all)
      if ((f.enabled && !f.archived) ||
          existingValues.containsKey(f.id) ||
          (alsoShow.contains(f.id) && !f.archived))
        f,
  ];
}

/// Rows of an entry form: a single field or a left/right pair.
class FormRowSpec {
  const FormRowSpec.single(this.field) : left = null, right = null;
  const FormRowSpec.pair({
    required MeasurementField this.left,
    required MeasurementField this.right,
  }) : field = null;

  final MeasurementField? field;
  final MeasurementField? left;
  final MeasurementField? right;

  bool get isPair => field == null;
}

/// Groups fields sharing a pair id into one row at the first one's place.
/// A pair with only one side visible stays a single row.
List<FormRowSpec> groupFormRows(List<MeasurementField> fields) {
  final Map<String, List<MeasurementField>> pairs =
      <String, List<MeasurementField>>{};
  for (final MeasurementField f in fields) {
    final String? p = f.pairId;
    if (p != null && f.side != BodySide.none) {
      pairs.putIfAbsent(p, () => <MeasurementField>[]).add(f);
    }
  }
  final Set<String> done = <String>{};
  final List<FormRowSpec> rows = <FormRowSpec>[];
  for (final MeasurementField f in fields) {
    final String? p = f.pairId;
    final List<MeasurementField>? group = p == null ? null : pairs[p];
    MeasurementField? left;
    MeasurementField? right;
    if (group != null) {
      for (final MeasurementField g in group) {
        if (g.side == BodySide.left) left ??= g;
        if (g.side == BodySide.right) right ??= g;
      }
    }
    if (left != null && right != null) {
      if (done.add(p!)) rows.add(FormRowSpec.pair(left: left, right: right));
    } else {
      rows.add(FormRowSpec.single(f));
    }
  }
  return rows;
}

/// "Bicep" from "Left bicep" and "Right bicep"; falls back to the left name.
String pairName(MeasurementField left, MeasurementField right) {
  String strip(String n, String side) {
    final RegExp re = RegExp('^$side\\s+', caseSensitive: false);
    final String s = n.replaceFirst(re, '').trim();
    return s.isEmpty ? n : s;
  }

  final String a = strip(left.name, 'left');
  final String b = strip(right.name, 'right');
  final String base = a.toLowerCase() == b.toLowerCase() ? a : left.name;
  return base.isEmpty ? left.name : base[0].toUpperCase() + base.substring(1);
}
