// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeasurementField _$MeasurementFieldFromJson(Map<String, dynamic> json) =>
    _MeasurementField(
      id: json['id'] as String,
      name: json['name'] as String,
      unitType: $enumDecode(_$MeasurementUnitTypeEnumMap, json['unitType']),
      customUnit: json['customUnit'] as String?,
      side:
          $enumDecodeNullable(_$BodySideEnumMap, json['side']) ?? BodySide.none,
      pairId: json['pairId'] as String?,
      bodyAnchor: $enumDecodeNullable(_$BodyAnchorEnumMap, json['bodyAnchor']),
      enabled: json['enabled'] as bool? ?? true,
      position: (json['position'] as num?)?.toInt() ?? 0,
      builtIn: json['builtIn'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MeasurementFieldToJson(_MeasurementField instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unitType': _$MeasurementUnitTypeEnumMap[instance.unitType]!,
      'customUnit': instance.customUnit,
      'side': _$BodySideEnumMap[instance.side]!,
      'pairId': instance.pairId,
      'bodyAnchor': _$BodyAnchorEnumMap[instance.bodyAnchor],
      'enabled': instance.enabled,
      'position': instance.position,
      'builtIn': instance.builtIn,
      'archived': instance.archived,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$MeasurementUnitTypeEnumMap = {
  MeasurementUnitType.length: 'length',
  MeasurementUnitType.mass: 'mass',
  MeasurementUnitType.percent: 'percent',
  MeasurementUnitType.count: 'count',
  MeasurementUnitType.custom: 'custom',
};

const _$BodySideEnumMap = {
  BodySide.none: 'none',
  BodySide.left: 'left',
  BodySide.right: 'right',
};

const _$BodyAnchorEnumMap = {
  BodyAnchor.neck: 'neck',
  BodyAnchor.shoulders: 'shoulders',
  BodyAnchor.chest: 'chest',
  BodyAnchor.upperArm: 'upperArm',
  BodyAnchor.forearm: 'forearm',
  BodyAnchor.aboveNavel: 'aboveNavel',
  BodyAnchor.waist: 'waist',
  BodyAnchor.belowNavel: 'belowNavel',
  BodyAnchor.hips: 'hips',
  BodyAnchor.thigh: 'thigh',
  BodyAnchor.calf: 'calf',
};

_MeasurementEntry _$MeasurementEntryFromJson(Map<String, dynamic> json) =>
    _MeasurementEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      values:
          (json['values'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const <String, double>{},
      note: json['note'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MeasurementEntryToJson(_MeasurementEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'values': instance.values,
      'note': instance.note,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
