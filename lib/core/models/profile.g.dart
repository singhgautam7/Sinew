// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  sex: $enumDecodeNullable(_$SexEnumMap, json['sex']),
  birthYear: (json['birthYear'] as num?)?.toInt(),
  heightCm: (json['heightCm'] as num?)?.toDouble(),
  activityLevel:
      $enumDecodeNullable(_$ActivityLevelEnumMap, json['activityLevel']) ??
      ActivityLevel.moderate,
  weightUnit:
      $enumDecodeNullable(_$WeightUnitEnumMap, json['weightUnit']) ??
      WeightUnit.kg,
  lengthUnit:
      $enumDecodeNullable(_$LengthUnitEnumMap, json['lengthUnit']) ??
      LengthUnit.cm,
  distanceUnit:
      $enumDecodeNullable(_$DistanceUnitEnumMap, json['distanceUnit']) ??
      DistanceUnit.km,
  bmiCutoffs:
      $enumDecodeNullable(_$BmiCutoffsEnumMap, json['bmiCutoffs']) ??
      BmiCutoffs.who,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'sex': _$SexEnumMap[instance.sex],
  'birthYear': instance.birthYear,
  'heightCm': instance.heightCm,
  'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel]!,
  'weightUnit': _$WeightUnitEnumMap[instance.weightUnit]!,
  'lengthUnit': _$LengthUnitEnumMap[instance.lengthUnit]!,
  'distanceUnit': _$DistanceUnitEnumMap[instance.distanceUnit]!,
  'bmiCutoffs': _$BmiCutoffsEnumMap[instance.bmiCutoffs]!,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$SexEnumMap = {Sex.male: 'male', Sex.female: 'female'};

const _$ActivityLevelEnumMap = {
  ActivityLevel.sedentary: 'sedentary',
  ActivityLevel.light: 'light',
  ActivityLevel.moderate: 'moderate',
  ActivityLevel.veryActive: 'veryActive',
  ActivityLevel.extraActive: 'extraActive',
};

const _$WeightUnitEnumMap = {WeightUnit.kg: 'kg', WeightUnit.lb: 'lb'};

const _$LengthUnitEnumMap = {LengthUnit.cm: 'cm', LengthUnit.inch: 'inch'};

const _$DistanceUnitEnumMap = {DistanceUnit.km: 'km', DistanceUnit.mi: 'mi'};

const _$BmiCutoffsEnumMap = {BmiCutoffs.who: 'who', BmiCutoffs.asian: 'asian'};
