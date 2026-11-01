// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plate_inventory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlateInventory {

 int get schemaVersion; List<Bar> get bars; List<PlateStock> get plates; WeightUnit get unit;/// Machine weight-stack increment, kilograms.
 double get machineStepKg;@NullableUtcDateTimeConverter() DateTime? get updatedAt;
/// Create a copy of PlateInventory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlateInventoryCopyWith<PlateInventory> get copyWith => _$PlateInventoryCopyWithImpl<PlateInventory>(this as PlateInventory, _$identity);

  /// Serializes this PlateInventory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlateInventory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlateInventory&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&const DeepCollectionEquality().equals(other.bars, _this.bars)&&const DeepCollectionEquality().equals(other.plates, _this.plates)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.machineStepKg, _this.machineStepKg) || other.machineStepKg == _this.machineStepKg)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlateInventory;
  return Object.hash(runtimeType,_this.schemaVersion,const DeepCollectionEquality().hash(_this.bars),const DeepCollectionEquality().hash(_this.plates),_this.unit,_this.machineStepKg,_this.updatedAt);
}

@override
String toString() {
  final _this = this as PlateInventory;
  return 'PlateInventory(schemaVersion: ${_this.schemaVersion}, bars: ${_this.bars}, plates: ${_this.plates}, unit: ${_this.unit}, machineStepKg: ${_this.machineStepKg}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $PlateInventoryCopyWith<$Res>  {
  factory $PlateInventoryCopyWith(PlateInventory value, $Res Function(PlateInventory) _then) = _$PlateInventoryCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, List<Bar> bars, List<PlateStock> plates, WeightUnit unit, double machineStepKg,@NullableUtcDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$PlateInventoryCopyWithImpl<$Res>
    implements $PlateInventoryCopyWith<$Res> {
  _$PlateInventoryCopyWithImpl(this._self, this._then);

  final PlateInventory _self;
  final $Res Function(PlateInventory) _then;

/// Create a copy of PlateInventory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? bars = null,Object? plates = null,Object? unit = null,Object? machineStepKg = null,Object? updatedAt = freezed,}) {
  return _then(PlateInventory(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,bars: null == bars ? _self.bars : bars // ignore: cast_nullable_to_non_nullable
as List<Bar>,plates: null == plates ? _self.plates : plates // ignore: cast_nullable_to_non_nullable
as List<PlateStock>,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as WeightUnit,machineStepKg: null == machineStepKg ? _self.machineStepKg : machineStepKg // ignore: cast_nullable_to_non_nullable
as double,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlateInventory].
extension PlateInventoryPatterns on PlateInventory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlateInventory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlateInventory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlateInventory value)  $default,){
final _that = this;
switch (_that) {
case _PlateInventory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlateInventory value)?  $default,){
final _that = this;
switch (_that) {
case _PlateInventory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  List<Bar> bars,  List<PlateStock> plates,  WeightUnit unit,  double machineStepKg, @NullableUtcDateTimeConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlateInventory() when $default != null:
return $default(_that.schemaVersion,_that.bars,_that.plates,_that.unit,_that.machineStepKg,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  List<Bar> bars,  List<PlateStock> plates,  WeightUnit unit,  double machineStepKg, @NullableUtcDateTimeConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PlateInventory():
return $default(_that.schemaVersion,_that.bars,_that.plates,_that.unit,_that.machineStepKg,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  List<Bar> bars,  List<PlateStock> plates,  WeightUnit unit,  double machineStepKg, @NullableUtcDateTimeConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlateInventory() when $default != null:
return $default(_that.schemaVersion,_that.bars,_that.plates,_that.unit,_that.machineStepKg,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlateInventory implements PlateInventory {
  const _PlateInventory({this.schemaVersion = PlateInventory.currentSchemaVersion,  List<Bar> bars = const <Bar>[],  List<PlateStock> plates = const <PlateStock>[], this.unit = WeightUnit.kg, this.machineStepKg = 5.0, @NullableUtcDateTimeConverter() this.updatedAt}): _bars = bars,_plates = plates;
  factory _PlateInventory.fromJson(Map<String, dynamic> json) => _$PlateInventoryFromJson(json);

@override@JsonKey() final  int schemaVersion;
 final  List<Bar> _bars;
@override@JsonKey() List<Bar> get bars {
  if (_bars is EqualUnmodifiableListView) return _bars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bars);
}

 final  List<PlateStock> _plates;
@override@JsonKey() List<PlateStock> get plates {
  if (_plates is EqualUnmodifiableListView) return _plates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plates);
}

@override@JsonKey() final  WeightUnit unit;
/// Machine weight-stack increment, kilograms.
@override@JsonKey() final  double machineStepKg;
@override@NullableUtcDateTimeConverter() final  DateTime? updatedAt;

/// Create a copy of PlateInventory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlateInventoryCopyWith<_PlateInventory> get copyWith => __$PlateInventoryCopyWithImpl<_PlateInventory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlateInventoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlateInventory&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&const DeepCollectionEquality().equals(other.bars, _bars)&&const DeepCollectionEquality().equals(other.plates, _plates)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.machineStepKg, machineStepKg) || other.machineStepKg == machineStepKg)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,const DeepCollectionEquality().hash(_bars),const DeepCollectionEquality().hash(_plates),unit,machineStepKg,updatedAt);
}

@override
String toString() {
    return 'PlateInventory(schemaVersion: $schemaVersion, bars: $bars, plates: $plates, unit: $unit, machineStepKg: $machineStepKg, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PlateInventoryCopyWith<$Res> implements $PlateInventoryCopyWith<$Res> {
  factory _$PlateInventoryCopyWith(_PlateInventory value, $Res Function(_PlateInventory) _then) = __$PlateInventoryCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, List<Bar> bars, List<PlateStock> plates, WeightUnit unit, double machineStepKg,@NullableUtcDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$PlateInventoryCopyWithImpl<$Res>
    implements _$PlateInventoryCopyWith<$Res> {
  __$PlateInventoryCopyWithImpl(this._self, this._then);

  final _PlateInventory _self;
  final $Res Function(_PlateInventory) _then;

/// Create a copy of PlateInventory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? bars = null,Object? plates = null,Object? unit = null,Object? machineStepKg = null,Object? updatedAt = freezed,}) {
  return _then(_PlateInventory(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,bars: null == bars ? _self._bars : bars // ignore: cast_nullable_to_non_nullable
as List<Bar>,plates: null == plates ? _self._plates : plates // ignore: cast_nullable_to_non_nullable
as List<PlateStock>,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as WeightUnit,machineStepKg: null == machineStepKg ? _self.machineStepKg : machineStepKg // ignore: cast_nullable_to_non_nullable
as double,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Bar {

 String get name; double get weightKg; bool get isDumbbell;
/// Create a copy of Bar
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarCopyWith<Bar> get copyWith => _$BarCopyWithImpl<Bar>(this as Bar, _$identity);

  /// Serializes this Bar to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Bar;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bar&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.isDumbbell, _this.isDumbbell) || other.isDumbbell == _this.isDumbbell));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Bar;
  return Object.hash(runtimeType,_this.name,_this.weightKg,_this.isDumbbell);
}

@override
String toString() {
  final _this = this as Bar;
  return 'Bar(name: ${_this.name}, weightKg: ${_this.weightKg}, isDumbbell: ${_this.isDumbbell})';
}


}

/// @nodoc
abstract mixin class $BarCopyWith<$Res>  {
  factory $BarCopyWith(Bar value, $Res Function(Bar) _then) = _$BarCopyWithImpl;
@useResult
$Res call({
 String name, double weightKg, bool isDumbbell
});




}
/// @nodoc
class _$BarCopyWithImpl<$Res>
    implements $BarCopyWith<$Res> {
  _$BarCopyWithImpl(this._self, this._then);

  final Bar _self;
  final $Res Function(Bar) _then;

/// Create a copy of Bar
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? weightKg = null,Object? isDumbbell = null,}) {
  return _then(Bar(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,isDumbbell: null == isDumbbell ? _self.isDumbbell : isDumbbell // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Bar].
extension BarPatterns on Bar {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bar value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bar() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bar value)  $default,){
final _that = this;
switch (_that) {
case _Bar():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bar value)?  $default,){
final _that = this;
switch (_that) {
case _Bar() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double weightKg,  bool isDumbbell)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bar() when $default != null:
return $default(_that.name,_that.weightKg,_that.isDumbbell);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double weightKg,  bool isDumbbell)  $default,) {final _that = this;
switch (_that) {
case _Bar():
return $default(_that.name,_that.weightKg,_that.isDumbbell);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double weightKg,  bool isDumbbell)?  $default,) {final _that = this;
switch (_that) {
case _Bar() when $default != null:
return $default(_that.name,_that.weightKg,_that.isDumbbell);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bar implements Bar {
  const _Bar({required this.name, required this.weightKg, this.isDumbbell = false});
  factory _Bar.fromJson(Map<String, dynamic> json) => _$BarFromJson(json);

@override final  String name;
@override final  double weightKg;
@override@JsonKey() final  bool isDumbbell;

/// Create a copy of Bar
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BarCopyWith<_Bar> get copyWith => __$BarCopyWithImpl<_Bar>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BarToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bar&&(identical(other.name, name) || other.name == name)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.isDumbbell, isDumbbell) || other.isDumbbell == isDumbbell));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,weightKg,isDumbbell);
}

@override
String toString() {
    return 'Bar(name: $name, weightKg: $weightKg, isDumbbell: $isDumbbell)';
}


}

/// @nodoc
abstract mixin class _$BarCopyWith<$Res> implements $BarCopyWith<$Res> {
  factory _$BarCopyWith(_Bar value, $Res Function(_Bar) _then) = __$BarCopyWithImpl;
@override @useResult
$Res call({
 String name, double weightKg, bool isDumbbell
});




}
/// @nodoc
class __$BarCopyWithImpl<$Res>
    implements _$BarCopyWith<$Res> {
  __$BarCopyWithImpl(this._self, this._then);

  final _Bar _self;
  final $Res Function(_Bar) _then;

/// Create a copy of Bar
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? weightKg = null,Object? isDumbbell = null,}) {
  return _then(_Bar(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,isDumbbell: null == isDumbbell ? _self.isDumbbell : isDumbbell // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PlateStock {

 double get weightKg; int get count;
/// Create a copy of PlateStock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlateStockCopyWith<PlateStock> get copyWith => _$PlateStockCopyWithImpl<PlateStock>(this as PlateStock, _$identity);

  /// Serializes this PlateStock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlateStock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlateStock&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.count, _this.count) || other.count == _this.count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlateStock;
  return Object.hash(runtimeType,_this.weightKg,_this.count);
}

@override
String toString() {
  final _this = this as PlateStock;
  return 'PlateStock(weightKg: ${_this.weightKg}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $PlateStockCopyWith<$Res>  {
  factory $PlateStockCopyWith(PlateStock value, $Res Function(PlateStock) _then) = _$PlateStockCopyWithImpl;
@useResult
$Res call({
 double weightKg, int count
});




}
/// @nodoc
class _$PlateStockCopyWithImpl<$Res>
    implements $PlateStockCopyWith<$Res> {
  _$PlateStockCopyWithImpl(this._self, this._then);

  final PlateStock _self;
  final $Res Function(PlateStock) _then;

/// Create a copy of PlateStock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weightKg = null,Object? count = null,}) {
  return _then(PlateStock(
weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlateStock].
extension PlateStockPatterns on PlateStock {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlateStock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlateStock() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlateStock value)  $default,){
final _that = this;
switch (_that) {
case _PlateStock():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlateStock value)?  $default,){
final _that = this;
switch (_that) {
case _PlateStock() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double weightKg,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlateStock() when $default != null:
return $default(_that.weightKg,_that.count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double weightKg,  int count)  $default,) {final _that = this;
switch (_that) {
case _PlateStock():
return $default(_that.weightKg,_that.count);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double weightKg,  int count)?  $default,) {final _that = this;
switch (_that) {
case _PlateStock() when $default != null:
return $default(_that.weightKg,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlateStock implements PlateStock {
  const _PlateStock({required this.weightKg, required this.count});
  factory _PlateStock.fromJson(Map<String, dynamic> json) => _$PlateStockFromJson(json);

@override final  double weightKg;
@override final  int count;

/// Create a copy of PlateStock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlateStockCopyWith<_PlateStock> get copyWith => __$PlateStockCopyWithImpl<_PlateStock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlateStockToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlateStock&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,weightKg,count);
}

@override
String toString() {
    return 'PlateStock(weightKg: $weightKg, count: $count)';
}


}

/// @nodoc
abstract mixin class _$PlateStockCopyWith<$Res> implements $PlateStockCopyWith<$Res> {
  factory _$PlateStockCopyWith(_PlateStock value, $Res Function(_PlateStock) _then) = __$PlateStockCopyWithImpl;
@override @useResult
$Res call({
 double weightKg, int count
});




}
/// @nodoc
class __$PlateStockCopyWithImpl<$Res>
    implements _$PlateStockCopyWith<$Res> {
  __$PlateStockCopyWithImpl(this._self, this._then);

  final _PlateStock _self;
  final $Res Function(_PlateStock) _then;

/// Create a copy of PlateStock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weightKg = null,Object? count = null,}) {
  return _then(_PlateStock(
weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
