// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeasurementField {

 String get id; String get name; MeasurementUnitType get unitType;/// Label for [MeasurementUnitType.custom] only.
 String? get customUnit; BodySide get side;/// Left and right of one measurement share a pair id.
 String? get pairId; BodyAnchor? get bodyAnchor; bool get enabled; int get position; bool get builtIn; bool get archived; DateTime get updatedAt;
/// Create a copy of MeasurementField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementFieldCopyWith<MeasurementField> get copyWith => _$MeasurementFieldCopyWithImpl<MeasurementField>(this as MeasurementField, _$identity);

  /// Serializes this MeasurementField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MeasurementField;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementField&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.unitType, _this.unitType) || other.unitType == _this.unitType)&&(identical(other.customUnit, _this.customUnit) || other.customUnit == _this.customUnit)&&(identical(other.side, _this.side) || other.side == _this.side)&&(identical(other.pairId, _this.pairId) || other.pairId == _this.pairId)&&(identical(other.bodyAnchor, _this.bodyAnchor) || other.bodyAnchor == _this.bodyAnchor)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.builtIn, _this.builtIn) || other.builtIn == _this.builtIn)&&(identical(other.archived, _this.archived) || other.archived == _this.archived)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MeasurementField;
  return Object.hash(runtimeType,_this.id,_this.name,_this.unitType,_this.customUnit,_this.side,_this.pairId,_this.bodyAnchor,_this.enabled,_this.position,_this.builtIn,_this.archived,_this.updatedAt);
}

@override
String toString() {
  final _this = this as MeasurementField;
  return 'MeasurementField(id: ${_this.id}, name: ${_this.name}, unitType: ${_this.unitType}, customUnit: ${_this.customUnit}, side: ${_this.side}, pairId: ${_this.pairId}, bodyAnchor: ${_this.bodyAnchor}, enabled: ${_this.enabled}, position: ${_this.position}, builtIn: ${_this.builtIn}, archived: ${_this.archived}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MeasurementFieldCopyWith<$Res>  {
  factory $MeasurementFieldCopyWith(MeasurementField value, $Res Function(MeasurementField) _then) = _$MeasurementFieldCopyWithImpl;
@useResult
$Res call({
 String id, String name, MeasurementUnitType unitType, String? customUnit, BodySide side, String? pairId, BodyAnchor? bodyAnchor, bool enabled, int position, bool builtIn, bool archived, DateTime updatedAt
});




}
/// @nodoc
class _$MeasurementFieldCopyWithImpl<$Res>
    implements $MeasurementFieldCopyWith<$Res> {
  _$MeasurementFieldCopyWithImpl(this._self, this._then);

  final MeasurementField _self;
  final $Res Function(MeasurementField) _then;

/// Create a copy of MeasurementField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? unitType = null,Object? customUnit = freezed,Object? side = null,Object? pairId = freezed,Object? bodyAnchor = freezed,Object? enabled = null,Object? position = null,Object? builtIn = null,Object? archived = null,Object? updatedAt = null,}) {
  return _then(MeasurementField(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as MeasurementUnitType,customUnit: freezed == customUnit ? _self.customUnit : customUnit // ignore: cast_nullable_to_non_nullable
as String?,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as BodySide,pairId: freezed == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String?,bodyAnchor: freezed == bodyAnchor ? _self.bodyAnchor : bodyAnchor // ignore: cast_nullable_to_non_nullable
as BodyAnchor?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,builtIn: null == builtIn ? _self.builtIn : builtIn // ignore: cast_nullable_to_non_nullable
as bool,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementField].
extension MeasurementFieldPatterns on MeasurementField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementField value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementField value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  MeasurementUnitType unitType,  String? customUnit,  BodySide side,  String? pairId,  BodyAnchor? bodyAnchor,  bool enabled,  int position,  bool builtIn,  bool archived,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementField() when $default != null:
return $default(_that.id,_that.name,_that.unitType,_that.customUnit,_that.side,_that.pairId,_that.bodyAnchor,_that.enabled,_that.position,_that.builtIn,_that.archived,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  MeasurementUnitType unitType,  String? customUnit,  BodySide side,  String? pairId,  BodyAnchor? bodyAnchor,  bool enabled,  int position,  bool builtIn,  bool archived,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MeasurementField():
return $default(_that.id,_that.name,_that.unitType,_that.customUnit,_that.side,_that.pairId,_that.bodyAnchor,_that.enabled,_that.position,_that.builtIn,_that.archived,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  MeasurementUnitType unitType,  String? customUnit,  BodySide side,  String? pairId,  BodyAnchor? bodyAnchor,  bool enabled,  int position,  bool builtIn,  bool archived,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementField() when $default != null:
return $default(_that.id,_that.name,_that.unitType,_that.customUnit,_that.side,_that.pairId,_that.bodyAnchor,_that.enabled,_that.position,_that.builtIn,_that.archived,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeasurementField implements MeasurementField {
  const _MeasurementField({required this.id, required this.name, required this.unitType, this.customUnit, this.side = BodySide.none, this.pairId, this.bodyAnchor, this.enabled = true, this.position = 0, this.builtIn = false, this.archived = false, required this.updatedAt});
  factory _MeasurementField.fromJson(Map<String, dynamic> json) => _$MeasurementFieldFromJson(json);

@override final  String id;
@override final  String name;
@override final  MeasurementUnitType unitType;
/// Label for [MeasurementUnitType.custom] only.
@override final  String? customUnit;
@override@JsonKey() final  BodySide side;
/// Left and right of one measurement share a pair id.
@override final  String? pairId;
@override final  BodyAnchor? bodyAnchor;
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int position;
@override@JsonKey() final  bool builtIn;
@override@JsonKey() final  bool archived;
@override final  DateTime updatedAt;

/// Create a copy of MeasurementField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementFieldCopyWith<_MeasurementField> get copyWith => __$MeasurementFieldCopyWithImpl<_MeasurementField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeasurementFieldToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementField&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.customUnit, customUnit) || other.customUnit == customUnit)&&(identical(other.side, side) || other.side == side)&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.bodyAnchor, bodyAnchor) || other.bodyAnchor == bodyAnchor)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.position, position) || other.position == position)&&(identical(other.builtIn, builtIn) || other.builtIn == builtIn)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,unitType,customUnit,side,pairId,bodyAnchor,enabled,position,builtIn,archived,updatedAt);
}

@override
String toString() {
    return 'MeasurementField(id: $id, name: $name, unitType: $unitType, customUnit: $customUnit, side: $side, pairId: $pairId, bodyAnchor: $bodyAnchor, enabled: $enabled, position: $position, builtIn: $builtIn, archived: $archived, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MeasurementFieldCopyWith<$Res> implements $MeasurementFieldCopyWith<$Res> {
  factory _$MeasurementFieldCopyWith(_MeasurementField value, $Res Function(_MeasurementField) _then) = __$MeasurementFieldCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, MeasurementUnitType unitType, String? customUnit, BodySide side, String? pairId, BodyAnchor? bodyAnchor, bool enabled, int position, bool builtIn, bool archived, DateTime updatedAt
});




}
/// @nodoc
class __$MeasurementFieldCopyWithImpl<$Res>
    implements _$MeasurementFieldCopyWith<$Res> {
  __$MeasurementFieldCopyWithImpl(this._self, this._then);

  final _MeasurementField _self;
  final $Res Function(_MeasurementField) _then;

/// Create a copy of MeasurementField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? unitType = null,Object? customUnit = freezed,Object? side = null,Object? pairId = freezed,Object? bodyAnchor = freezed,Object? enabled = null,Object? position = null,Object? builtIn = null,Object? archived = null,Object? updatedAt = null,}) {
  return _then(_MeasurementField(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as MeasurementUnitType,customUnit: freezed == customUnit ? _self.customUnit : customUnit // ignore: cast_nullable_to_non_nullable
as String?,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as BodySide,pairId: freezed == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String?,bodyAnchor: freezed == bodyAnchor ? _self.bodyAnchor : bodyAnchor // ignore: cast_nullable_to_non_nullable
as BodyAnchor?,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,builtIn: null == builtIn ? _self.builtIn : builtIn // ignore: cast_nullable_to_non_nullable
as bool,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MeasurementEntry {

 String get id; DateTime get date; Map<String, double> get values; String? get note; DateTime get updatedAt;
/// Create a copy of MeasurementEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeasurementEntryCopyWith<MeasurementEntry> get copyWith => _$MeasurementEntryCopyWithImpl<MeasurementEntry>(this as MeasurementEntry, _$identity);

  /// Serializes this MeasurementEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MeasurementEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeasurementEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.values, _this.values)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MeasurementEntry;
  return Object.hash(runtimeType,_this.id,_this.date,const DeepCollectionEquality().hash(_this.values),_this.note,_this.updatedAt);
}

@override
String toString() {
  final _this = this as MeasurementEntry;
  return 'MeasurementEntry(id: ${_this.id}, date: ${_this.date}, values: ${_this.values}, note: ${_this.note}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MeasurementEntryCopyWith<$Res>  {
  factory $MeasurementEntryCopyWith(MeasurementEntry value, $Res Function(MeasurementEntry) _then) = _$MeasurementEntryCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, Map<String, double> values, String? note, DateTime updatedAt
});




}
/// @nodoc
class _$MeasurementEntryCopyWithImpl<$Res>
    implements $MeasurementEntryCopyWith<$Res> {
  _$MeasurementEntryCopyWithImpl(this._self, this._then);

  final MeasurementEntry _self;
  final $Res Function(MeasurementEntry) _then;

/// Create a copy of MeasurementEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? values = null,Object? note = freezed,Object? updatedAt = null,}) {
  return _then(MeasurementEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as Map<String, double>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MeasurementEntry].
extension MeasurementEntryPatterns on MeasurementEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeasurementEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeasurementEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeasurementEntry value)  $default,){
final _that = this;
switch (_that) {
case _MeasurementEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeasurementEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MeasurementEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  Map<String, double> values,  String? note,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeasurementEntry() when $default != null:
return $default(_that.id,_that.date,_that.values,_that.note,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  Map<String, double> values,  String? note,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MeasurementEntry():
return $default(_that.id,_that.date,_that.values,_that.note,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  Map<String, double> values,  String? note,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MeasurementEntry() when $default != null:
return $default(_that.id,_that.date,_that.values,_that.note,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeasurementEntry implements MeasurementEntry {
  const _MeasurementEntry({required this.id, required this.date,  Map<String, double> values = const <String, double>{}, this.note, required this.updatedAt}): _values = values;
  factory _MeasurementEntry.fromJson(Map<String, dynamic> json) => _$MeasurementEntryFromJson(json);

@override final  String id;
@override final  DateTime date;
 final  Map<String, double> _values;
@override@JsonKey() Map<String, double> get values {
  if (_values is EqualUnmodifiableMapView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_values);
}

@override final  String? note;
@override final  DateTime updatedAt;

/// Create a copy of MeasurementEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeasurementEntryCopyWith<_MeasurementEntry> get copyWith => __$MeasurementEntryCopyWithImpl<_MeasurementEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeasurementEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeasurementEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.values, _values)&&(identical(other.note, note) || other.note == note)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,date,const DeepCollectionEquality().hash(_values),note,updatedAt);
}

@override
String toString() {
    return 'MeasurementEntry(id: $id, date: $date, values: $values, note: $note, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MeasurementEntryCopyWith<$Res> implements $MeasurementEntryCopyWith<$Res> {
  factory _$MeasurementEntryCopyWith(_MeasurementEntry value, $Res Function(_MeasurementEntry) _then) = __$MeasurementEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, Map<String, double> values, String? note, DateTime updatedAt
});




}
/// @nodoc
class __$MeasurementEntryCopyWithImpl<$Res>
    implements _$MeasurementEntryCopyWith<$Res> {
  __$MeasurementEntryCopyWithImpl(this._self, this._then);

  final _MeasurementEntry _self;
  final $Res Function(_MeasurementEntry) _then;

/// Create a copy of MeasurementEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? values = null,Object? note = freezed,Object? updatedAt = null,}) {
  return _then(_MeasurementEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as Map<String, double>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
