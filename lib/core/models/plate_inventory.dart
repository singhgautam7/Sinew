import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'plate_inventory.freezed.dart';
part 'plate_inventory.g.dart';

/// The bars and plates the user owns, for plate math. Stored as JSON, so it
/// carries its own [schemaVersion]. Weights are kilograms; [unit] is the unit
/// the plates are labelled in (a 45 lb plate is stored as 20.4117 kg).
@freezed
abstract class PlateInventory with _$PlateInventory {
  const factory PlateInventory({
    @Default(PlateInventory.currentSchemaVersion) int schemaVersion,
    @Default(<Bar>[]) List<Bar> bars,
    @Default(<PlateStock>[]) List<PlateStock> plates,
    @Default(WeightUnit.kg) WeightUnit unit,

    /// Machine weight-stack increment, kilograms.
    @Default(5.0) double machineStepKg,
    DateTime? updatedAt,
  }) = _PlateInventory;

  factory PlateInventory.fromJson(Map<String, dynamic> json) =>
      _$PlateInventoryFromJson(json);

  static const int currentSchemaVersion = 1;

  /// A sensible metric gym before the user edits anything.
  static const PlateInventory metricDefault = PlateInventory(
    bars: <Bar>[
      Bar(name: 'Olympic bar', weightKg: 20),
      Bar(name: "Women's bar", weightKg: 15),
      Bar(name: 'EZ bar', weightKg: 10),
      Bar(name: 'Dumbbell handle', weightKg: 2, isDumbbell: true),
    ],
    plates: <PlateStock>[
      PlateStock(weightKg: 25, count: 2),
      PlateStock(weightKg: 20, count: 4),
      PlateStock(weightKg: 15, count: 2),
      PlateStock(weightKg: 10, count: 4),
      PlateStock(weightKg: 5, count: 4),
      PlateStock(weightKg: 2.5, count: 4),
      PlateStock(weightKg: 1.25, count: 4),
    ],
  );
}

@freezed
abstract class Bar with _$Bar {
  const factory Bar({
    required String name,
    required double weightKg,
    @Default(false) bool isDumbbell,
  }) = _Bar;

  factory Bar.fromJson(Map<String, dynamic> json) => _$BarFromJson(json);
}

/// [count] is the total number of plates of this weight (both sides).
@freezed
abstract class PlateStock with _$PlateStock {
  const factory PlateStock({required double weightKg, required int count}) =
      _PlateStock;

  factory PlateStock.fromJson(Map<String, dynamic> json) =>
      _$PlateStockFromJson(json);
}
