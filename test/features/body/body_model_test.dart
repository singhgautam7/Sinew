import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/seeds/measurement_seed.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/measurement.dart';
import 'package:sinew/core/models/profile.dart';
import 'package:sinew/features/body/body_model.dart';

MeasurementEntry _e(String id, DateTime d, Map<String, double> v) =>
    MeasurementEntry(id: id, date: d, values: v, updatedAt: d);

void main() {
  final List<MeasurementEntry> entries = <MeasurementEntry>[
    _e('3', DateTime(2026, 10, 30), <String, double>{'waist': 84}),
    _e('2', DateTime(2026, 10, 24), <String, double>{
      'waist': 85,
      'weight': 79,
    }),
    _e('1', DateTime(2026, 1, 1), <String, double>{'waist': 92, 'weight': 85}),
  ];

  test('valuesAsOf takes each field from its newest entry up to a date', () {
    final Map<String, DatedValue> now = valuesAsOf(entries);
    expect(now['waist']!.value, 84);
    expect(now['weight']!.value, 79);
    final Map<String, DatedValue> then = valuesAsOf(
      entries,
      upTo: DateTime(2026, 6, 1),
    );
    expect(then['waist']!.value, 92);
    expect(then['weight']!.value, 85);
  });

  test('latestWithPrevious pairs the newest value with the one before', () {
    final Map<String, LatestValue> l = latestWithPrevious(entries);
    expect(l['waist']!.delta, -1);
    expect(l['weight']!.delta, -6);
    expect(l['waist']!.previous!.date, DateTime(2026, 10, 24));
  });

  test('height comes from the profile unless a later entry logs it', () {
    const Profile p = Profile(heightCm: 178);
    expect(resolveHeightCm(const <String, DatedValue>{}, p), 178);
    final Map<String, DatedValue> logged = <String, DatedValue>{
      'height': (value: 180, date: DateTime(2026, 10, 1)),
    };
    // No profile date: the profile wins.
    expect(resolveHeightCm(logged, p), 178);
    expect(
      resolveHeightCm(logged, p.copyWith(updatedAt: DateTime(2026, 9, 1))),
      180,
    );
    expect(resolveHeightCm(logged, const Profile()), 180);
  });

  test('pairs group left and right into one row at the first position', () {
    final List<MeasurementField> fields = MeasurementSeed.builtIns;
    final List<FormRowSpec> rows = groupFormRows(fields);
    // 18 fields, four pairs (bicep, forearm, thigh, calf) merge: 18 - 4.
    expect(rows, hasLength(14));
    final FormRowSpec bicep = rows.firstWhere(
      (FormRowSpec r) => r.isPair && r.left!.id == 'bicep-left',
    );
    expect(pairName(bicep.left!, bicep.right!), 'Bicep');
  });

  test('a pair with one side hidden stays a single row', () {
    final List<MeasurementField> fields = MeasurementSeed.builtIns
        .where((MeasurementField f) => f.id != 'thigh-right')
        .toList();
    final List<FormRowSpec> rows = groupFormRows(fields);
    expect(
      rows.any((FormRowSpec r) => !r.isPair && r.field!.id == 'thigh-left'),
      isTrue,
    );
  });

  test('silhouette input averages the two sides and skips non-length', () {
    final Map<String, DatedValue> v = <String, DatedValue>{
      'bicep-left': (value: 34, date: DateTime(2026, 10, 1)),
      'bicep-right': (value: 33, date: DateTime(2026, 10, 1)),
      'weight': (value: 80, date: DateTime(2026, 10, 1)),
    };
    final input = silhouetteInputFor(
      MeasurementSeed.builtIns,
      v,
      const Profile(sex: Sex.female, heightCm: 165),
    );
    expect(input.measurements[BodyAnchor.upperArm], 33.5);
    expect(input.measurements.length, 1);
    expect(input.heightCm, 165);
    expect(input.sex, Sex.female);
  });

  test('formFields keeps a disabled field that already has a value', () {
    final List<MeasurementField> fields = <MeasurementField>[
      for (final MeasurementField f in MeasurementSeed.builtIns)
        f.id == 'neck' || f.id == 'chest' ? f.copyWith(enabled: false) : f,
    ];
    final List<String> ids = formFields(fields, <String, double>{
      'neck': 39,
    }).map((MeasurementField f) => f.id).toList();
    expect(ids, contains('neck'));
    expect(ids, isNot(contains('chest')));
  });
}
