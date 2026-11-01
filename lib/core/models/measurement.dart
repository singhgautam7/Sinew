import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'utc_date_time.dart';

part 'measurement.freezed.dart';
part 'measurement.g.dart';

/// A body measurement the user tracks. Built-in fields are seeded on first
/// run; users rename, disable, reorder and add their own. A field with data is
/// archived, never destroyed.
@freezed
abstract class MeasurementField with _$MeasurementField {
  const factory MeasurementField({
    required String id,
    required String name,
    required MeasurementUnitType unitType,

    /// Label for [MeasurementUnitType.custom] only.
    String? customUnit,
    @Default(BodySide.none) BodySide side,

    /// Left and right of one measurement share a pair id.
    String? pairId,
    BodyAnchor? bodyAnchor,
    @Default(true) bool enabled,
    @Default(0) int position,
    @Default(false) bool builtIn,
    @Default(false) bool archived,
    @UtcDateTimeConverter() required DateTime updatedAt,
  }) = _MeasurementField;

  factory MeasurementField.fromJson(Map<String, dynamic> json) =>
      _$MeasurementFieldFromJson(json);
}

/// One day's measurements. [values] maps field id to a metric value
/// (cm, kg, percent, count or the custom unit).
@freezed
abstract class MeasurementEntry with _$MeasurementEntry {
  const factory MeasurementEntry({
    required String id,
    @UtcDateTimeConverter() required DateTime date,
    @Default(<String, double>{}) Map<String, double> values,
    String? note,
    @UtcDateTimeConverter() required DateTime updatedAt,
  }) = _MeasurementEntry;

  factory MeasurementEntry.fromJson(Map<String, dynamic> json) =>
      _$MeasurementEntryFromJson(json);
}
