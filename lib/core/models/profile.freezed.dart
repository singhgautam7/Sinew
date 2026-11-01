// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 Sex? get sex; int? get birthYear; double? get heightCm; ActivityLevel get activityLevel; WeightUnit get weightUnit; LengthUnit get lengthUnit; DistanceUnit get distanceUnit; BmiCutoffs get bmiCutoffs;@NullableUtcDateTimeConverter() DateTime? get updatedAt;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.sex, _this.sex) || other.sex == _this.sex)&&(identical(other.birthYear, _this.birthYear) || other.birthYear == _this.birthYear)&&(identical(other.heightCm, _this.heightCm) || other.heightCm == _this.heightCm)&&(identical(other.activityLevel, _this.activityLevel) || other.activityLevel == _this.activityLevel)&&(identical(other.weightUnit, _this.weightUnit) || other.weightUnit == _this.weightUnit)&&(identical(other.lengthUnit, _this.lengthUnit) || other.lengthUnit == _this.lengthUnit)&&(identical(other.distanceUnit, _this.distanceUnit) || other.distanceUnit == _this.distanceUnit)&&(identical(other.bmiCutoffs, _this.bmiCutoffs) || other.bmiCutoffs == _this.bmiCutoffs)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.sex,_this.birthYear,_this.heightCm,_this.activityLevel,_this.weightUnit,_this.lengthUnit,_this.distanceUnit,_this.bmiCutoffs,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(sex: ${_this.sex}, birthYear: ${_this.birthYear}, heightCm: ${_this.heightCm}, activityLevel: ${_this.activityLevel}, weightUnit: ${_this.weightUnit}, lengthUnit: ${_this.lengthUnit}, distanceUnit: ${_this.distanceUnit}, bmiCutoffs: ${_this.bmiCutoffs}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 Sex? sex, int? birthYear, double? heightCm, ActivityLevel activityLevel, WeightUnit weightUnit, LengthUnit lengthUnit, DistanceUnit distanceUnit, BmiCutoffs bmiCutoffs,@NullableUtcDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sex = freezed,Object? birthYear = freezed,Object? heightCm = freezed,Object? activityLevel = null,Object? weightUnit = null,Object? lengthUnit = null,Object? distanceUnit = null,Object? bmiCutoffs = null,Object? updatedAt = freezed,}) {
  return _then(Profile(
sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as Sex?,birthYear: freezed == birthYear ? _self.birthYear : birthYear // ignore: cast_nullable_to_non_nullable
as int?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as ActivityLevel,weightUnit: null == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as WeightUnit,lengthUnit: null == lengthUnit ? _self.lengthUnit : lengthUnit // ignore: cast_nullable_to_non_nullable
as LengthUnit,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as DistanceUnit,bmiCutoffs: null == bmiCutoffs ? _self.bmiCutoffs : bmiCutoffs // ignore: cast_nullable_to_non_nullable
as BmiCutoffs,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Sex? sex,  int? birthYear,  double? heightCm,  ActivityLevel activityLevel,  WeightUnit weightUnit,  LengthUnit lengthUnit,  DistanceUnit distanceUnit,  BmiCutoffs bmiCutoffs, @NullableUtcDateTimeConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.sex,_that.birthYear,_that.heightCm,_that.activityLevel,_that.weightUnit,_that.lengthUnit,_that.distanceUnit,_that.bmiCutoffs,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Sex? sex,  int? birthYear,  double? heightCm,  ActivityLevel activityLevel,  WeightUnit weightUnit,  LengthUnit lengthUnit,  DistanceUnit distanceUnit,  BmiCutoffs bmiCutoffs, @NullableUtcDateTimeConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.sex,_that.birthYear,_that.heightCm,_that.activityLevel,_that.weightUnit,_that.lengthUnit,_that.distanceUnit,_that.bmiCutoffs,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Sex? sex,  int? birthYear,  double? heightCm,  ActivityLevel activityLevel,  WeightUnit weightUnit,  LengthUnit lengthUnit,  DistanceUnit distanceUnit,  BmiCutoffs bmiCutoffs, @NullableUtcDateTimeConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.sex,_that.birthYear,_that.heightCm,_that.activityLevel,_that.weightUnit,_that.lengthUnit,_that.distanceUnit,_that.bmiCutoffs,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({this.sex, this.birthYear, this.heightCm, this.activityLevel = ActivityLevel.moderate, this.weightUnit = WeightUnit.kg, this.lengthUnit = LengthUnit.cm, this.distanceUnit = DistanceUnit.km, this.bmiCutoffs = BmiCutoffs.who, @NullableUtcDateTimeConverter() this.updatedAt});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  Sex? sex;
@override final  int? birthYear;
@override final  double? heightCm;
@override@JsonKey() final  ActivityLevel activityLevel;
@override@JsonKey() final  WeightUnit weightUnit;
@override@JsonKey() final  LengthUnit lengthUnit;
@override@JsonKey() final  DistanceUnit distanceUnit;
@override@JsonKey() final  BmiCutoffs bmiCutoffs;
@override@NullableUtcDateTimeConverter() final  DateTime? updatedAt;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthYear, birthYear) || other.birthYear == birthYear)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.weightUnit, weightUnit) || other.weightUnit == weightUnit)&&(identical(other.lengthUnit, lengthUnit) || other.lengthUnit == lengthUnit)&&(identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit)&&(identical(other.bmiCutoffs, bmiCutoffs) || other.bmiCutoffs == bmiCutoffs)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sex,birthYear,heightCm,activityLevel,weightUnit,lengthUnit,distanceUnit,bmiCutoffs,updatedAt);
}

@override
String toString() {
    return 'Profile(sex: $sex, birthYear: $birthYear, heightCm: $heightCm, activityLevel: $activityLevel, weightUnit: $weightUnit, lengthUnit: $lengthUnit, distanceUnit: $distanceUnit, bmiCutoffs: $bmiCutoffs, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 Sex? sex, int? birthYear, double? heightCm, ActivityLevel activityLevel, WeightUnit weightUnit, LengthUnit lengthUnit, DistanceUnit distanceUnit, BmiCutoffs bmiCutoffs,@NullableUtcDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sex = freezed,Object? birthYear = freezed,Object? heightCm = freezed,Object? activityLevel = null,Object? weightUnit = null,Object? lengthUnit = null,Object? distanceUnit = null,Object? bmiCutoffs = null,Object? updatedAt = freezed,}) {
  return _then(_Profile(
sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as Sex?,birthYear: freezed == birthYear ? _self.birthYear : birthYear // ignore: cast_nullable_to_non_nullable
as int?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as ActivityLevel,weightUnit: null == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as WeightUnit,lengthUnit: null == lengthUnit ? _self.lengthUnit : lengthUnit // ignore: cast_nullable_to_non_nullable
as LengthUnit,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as DistanceUnit,bmiCutoffs: null == bmiCutoffs ? _self.bmiCutoffs : bmiCutoffs // ignore: cast_nullable_to_non_nullable
as BmiCutoffs,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
