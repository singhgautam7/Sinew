// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {

 String get id; String get name; List<String> get aliases; String? get sanskritName; String get category; String? get subcategory;@JsonKey(unknownEnumValue: TrackingType.unknown) TrackingType get trackingType; List<String> get primaryMuscles; List<String> get secondaryMuscles; List<String> get equipment; Difficulty? get difficulty; bool get unilateral; String? get mechanic; String? get force; List<String> get steps; List<String> get tips; List<String> get commonMistakes; List<String> get safetyNotes; List<String> get contraindications; double? get metValue; int? get defaultRestSec; int? get defaultHoldSec; String? get variationOf; List<String> get tags; String? get source; String? get license; bool get isCustom;/// Custom exercises only: hidden from pickers but kept for history.
 bool get archived;@NullableUtcDateTimeConverter() DateTime? get createdAt;@NullableUtcDateTimeConverter() DateTime? get updatedAt;
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseCopyWith<Exercise> get copyWith => _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Exercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.aliases, _this.aliases)&&(identical(other.sanskritName, _this.sanskritName) || other.sanskritName == _this.sanskritName)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.subcategory, _this.subcategory) || other.subcategory == _this.subcategory)&&(identical(other.trackingType, _this.trackingType) || other.trackingType == _this.trackingType)&&const DeepCollectionEquality().equals(other.primaryMuscles, _this.primaryMuscles)&&const DeepCollectionEquality().equals(other.secondaryMuscles, _this.secondaryMuscles)&&const DeepCollectionEquality().equals(other.equipment, _this.equipment)&&(identical(other.difficulty, _this.difficulty) || other.difficulty == _this.difficulty)&&(identical(other.unilateral, _this.unilateral) || other.unilateral == _this.unilateral)&&(identical(other.mechanic, _this.mechanic) || other.mechanic == _this.mechanic)&&(identical(other.force, _this.force) || other.force == _this.force)&&const DeepCollectionEquality().equals(other.steps, _this.steps)&&const DeepCollectionEquality().equals(other.tips, _this.tips)&&const DeepCollectionEquality().equals(other.commonMistakes, _this.commonMistakes)&&const DeepCollectionEquality().equals(other.safetyNotes, _this.safetyNotes)&&const DeepCollectionEquality().equals(other.contraindications, _this.contraindications)&&(identical(other.metValue, _this.metValue) || other.metValue == _this.metValue)&&(identical(other.defaultRestSec, _this.defaultRestSec) || other.defaultRestSec == _this.defaultRestSec)&&(identical(other.defaultHoldSec, _this.defaultHoldSec) || other.defaultHoldSec == _this.defaultHoldSec)&&(identical(other.variationOf, _this.variationOf) || other.variationOf == _this.variationOf)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.license, _this.license) || other.license == _this.license)&&(identical(other.isCustom, _this.isCustom) || other.isCustom == _this.isCustom)&&(identical(other.archived, _this.archived) || other.archived == _this.archived)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Exercise;
  return Object.hashAll([runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.aliases),_this.sanskritName,_this.category,_this.subcategory,_this.trackingType,const DeepCollectionEquality().hash(_this.primaryMuscles),const DeepCollectionEquality().hash(_this.secondaryMuscles),const DeepCollectionEquality().hash(_this.equipment),_this.difficulty,_this.unilateral,_this.mechanic,_this.force,const DeepCollectionEquality().hash(_this.steps),const DeepCollectionEquality().hash(_this.tips),const DeepCollectionEquality().hash(_this.commonMistakes),const DeepCollectionEquality().hash(_this.safetyNotes),const DeepCollectionEquality().hash(_this.contraindications),_this.metValue,_this.defaultRestSec,_this.defaultHoldSec,_this.variationOf,const DeepCollectionEquality().hash(_this.tags),_this.source,_this.license,_this.isCustom,_this.archived,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as Exercise;
  return 'Exercise(id: ${_this.id}, name: ${_this.name}, aliases: ${_this.aliases}, sanskritName: ${_this.sanskritName}, category: ${_this.category}, subcategory: ${_this.subcategory}, trackingType: ${_this.trackingType}, primaryMuscles: ${_this.primaryMuscles}, secondaryMuscles: ${_this.secondaryMuscles}, equipment: ${_this.equipment}, difficulty: ${_this.difficulty}, unilateral: ${_this.unilateral}, mechanic: ${_this.mechanic}, force: ${_this.force}, steps: ${_this.steps}, tips: ${_this.tips}, commonMistakes: ${_this.commonMistakes}, safetyNotes: ${_this.safetyNotes}, contraindications: ${_this.contraindications}, metValue: ${_this.metValue}, defaultRestSec: ${_this.defaultRestSec}, defaultHoldSec: ${_this.defaultHoldSec}, variationOf: ${_this.variationOf}, tags: ${_this.tags}, source: ${_this.source}, license: ${_this.license}, isCustom: ${_this.isCustom}, archived: ${_this.archived}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res>  {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) = _$ExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> aliases, String? sanskritName, String category, String? subcategory,@JsonKey(unknownEnumValue: TrackingType.unknown) TrackingType trackingType, List<String> primaryMuscles, List<String> secondaryMuscles, List<String> equipment, Difficulty? difficulty, bool unilateral, String? mechanic, String? force, List<String> steps, List<String> tips, List<String> commonMistakes, List<String> safetyNotes, List<String> contraindications, double? metValue, int? defaultRestSec, int? defaultHoldSec, String? variationOf, List<String> tags, String? source, String? license, bool isCustom, bool archived,@NullableUtcDateTimeConverter() DateTime? createdAt,@NullableUtcDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$ExerciseCopyWithImpl<$Res>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? aliases = null,Object? sanskritName = freezed,Object? category = null,Object? subcategory = freezed,Object? trackingType = null,Object? primaryMuscles = null,Object? secondaryMuscles = null,Object? equipment = null,Object? difficulty = freezed,Object? unilateral = null,Object? mechanic = freezed,Object? force = freezed,Object? steps = null,Object? tips = null,Object? commonMistakes = null,Object? safetyNotes = null,Object? contraindications = null,Object? metValue = freezed,Object? defaultRestSec = freezed,Object? defaultHoldSec = freezed,Object? variationOf = freezed,Object? tags = null,Object? source = freezed,Object? license = freezed,Object? isCustom = null,Object? archived = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,aliases: null == aliases ? _self.aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,sanskritName: freezed == sanskritName ? _self.sanskritName : sanskritName // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,trackingType: null == trackingType ? _self.trackingType : trackingType // ignore: cast_nullable_to_non_nullable
as TrackingType,primaryMuscles: null == primaryMuscles ? _self.primaryMuscles : primaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,secondaryMuscles: null == secondaryMuscles ? _self.secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty?,unilateral: null == unilateral ? _self.unilateral : unilateral // ignore: cast_nullable_to_non_nullable
as bool,mechanic: freezed == mechanic ? _self.mechanic : mechanic // ignore: cast_nullable_to_non_nullable
as String?,force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as String?,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<String>,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as List<String>,commonMistakes: null == commonMistakes ? _self.commonMistakes : commonMistakes // ignore: cast_nullable_to_non_nullable
as List<String>,safetyNotes: null == safetyNotes ? _self.safetyNotes : safetyNotes // ignore: cast_nullable_to_non_nullable
as List<String>,contraindications: null == contraindications ? _self.contraindications : contraindications // ignore: cast_nullable_to_non_nullable
as List<String>,metValue: freezed == metValue ? _self.metValue : metValue // ignore: cast_nullable_to_non_nullable
as double?,defaultRestSec: freezed == defaultRestSec ? _self.defaultRestSec : defaultRestSec // ignore: cast_nullable_to_non_nullable
as int?,defaultHoldSec: freezed == defaultHoldSec ? _self.defaultHoldSec : defaultHoldSec // ignore: cast_nullable_to_non_nullable
as int?,variationOf: freezed == variationOf ? _self.variationOf : variationOf // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,license: freezed == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exercise value)  $default,){
final _that = this;
switch (_that) {
case _Exercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exercise value)?  $default,){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> aliases,  String? sanskritName,  String category,  String? subcategory, @JsonKey(unknownEnumValue: TrackingType.unknown)  TrackingType trackingType,  List<String> primaryMuscles,  List<String> secondaryMuscles,  List<String> equipment,  Difficulty? difficulty,  bool unilateral,  String? mechanic,  String? force,  List<String> steps,  List<String> tips,  List<String> commonMistakes,  List<String> safetyNotes,  List<String> contraindications,  double? metValue,  int? defaultRestSec,  int? defaultHoldSec,  String? variationOf,  List<String> tags,  String? source,  String? license,  bool isCustom,  bool archived, @NullableUtcDateTimeConverter()  DateTime? createdAt, @NullableUtcDateTimeConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.aliases,_that.sanskritName,_that.category,_that.subcategory,_that.trackingType,_that.primaryMuscles,_that.secondaryMuscles,_that.equipment,_that.difficulty,_that.unilateral,_that.mechanic,_that.force,_that.steps,_that.tips,_that.commonMistakes,_that.safetyNotes,_that.contraindications,_that.metValue,_that.defaultRestSec,_that.defaultHoldSec,_that.variationOf,_that.tags,_that.source,_that.license,_that.isCustom,_that.archived,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> aliases,  String? sanskritName,  String category,  String? subcategory, @JsonKey(unknownEnumValue: TrackingType.unknown)  TrackingType trackingType,  List<String> primaryMuscles,  List<String> secondaryMuscles,  List<String> equipment,  Difficulty? difficulty,  bool unilateral,  String? mechanic,  String? force,  List<String> steps,  List<String> tips,  List<String> commonMistakes,  List<String> safetyNotes,  List<String> contraindications,  double? metValue,  int? defaultRestSec,  int? defaultHoldSec,  String? variationOf,  List<String> tags,  String? source,  String? license,  bool isCustom,  bool archived, @NullableUtcDateTimeConverter()  DateTime? createdAt, @NullableUtcDateTimeConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Exercise():
return $default(_that.id,_that.name,_that.aliases,_that.sanskritName,_that.category,_that.subcategory,_that.trackingType,_that.primaryMuscles,_that.secondaryMuscles,_that.equipment,_that.difficulty,_that.unilateral,_that.mechanic,_that.force,_that.steps,_that.tips,_that.commonMistakes,_that.safetyNotes,_that.contraindications,_that.metValue,_that.defaultRestSec,_that.defaultHoldSec,_that.variationOf,_that.tags,_that.source,_that.license,_that.isCustom,_that.archived,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> aliases,  String? sanskritName,  String category,  String? subcategory, @JsonKey(unknownEnumValue: TrackingType.unknown)  TrackingType trackingType,  List<String> primaryMuscles,  List<String> secondaryMuscles,  List<String> equipment,  Difficulty? difficulty,  bool unilateral,  String? mechanic,  String? force,  List<String> steps,  List<String> tips,  List<String> commonMistakes,  List<String> safetyNotes,  List<String> contraindications,  double? metValue,  int? defaultRestSec,  int? defaultHoldSec,  String? variationOf,  List<String> tags,  String? source,  String? license,  bool isCustom,  bool archived, @NullableUtcDateTimeConverter()  DateTime? createdAt, @NullableUtcDateTimeConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.id,_that.name,_that.aliases,_that.sanskritName,_that.category,_that.subcategory,_that.trackingType,_that.primaryMuscles,_that.secondaryMuscles,_that.equipment,_that.difficulty,_that.unilateral,_that.mechanic,_that.force,_that.steps,_that.tips,_that.commonMistakes,_that.safetyNotes,_that.contraindications,_that.metValue,_that.defaultRestSec,_that.defaultHoldSec,_that.variationOf,_that.tags,_that.source,_that.license,_that.isCustom,_that.archived,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Exercise implements Exercise {
  const _Exercise({required this.id, required this.name,  List<String> aliases = const <String>[], this.sanskritName, required this.category, this.subcategory, @JsonKey(unknownEnumValue: TrackingType.unknown) required this.trackingType,  List<String> primaryMuscles = const <String>[],  List<String> secondaryMuscles = const <String>[],  List<String> equipment = const <String>[], this.difficulty, this.unilateral = false, this.mechanic, this.force,  List<String> steps = const <String>[],  List<String> tips = const <String>[],  List<String> commonMistakes = const <String>[],  List<String> safetyNotes = const <String>[],  List<String> contraindications = const <String>[], this.metValue, this.defaultRestSec, this.defaultHoldSec, this.variationOf,  List<String> tags = const <String>[], this.source, this.license, this.isCustom = false, this.archived = false, @NullableUtcDateTimeConverter() this.createdAt, @NullableUtcDateTimeConverter() this.updatedAt}): _aliases = aliases,_primaryMuscles = primaryMuscles,_secondaryMuscles = secondaryMuscles,_equipment = equipment,_steps = steps,_tips = tips,_commonMistakes = commonMistakes,_safetyNotes = safetyNotes,_contraindications = contraindications,_tags = tags;
  factory _Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _aliases;
@override@JsonKey() List<String> get aliases {
  if (_aliases is EqualUnmodifiableListView) return _aliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aliases);
}

@override final  String? sanskritName;
@override final  String category;
@override final  String? subcategory;
@override@JsonKey(unknownEnumValue: TrackingType.unknown) final  TrackingType trackingType;
 final  List<String> _primaryMuscles;
@override@JsonKey() List<String> get primaryMuscles {
  if (_primaryMuscles is EqualUnmodifiableListView) return _primaryMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryMuscles);
}

 final  List<String> _secondaryMuscles;
@override@JsonKey() List<String> get secondaryMuscles {
  if (_secondaryMuscles is EqualUnmodifiableListView) return _secondaryMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryMuscles);
}

 final  List<String> _equipment;
@override@JsonKey() List<String> get equipment {
  if (_equipment is EqualUnmodifiableListView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_equipment);
}

@override final  Difficulty? difficulty;
@override@JsonKey() final  bool unilateral;
@override final  String? mechanic;
@override final  String? force;
 final  List<String> _steps;
@override@JsonKey() List<String> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

 final  List<String> _tips;
@override@JsonKey() List<String> get tips {
  if (_tips is EqualUnmodifiableListView) return _tips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tips);
}

 final  List<String> _commonMistakes;
@override@JsonKey() List<String> get commonMistakes {
  if (_commonMistakes is EqualUnmodifiableListView) return _commonMistakes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commonMistakes);
}

 final  List<String> _safetyNotes;
@override@JsonKey() List<String> get safetyNotes {
  if (_safetyNotes is EqualUnmodifiableListView) return _safetyNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_safetyNotes);
}

 final  List<String> _contraindications;
@override@JsonKey() List<String> get contraindications {
  if (_contraindications is EqualUnmodifiableListView) return _contraindications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contraindications);
}

@override final  double? metValue;
@override final  int? defaultRestSec;
@override final  int? defaultHoldSec;
@override final  String? variationOf;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? source;
@override final  String? license;
@override@JsonKey() final  bool isCustom;
/// Custom exercises only: hidden from pickers but kept for history.
@override@JsonKey() final  bool archived;
@override@NullableUtcDateTimeConverter() final  DateTime? createdAt;
@override@NullableUtcDateTimeConverter() final  DateTime? updatedAt;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseCopyWith<_Exercise> get copyWith => __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exercise&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.aliases, _aliases)&&(identical(other.sanskritName, sanskritName) || other.sanskritName == sanskritName)&&(identical(other.category, category) || other.category == category)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.trackingType, trackingType) || other.trackingType == trackingType)&&const DeepCollectionEquality().equals(other.primaryMuscles, _primaryMuscles)&&const DeepCollectionEquality().equals(other.secondaryMuscles, _secondaryMuscles)&&const DeepCollectionEquality().equals(other.equipment, _equipment)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.unilateral, unilateral) || other.unilateral == unilateral)&&(identical(other.mechanic, mechanic) || other.mechanic == mechanic)&&(identical(other.force, force) || other.force == force)&&const DeepCollectionEquality().equals(other.steps, _steps)&&const DeepCollectionEquality().equals(other.tips, _tips)&&const DeepCollectionEquality().equals(other.commonMistakes, _commonMistakes)&&const DeepCollectionEquality().equals(other.safetyNotes, _safetyNotes)&&const DeepCollectionEquality().equals(other.contraindications, _contraindications)&&(identical(other.metValue, metValue) || other.metValue == metValue)&&(identical(other.defaultRestSec, defaultRestSec) || other.defaultRestSec == defaultRestSec)&&(identical(other.defaultHoldSec, defaultHoldSec) || other.defaultHoldSec == defaultHoldSec)&&(identical(other.variationOf, variationOf) || other.variationOf == variationOf)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.source, source) || other.source == source)&&(identical(other.license, license) || other.license == license)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,name,const DeepCollectionEquality().hash(_aliases),sanskritName,category,subcategory,trackingType,const DeepCollectionEquality().hash(_primaryMuscles),const DeepCollectionEquality().hash(_secondaryMuscles),const DeepCollectionEquality().hash(_equipment),difficulty,unilateral,mechanic,force,const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_tips),const DeepCollectionEquality().hash(_commonMistakes),const DeepCollectionEquality().hash(_safetyNotes),const DeepCollectionEquality().hash(_contraindications),metValue,defaultRestSec,defaultHoldSec,variationOf,const DeepCollectionEquality().hash(_tags),source,license,isCustom,archived,createdAt,updatedAt]);
}

@override
String toString() {
    return 'Exercise(id: $id, name: $name, aliases: $aliases, sanskritName: $sanskritName, category: $category, subcategory: $subcategory, trackingType: $trackingType, primaryMuscles: $primaryMuscles, secondaryMuscles: $secondaryMuscles, equipment: $equipment, difficulty: $difficulty, unilateral: $unilateral, mechanic: $mechanic, force: $force, steps: $steps, tips: $tips, commonMistakes: $commonMistakes, safetyNotes: $safetyNotes, contraindications: $contraindications, metValue: $metValue, defaultRestSec: $defaultRestSec, defaultHoldSec: $defaultHoldSec, variationOf: $variationOf, tags: $tags, source: $source, license: $license, isCustom: $isCustom, archived: $archived, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res> implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) = __$ExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> aliases, String? sanskritName, String category, String? subcategory,@JsonKey(unknownEnumValue: TrackingType.unknown) TrackingType trackingType, List<String> primaryMuscles, List<String> secondaryMuscles, List<String> equipment, Difficulty? difficulty, bool unilateral, String? mechanic, String? force, List<String> steps, List<String> tips, List<String> commonMistakes, List<String> safetyNotes, List<String> contraindications, double? metValue, int? defaultRestSec, int? defaultHoldSec, String? variationOf, List<String> tags, String? source, String? license, bool isCustom, bool archived,@NullableUtcDateTimeConverter() DateTime? createdAt,@NullableUtcDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$ExerciseCopyWithImpl<$Res>
    implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? aliases = null,Object? sanskritName = freezed,Object? category = null,Object? subcategory = freezed,Object? trackingType = null,Object? primaryMuscles = null,Object? secondaryMuscles = null,Object? equipment = null,Object? difficulty = freezed,Object? unilateral = null,Object? mechanic = freezed,Object? force = freezed,Object? steps = null,Object? tips = null,Object? commonMistakes = null,Object? safetyNotes = null,Object? contraindications = null,Object? metValue = freezed,Object? defaultRestSec = freezed,Object? defaultHoldSec = freezed,Object? variationOf = freezed,Object? tags = null,Object? source = freezed,Object? license = freezed,Object? isCustom = null,Object? archived = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Exercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,aliases: null == aliases ? _self._aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,sanskritName: freezed == sanskritName ? _self.sanskritName : sanskritName // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,trackingType: null == trackingType ? _self.trackingType : trackingType // ignore: cast_nullable_to_non_nullable
as TrackingType,primaryMuscles: null == primaryMuscles ? _self._primaryMuscles : primaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,secondaryMuscles: null == secondaryMuscles ? _self._secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,equipment: null == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty?,unilateral: null == unilateral ? _self.unilateral : unilateral // ignore: cast_nullable_to_non_nullable
as bool,mechanic: freezed == mechanic ? _self.mechanic : mechanic // ignore: cast_nullable_to_non_nullable
as String?,force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as String?,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<String>,tips: null == tips ? _self._tips : tips // ignore: cast_nullable_to_non_nullable
as List<String>,commonMistakes: null == commonMistakes ? _self._commonMistakes : commonMistakes // ignore: cast_nullable_to_non_nullable
as List<String>,safetyNotes: null == safetyNotes ? _self._safetyNotes : safetyNotes // ignore: cast_nullable_to_non_nullable
as List<String>,contraindications: null == contraindications ? _self._contraindications : contraindications // ignore: cast_nullable_to_non_nullable
as List<String>,metValue: freezed == metValue ? _self.metValue : metValue // ignore: cast_nullable_to_non_nullable
as double?,defaultRestSec: freezed == defaultRestSec ? _self.defaultRestSec : defaultRestSec // ignore: cast_nullable_to_non_nullable
as int?,defaultHoldSec: freezed == defaultHoldSec ? _self.defaultHoldSec : defaultHoldSec // ignore: cast_nullable_to_non_nullable
as int?,variationOf: freezed == variationOf ? _self.variationOf : variationOf // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,license: freezed == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String?,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ExerciseTombstone {

 String get exerciseId; String get name;@JsonKey(unknownEnumValue: TrackingType.unknown) TrackingType get trackingType; String get removedInLibraryVersion;
/// Create a copy of ExerciseTombstone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseTombstoneCopyWith<ExerciseTombstone> get copyWith => _$ExerciseTombstoneCopyWithImpl<ExerciseTombstone>(this as ExerciseTombstone, _$identity);

  /// Serializes this ExerciseTombstone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExerciseTombstone;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseTombstone&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.trackingType, _this.trackingType) || other.trackingType == _this.trackingType)&&(identical(other.removedInLibraryVersion, _this.removedInLibraryVersion) || other.removedInLibraryVersion == _this.removedInLibraryVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExerciseTombstone;
  return Object.hash(runtimeType,_this.exerciseId,_this.name,_this.trackingType,_this.removedInLibraryVersion);
}

@override
String toString() {
  final _this = this as ExerciseTombstone;
  return 'ExerciseTombstone(exerciseId: ${_this.exerciseId}, name: ${_this.name}, trackingType: ${_this.trackingType}, removedInLibraryVersion: ${_this.removedInLibraryVersion})';
}


}

/// @nodoc
abstract mixin class $ExerciseTombstoneCopyWith<$Res>  {
  factory $ExerciseTombstoneCopyWith(ExerciseTombstone value, $Res Function(ExerciseTombstone) _then) = _$ExerciseTombstoneCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String name,@JsonKey(unknownEnumValue: TrackingType.unknown) TrackingType trackingType, String removedInLibraryVersion
});




}
/// @nodoc
class _$ExerciseTombstoneCopyWithImpl<$Res>
    implements $ExerciseTombstoneCopyWith<$Res> {
  _$ExerciseTombstoneCopyWithImpl(this._self, this._then);

  final ExerciseTombstone _self;
  final $Res Function(ExerciseTombstone) _then;

/// Create a copy of ExerciseTombstone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? name = null,Object? trackingType = null,Object? removedInLibraryVersion = null,}) {
  return _then(ExerciseTombstone(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,trackingType: null == trackingType ? _self.trackingType : trackingType // ignore: cast_nullable_to_non_nullable
as TrackingType,removedInLibraryVersion: null == removedInLibraryVersion ? _self.removedInLibraryVersion : removedInLibraryVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseTombstone].
extension ExerciseTombstonePatterns on ExerciseTombstone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseTombstone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseTombstone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseTombstone value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseTombstone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseTombstone value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseTombstone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String name, @JsonKey(unknownEnumValue: TrackingType.unknown)  TrackingType trackingType,  String removedInLibraryVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseTombstone() when $default != null:
return $default(_that.exerciseId,_that.name,_that.trackingType,_that.removedInLibraryVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String name, @JsonKey(unknownEnumValue: TrackingType.unknown)  TrackingType trackingType,  String removedInLibraryVersion)  $default,) {final _that = this;
switch (_that) {
case _ExerciseTombstone():
return $default(_that.exerciseId,_that.name,_that.trackingType,_that.removedInLibraryVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String name, @JsonKey(unknownEnumValue: TrackingType.unknown)  TrackingType trackingType,  String removedInLibraryVersion)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseTombstone() when $default != null:
return $default(_that.exerciseId,_that.name,_that.trackingType,_that.removedInLibraryVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseTombstone implements ExerciseTombstone {
  const _ExerciseTombstone({required this.exerciseId, required this.name, @JsonKey(unknownEnumValue: TrackingType.unknown) required this.trackingType, required this.removedInLibraryVersion});
  factory _ExerciseTombstone.fromJson(Map<String, dynamic> json) => _$ExerciseTombstoneFromJson(json);

@override final  String exerciseId;
@override final  String name;
@override@JsonKey(unknownEnumValue: TrackingType.unknown) final  TrackingType trackingType;
@override final  String removedInLibraryVersion;

/// Create a copy of ExerciseTombstone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseTombstoneCopyWith<_ExerciseTombstone> get copyWith => __$ExerciseTombstoneCopyWithImpl<_ExerciseTombstone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseTombstoneToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseTombstone&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.trackingType, trackingType) || other.trackingType == trackingType)&&(identical(other.removedInLibraryVersion, removedInLibraryVersion) || other.removedInLibraryVersion == removedInLibraryVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,exerciseId,name,trackingType,removedInLibraryVersion);
}

@override
String toString() {
    return 'ExerciseTombstone(exerciseId: $exerciseId, name: $name, trackingType: $trackingType, removedInLibraryVersion: $removedInLibraryVersion)';
}


}

/// @nodoc
abstract mixin class _$ExerciseTombstoneCopyWith<$Res> implements $ExerciseTombstoneCopyWith<$Res> {
  factory _$ExerciseTombstoneCopyWith(_ExerciseTombstone value, $Res Function(_ExerciseTombstone) _then) = __$ExerciseTombstoneCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String name,@JsonKey(unknownEnumValue: TrackingType.unknown) TrackingType trackingType, String removedInLibraryVersion
});




}
/// @nodoc
class __$ExerciseTombstoneCopyWithImpl<$Res>
    implements _$ExerciseTombstoneCopyWith<$Res> {
  __$ExerciseTombstoneCopyWithImpl(this._self, this._then);

  final _ExerciseTombstone _self;
  final $Res Function(_ExerciseTombstone) _then;

/// Create a copy of ExerciseTombstone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? name = null,Object? trackingType = null,Object? removedInLibraryVersion = null,}) {
  return _then(_ExerciseTombstone(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,trackingType: null == trackingType ? _self.trackingType : trackingType // ignore: cast_nullable_to_non_nullable
as TrackingType,removedInLibraryVersion: null == removedInLibraryVersion ? _self.removedInLibraryVersion : removedInLibraryVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
