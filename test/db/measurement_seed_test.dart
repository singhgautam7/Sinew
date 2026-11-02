import 'package:flutter_test/flutter_test.dart';
import 'package:sinew/core/db/repositories/measurement_repository.dart';
import 'package:sinew/core/db/repositories/seed_repository.dart';
import 'package:sinew/core/db/seeds/measurement_seed.dart';
import 'package:sinew/core/db/user/user_db.dart';
import 'package:sinew/core/models/enums.dart';
import 'package:sinew/core/models/measurement.dart';

import '../helpers/test_db.dart';

void main() {
  late UserDatabase db;
  late SeedRepository seeds;
  late MeasurementRepository measurements;

  setUp(() {
    db = memoryUserDb();
    seeds = SeedRepository(db);
    measurements = MeasurementRepository(db);
  });
  tearDown(() => db.close());

  test('first run inserts the 18 built-ins with stable ids', () async {
    expect(await MeasurementSeed.seed(seeds), 18);
    final List<MeasurementField> fields = await measurements.fields();
    expect(fields.map((MeasurementField f) => f.id), <String>[
      'weight',
      'height',
      'neck',
      'shoulders',
      'chest',
      'bicep-left',
      'bicep-right',
      'forearm-left',
      'forearm-right',
      'waist',
      'above-navel',
      'below-navel',
      'hips',
      'thigh-left',
      'thigh-right',
      'calf-left',
      'calf-right',
      'body-fat',
    ]);
    expect(
      fields.every((MeasurementField f) => f.builtIn && f.enabled),
      isTrue,
    );
    final Map<String, MeasurementField> by = <String, MeasurementField>{
      for (final MeasurementField f in fields) f.id: f,
    };
    expect(by['weight']!.unitType, MeasurementUnitType.mass);
    expect(by['height']!.unitType, MeasurementUnitType.length);
    expect(by['body-fat']!.unitType, MeasurementUnitType.percent);
    expect(by['bicep-left']!.side, BodySide.left);
    expect(by['bicep-right']!.side, BodySide.right);
    expect(by['bicep-left']!.pairId, 'bicep');
    expect(by['bicep-left']!.bodyAnchor, BodyAnchor.upperArm);
    expect(by['above-navel']!.name, '2in above navel');
    expect(by['above-navel']!.bodyAnchor, BodyAnchor.aboveNavel);
    expect(by['below-navel']!.bodyAnchor, BodyAnchor.belowNavel);
    expect(by['calf-right']!.pairId, 'calf');
    expect(by['weight']!.bodyAnchor, isNull);
  });

  test(
    'idempotent: a second run inserts nothing and keeps user changes',
    () async {
      await MeasurementSeed.seed(seeds);
      final MeasurementField chest = (await measurements.fields()).firstWhere(
        (MeasurementField f) => f.id == 'chest',
      );
      await measurements.saveField(
        chest.copyWith(name: 'Rib cage', enabled: false),
      );
      await measurements.reorderFields(<String>['waist', 'chest']);
      final List<MeasurementField> before = await measurements.fields(
        includeArchived: true,
      );

      expect(await MeasurementSeed.seed(seeds), 0);
      expect(await MeasurementSeed.seed(seeds), 0);

      final List<MeasurementField> after = await measurements.fields(
        includeArchived: true,
      );
      expect(after.length, 18);
      expect(after, before);
      expect(
        after.firstWhere((MeasurementField f) => f.id == 'chest').name,
        'Rib cage',
      );
    },
  );

  test(
    'archived stays archived and a deleted built-in stays deleted',
    () async {
      await MeasurementSeed.seed(seeds);
      await measurements.saveField(
        (await measurements.fields())
            .firstWhere((MeasurementField f) => f.id == 'neck')
            .copyWith(archived: true),
      );
      expect(await measurements.removeField('hips'), FieldRemoval.deleted);
      expect(await MeasurementSeed.seed(seeds), 0);
      final List<MeasurementField> all = await measurements.fields(
        includeArchived: true,
      );
      expect(all.length, 17);
      expect(
        all.firstWhere((MeasurementField f) => f.id == 'neck').archived,
        isTrue,
      );
    },
  );

  test('a built-in added by a later version is inserted', () async {
    await MeasurementSeed.seed(seeds);
    final MeasurementField extra = MeasurementSeed.builtIns.first.copyWith(
      id: 'resting-hr',
      name: 'Resting heart rate',
    );
    expect(
      await seeds.insertMissingMeasurementFields(<MeasurementField>[
        ...MeasurementSeed.builtIns,
        extra,
      ]),
      1,
    );
    expect((await measurements.fields()).length, 19);
  });

  test('existing rows are never overwritten', () async {
    await measurements.saveField(
      MeasurementSeed.builtIns[4].copyWith(name: 'My chest'),
    );
    expect(await MeasurementSeed.seed(seeds), 17);
    expect(
      (await measurements.fields())
          .firstWhere((MeasurementField f) => f.id == 'chest')
          .name,
      'My chest',
    );
  });
}
