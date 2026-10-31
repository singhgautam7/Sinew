// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plate_inventory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlateInventory _$PlateInventoryFromJson(
  Map<String, dynamic> json,
) => _PlateInventory(
  schemaVersion:
      (json['schemaVersion'] as num?)?.toInt() ??
      PlateInventory.currentSchemaVersion,
  bars:
      (json['bars'] as List<dynamic>?)
          ?.map((e) => Bar.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Bar>[],
  plates:
      (json['plates'] as List<dynamic>?)
          ?.map((e) => PlateStock.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PlateStock>[],
  unit: $enumDecodeNullable(_$WeightUnitEnumMap, json['unit']) ?? WeightUnit.kg,
  machineStepKg: (json['machineStepKg'] as num?)?.toDouble() ?? 5.0,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PlateInventoryToJson(_PlateInventory instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'bars': instance.bars,
      'plates': instance.plates,
      'unit': _$WeightUnitEnumMap[instance.unit]!,
      'machineStepKg': instance.machineStepKg,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$WeightUnitEnumMap = {WeightUnit.kg: 'kg', WeightUnit.lb: 'lb'};

_Bar _$BarFromJson(Map<String, dynamic> json) => _Bar(
  name: json['name'] as String,
  weightKg: (json['weightKg'] as num).toDouble(),
  isDumbbell: json['isDumbbell'] as bool? ?? false,
);

Map<String, dynamic> _$BarToJson(_Bar instance) => <String, dynamic>{
  'name': instance.name,
  'weightKg': instance.weightKg,
  'isDumbbell': instance.isDumbbell,
};

_PlateStock _$PlateStockFromJson(Map<String, dynamic> json) => _PlateStock(
  weightKg: (json['weightKg'] as num).toDouble(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$PlateStockToJson(_PlateStock instance) =>
    <String, dynamic>{'weightKg': instance.weightKg, 'count': instance.count};
