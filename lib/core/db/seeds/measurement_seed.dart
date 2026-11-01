import '../../models/enums.dart';
import '../../models/measurement.dart';
import '../repositories/seed_repository.dart';

// PURE DART.

/// The measurement fields every install starts with. Ids are stable (a backup
/// merges by them); names are sentence case and the user may rename them.
/// Metric: lengths in cm, weight in kg, body fat in percent.
abstract final class MeasurementSeed {
  static final DateTime _epoch = DateTime.utc(2026);

  static MeasurementField _f(
    int position,
    String id,
    String name,
    MeasurementUnitType unit, {
    BodyAnchor? anchor,
    BodySide side = BodySide.none,
    String? pairId,
  }) => MeasurementField(
    id: id,
    name: name,
    unitType: unit,
    side: side,
    pairId: pairId,
    bodyAnchor: anchor,
    position: position,
    builtIn: true,
    updatedAt: _epoch,
  );

  static final List<MeasurementField> builtIns = <MeasurementField>[
    _f(0, 'weight', 'Weight', MeasurementUnitType.mass),
    _f(1, 'height', 'Height', MeasurementUnitType.length),
    _f(2, 'neck', 'Neck', MeasurementUnitType.length, anchor: BodyAnchor.neck),
    _f(
      3,
      'shoulders',
      'Shoulders',
      MeasurementUnitType.length,
      anchor: BodyAnchor.shoulders,
    ),
    _f(
      4,
      'chest',
      'Chest',
      MeasurementUnitType.length,
      anchor: BodyAnchor.chest,
    ),
    _f(
      5,
      'bicep-left',
      'Left bicep',
      MeasurementUnitType.length,
      anchor: BodyAnchor.upperArm,
      side: BodySide.left,
      pairId: 'bicep',
    ),
    _f(
      6,
      'bicep-right',
      'Right bicep',
      MeasurementUnitType.length,
      anchor: BodyAnchor.upperArm,
      side: BodySide.right,
      pairId: 'bicep',
    ),
    _f(
      7,
      'forearm-left',
      'Left forearm',
      MeasurementUnitType.length,
      anchor: BodyAnchor.forearm,
      side: BodySide.left,
      pairId: 'forearm',
    ),
    _f(
      8,
      'forearm-right',
      'Right forearm',
      MeasurementUnitType.length,
      anchor: BodyAnchor.forearm,
      side: BodySide.right,
      pairId: 'forearm',
    ),
    _f(
      9,
      'waist',
      'Waist',
      MeasurementUnitType.length,
      anchor: BodyAnchor.waist,
    ),
    _f(
      10,
      'above-navel',
      '2in above navel',
      MeasurementUnitType.length,
      anchor: BodyAnchor.aboveNavel,
    ),
    _f(
      11,
      'below-navel',
      '2in below navel',
      MeasurementUnitType.length,
      anchor: BodyAnchor.belowNavel,
    ),
    _f(12, 'hips', 'Hips', MeasurementUnitType.length, anchor: BodyAnchor.hips),
    _f(
      13,
      'thigh-left',
      'Left thigh',
      MeasurementUnitType.length,
      anchor: BodyAnchor.thigh,
      side: BodySide.left,
      pairId: 'thigh',
    ),
    _f(
      14,
      'thigh-right',
      'Right thigh',
      MeasurementUnitType.length,
      anchor: BodyAnchor.thigh,
      side: BodySide.right,
      pairId: 'thigh',
    ),
    _f(
      15,
      'calf-left',
      'Left calf',
      MeasurementUnitType.length,
      anchor: BodyAnchor.calf,
      side: BodySide.left,
      pairId: 'calf',
    ),
    _f(
      16,
      'calf-right',
      'Right calf',
      MeasurementUnitType.length,
      anchor: BodyAnchor.calf,
      side: BodySide.right,
      pairId: 'calf',
    ),
    _f(17, 'body-fat', 'Body fat', MeasurementUnitType.percent),
  ];

  /// Inserts the built-ins that are missing. Safe to call on every start.
  /// Returns how many were inserted.
  static Future<int> seed(SeedRepository repository) =>
      repository.insertMissingMeasurementFields(builtIns);
}
