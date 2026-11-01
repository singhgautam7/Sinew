// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Routine {

 String get id; String get name; String? get notes; int get position; bool get archived; List<RoutineItem> get items;@UtcDateTimeConverter() DateTime get createdAt;@UtcDateTimeConverter() DateTime get updatedAt;
/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineCopyWith<Routine> get copyWith => _$RoutineCopyWithImpl<Routine>(this as Routine, _$identity);

  /// Serializes this Routine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Routine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Routine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.archived, _this.archived) || other.archived == _this.archived)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Routine;
  return Object.hash(runtimeType,_this.id,_this.name,_this.notes,_this.position,_this.archived,const DeepCollectionEquality().hash(_this.items),_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Routine;
  return 'Routine(id: ${_this.id}, name: ${_this.name}, notes: ${_this.notes}, position: ${_this.position}, archived: ${_this.archived}, items: ${_this.items}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $RoutineCopyWith<$Res>  {
  factory $RoutineCopyWith(Routine value, $Res Function(Routine) _then) = _$RoutineCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? notes, int position, bool archived, List<RoutineItem> items,@UtcDateTimeConverter() DateTime createdAt,@UtcDateTimeConverter() DateTime updatedAt
});




}
/// @nodoc
class _$RoutineCopyWithImpl<$Res>
    implements $RoutineCopyWith<$Res> {
  _$RoutineCopyWithImpl(this._self, this._then);

  final Routine _self;
  final $Res Function(Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? notes = freezed,Object? position = null,Object? archived = null,Object? items = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Routine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RoutineItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Routine].
extension RoutinePatterns on Routine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Routine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Routine value)  $default,){
final _that = this;
switch (_that) {
case _Routine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Routine value)?  $default,){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? notes,  int position,  bool archived,  List<RoutineItem> items, @UtcDateTimeConverter()  DateTime createdAt, @UtcDateTimeConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.position,_that.archived,_that.items,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? notes,  int position,  bool archived,  List<RoutineItem> items, @UtcDateTimeConverter()  DateTime createdAt, @UtcDateTimeConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Routine():
return $default(_that.id,_that.name,_that.notes,_that.position,_that.archived,_that.items,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? notes,  int position,  bool archived,  List<RoutineItem> items, @UtcDateTimeConverter()  DateTime createdAt, @UtcDateTimeConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.name,_that.notes,_that.position,_that.archived,_that.items,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Routine implements Routine {
  const _Routine({required this.id, required this.name, this.notes, this.position = 0, this.archived = false,  List<RoutineItem> items = const <RoutineItem>[], @UtcDateTimeConverter() required this.createdAt, @UtcDateTimeConverter() required this.updatedAt}): _items = items;
  factory _Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? notes;
@override@JsonKey() final  int position;
@override@JsonKey() final  bool archived;
 final  List<RoutineItem> _items;
@override@JsonKey() List<RoutineItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@UtcDateTimeConverter() final  DateTime createdAt;
@override@UtcDateTimeConverter() final  DateTime updatedAt;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineCopyWith<_Routine> get copyWith => __$RoutineCopyWithImpl<_Routine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Routine&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.position, position) || other.position == position)&&(identical(other.archived, archived) || other.archived == archived)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,notes,position,archived,const DeepCollectionEquality().hash(_items),createdAt,updatedAt);
}

@override
String toString() {
    return 'Routine(id: $id, name: $name, notes: $notes, position: $position, archived: $archived, items: $items, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineCopyWith<$Res> implements $RoutineCopyWith<$Res> {
  factory _$RoutineCopyWith(_Routine value, $Res Function(_Routine) _then) = __$RoutineCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? notes, int position, bool archived, List<RoutineItem> items,@UtcDateTimeConverter() DateTime createdAt,@UtcDateTimeConverter() DateTime updatedAt
});




}
/// @nodoc
class __$RoutineCopyWithImpl<$Res>
    implements _$RoutineCopyWith<$Res> {
  __$RoutineCopyWithImpl(this._self, this._then);

  final _Routine _self;
  final $Res Function(_Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? notes = freezed,Object? position = null,Object? archived = null,Object? items = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Routine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RoutineItem>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$RoutineItem {

 String get id; String get exerciseId; int get position;/// Items sharing a group number form a superset; null is a straight set.
 int? get supersetGroup; int get targetSets; int? get targetReps; int? get targetDurationSec; double? get targetDistanceM; double? get targetWeightKg; int? get restSec; String? get notes;
/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineItemCopyWith<RoutineItem> get copyWith => _$RoutineItemCopyWithImpl<RoutineItem>(this as RoutineItem, _$identity);

  /// Serializes this RoutineItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RoutineItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.supersetGroup, _this.supersetGroup) || other.supersetGroup == _this.supersetGroup)&&(identical(other.targetSets, _this.targetSets) || other.targetSets == _this.targetSets)&&(identical(other.targetReps, _this.targetReps) || other.targetReps == _this.targetReps)&&(identical(other.targetDurationSec, _this.targetDurationSec) || other.targetDurationSec == _this.targetDurationSec)&&(identical(other.targetDistanceM, _this.targetDistanceM) || other.targetDistanceM == _this.targetDistanceM)&&(identical(other.targetWeightKg, _this.targetWeightKg) || other.targetWeightKg == _this.targetWeightKg)&&(identical(other.restSec, _this.restSec) || other.restSec == _this.restSec)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RoutineItem;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.position,_this.supersetGroup,_this.targetSets,_this.targetReps,_this.targetDurationSec,_this.targetDistanceM,_this.targetWeightKg,_this.restSec,_this.notes);
}

@override
String toString() {
  final _this = this as RoutineItem;
  return 'RoutineItem(id: ${_this.id}, exerciseId: ${_this.exerciseId}, position: ${_this.position}, supersetGroup: ${_this.supersetGroup}, targetSets: ${_this.targetSets}, targetReps: ${_this.targetReps}, targetDurationSec: ${_this.targetDurationSec}, targetDistanceM: ${_this.targetDistanceM}, targetWeightKg: ${_this.targetWeightKg}, restSec: ${_this.restSec}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $RoutineItemCopyWith<$Res>  {
  factory $RoutineItemCopyWith(RoutineItem value, $Res Function(RoutineItem) _then) = _$RoutineItemCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, int position, int? supersetGroup, int targetSets, int? targetReps, int? targetDurationSec, double? targetDistanceM, double? targetWeightKg, int? restSec, String? notes
});




}
/// @nodoc
class _$RoutineItemCopyWithImpl<$Res>
    implements $RoutineItemCopyWith<$Res> {
  _$RoutineItemCopyWithImpl(this._self, this._then);

  final RoutineItem _self;
  final $Res Function(RoutineItem) _then;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? position = null,Object? supersetGroup = freezed,Object? targetSets = null,Object? targetReps = freezed,Object? targetDurationSec = freezed,Object? targetDistanceM = freezed,Object? targetWeightKg = freezed,Object? restSec = freezed,Object? notes = freezed,}) {
  return _then(RoutineItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supersetGroup: freezed == supersetGroup ? _self.supersetGroup : supersetGroup // ignore: cast_nullable_to_non_nullable
as int?,targetSets: null == targetSets ? _self.targetSets : targetSets // ignore: cast_nullable_to_non_nullable
as int,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,targetDurationSec: freezed == targetDurationSec ? _self.targetDurationSec : targetDurationSec // ignore: cast_nullable_to_non_nullable
as int?,targetDistanceM: freezed == targetDistanceM ? _self.targetDistanceM : targetDistanceM // ignore: cast_nullable_to_non_nullable
as double?,targetWeightKg: freezed == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,restSec: freezed == restSec ? _self.restSec : restSec // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineItem].
extension RoutineItemPatterns on RoutineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineItem value)  $default,){
final _that = this;
switch (_that) {
case _RoutineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineItem value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int position,  int? supersetGroup,  int targetSets,  int? targetReps,  int? targetDurationSec,  double? targetDistanceM,  double? targetWeightKg,  int? restSec,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineItem() when $default != null:
return $default(_that.id,_that.exerciseId,_that.position,_that.supersetGroup,_that.targetSets,_that.targetReps,_that.targetDurationSec,_that.targetDistanceM,_that.targetWeightKg,_that.restSec,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int position,  int? supersetGroup,  int targetSets,  int? targetReps,  int? targetDurationSec,  double? targetDistanceM,  double? targetWeightKg,  int? restSec,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _RoutineItem():
return $default(_that.id,_that.exerciseId,_that.position,_that.supersetGroup,_that.targetSets,_that.targetReps,_that.targetDurationSec,_that.targetDistanceM,_that.targetWeightKg,_that.restSec,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  int position,  int? supersetGroup,  int targetSets,  int? targetReps,  int? targetDurationSec,  double? targetDistanceM,  double? targetWeightKg,  int? restSec,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _RoutineItem() when $default != null:
return $default(_that.id,_that.exerciseId,_that.position,_that.supersetGroup,_that.targetSets,_that.targetReps,_that.targetDurationSec,_that.targetDistanceM,_that.targetWeightKg,_that.restSec,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineItem implements RoutineItem {
  const _RoutineItem({required this.id, required this.exerciseId, required this.position, this.supersetGroup, this.targetSets = 3, this.targetReps, this.targetDurationSec, this.targetDistanceM, this.targetWeightKg, this.restSec, this.notes});
  factory _RoutineItem.fromJson(Map<String, dynamic> json) => _$RoutineItemFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  int position;
/// Items sharing a group number form a superset; null is a straight set.
@override final  int? supersetGroup;
@override@JsonKey() final  int targetSets;
@override final  int? targetReps;
@override final  int? targetDurationSec;
@override final  double? targetDistanceM;
@override final  double? targetWeightKg;
@override final  int? restSec;
@override final  String? notes;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineItemCopyWith<_RoutineItem> get copyWith => __$RoutineItemCopyWithImpl<_RoutineItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.position, position) || other.position == position)&&(identical(other.supersetGroup, supersetGroup) || other.supersetGroup == supersetGroup)&&(identical(other.targetSets, targetSets) || other.targetSets == targetSets)&&(identical(other.targetReps, targetReps) || other.targetReps == targetReps)&&(identical(other.targetDurationSec, targetDurationSec) || other.targetDurationSec == targetDurationSec)&&(identical(other.targetDistanceM, targetDistanceM) || other.targetDistanceM == targetDistanceM)&&(identical(other.targetWeightKg, targetWeightKg) || other.targetWeightKg == targetWeightKg)&&(identical(other.restSec, restSec) || other.restSec == restSec)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,position,supersetGroup,targetSets,targetReps,targetDurationSec,targetDistanceM,targetWeightKg,restSec,notes);
}

@override
String toString() {
    return 'RoutineItem(id: $id, exerciseId: $exerciseId, position: $position, supersetGroup: $supersetGroup, targetSets: $targetSets, targetReps: $targetReps, targetDurationSec: $targetDurationSec, targetDistanceM: $targetDistanceM, targetWeightKg: $targetWeightKg, restSec: $restSec, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$RoutineItemCopyWith<$Res> implements $RoutineItemCopyWith<$Res> {
  factory _$RoutineItemCopyWith(_RoutineItem value, $Res Function(_RoutineItem) _then) = __$RoutineItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, int position, int? supersetGroup, int targetSets, int? targetReps, int? targetDurationSec, double? targetDistanceM, double? targetWeightKg, int? restSec, String? notes
});




}
/// @nodoc
class __$RoutineItemCopyWithImpl<$Res>
    implements _$RoutineItemCopyWith<$Res> {
  __$RoutineItemCopyWithImpl(this._self, this._then);

  final _RoutineItem _self;
  final $Res Function(_RoutineItem) _then;

/// Create a copy of RoutineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? position = null,Object? supersetGroup = freezed,Object? targetSets = null,Object? targetReps = freezed,Object? targetDurationSec = freezed,Object? targetDistanceM = freezed,Object? targetWeightKg = freezed,Object? restSec = freezed,Object? notes = freezed,}) {
  return _then(_RoutineItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supersetGroup: freezed == supersetGroup ? _self.supersetGroup : supersetGroup // ignore: cast_nullable_to_non_nullable
as int?,targetSets: null == targetSets ? _self.targetSets : targetSets // ignore: cast_nullable_to_non_nullable
as int,targetReps: freezed == targetReps ? _self.targetReps : targetReps // ignore: cast_nullable_to_non_nullable
as int?,targetDurationSec: freezed == targetDurationSec ? _self.targetDurationSec : targetDurationSec // ignore: cast_nullable_to_non_nullable
as int?,targetDistanceM: freezed == targetDistanceM ? _self.targetDistanceM : targetDistanceM // ignore: cast_nullable_to_non_nullable
as double?,targetWeightKg: freezed == targetWeightKg ? _self.targetWeightKg : targetWeightKg // ignore: cast_nullable_to_non_nullable
as double?,restSec: freezed == restSec ? _self.restSec : restSec // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WorkoutSession {

 String get id; String? get name;@UtcDateTimeConverter() DateTime get startedAt;@NullableUtcDateTimeConverter() DateTime? get endedAt; String? get routineId; String? get notes;/// 1 to 10.
 int? get perceivedEffort; SessionSource get source;/// Cached at finish and recomputed on edit. Estimates, not truth.
 int? get durationSec; double? get volumeKg; double? get caloriesKcal; List<SessionExercise> get exercises;@UtcDateTimeConverter() DateTime get updatedAt;
/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<WorkoutSession> get copyWith => _$WorkoutSessionCopyWithImpl<WorkoutSession>(this as WorkoutSession, _$identity);

  /// Serializes this WorkoutSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkoutSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.routineId, _this.routineId) || other.routineId == _this.routineId)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.perceivedEffort, _this.perceivedEffort) || other.perceivedEffort == _this.perceivedEffort)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.durationSec, _this.durationSec) || other.durationSec == _this.durationSec)&&(identical(other.volumeKg, _this.volumeKg) || other.volumeKg == _this.volumeKg)&&(identical(other.caloriesKcal, _this.caloriesKcal) || other.caloriesKcal == _this.caloriesKcal)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkoutSession;
  return Object.hash(runtimeType,_this.id,_this.name,_this.startedAt,_this.endedAt,_this.routineId,_this.notes,_this.perceivedEffort,_this.source,_this.durationSec,_this.volumeKg,_this.caloriesKcal,const DeepCollectionEquality().hash(_this.exercises),_this.updatedAt);
}

@override
String toString() {
  final _this = this as WorkoutSession;
  return 'WorkoutSession(id: ${_this.id}, name: ${_this.name}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, routineId: ${_this.routineId}, notes: ${_this.notes}, perceivedEffort: ${_this.perceivedEffort}, source: ${_this.source}, durationSec: ${_this.durationSec}, volumeKg: ${_this.volumeKg}, caloriesKcal: ${_this.caloriesKcal}, exercises: ${_this.exercises}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $WorkoutSessionCopyWith<$Res>  {
  factory $WorkoutSessionCopyWith(WorkoutSession value, $Res Function(WorkoutSession) _then) = _$WorkoutSessionCopyWithImpl;
@useResult
$Res call({
 String id, String? name,@UtcDateTimeConverter() DateTime startedAt,@NullableUtcDateTimeConverter() DateTime? endedAt, String? routineId, String? notes, int? perceivedEffort, SessionSource source, int? durationSec, double? volumeKg, double? caloriesKcal, List<SessionExercise> exercises,@UtcDateTimeConverter() DateTime updatedAt
});




}
/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._self, this._then);

  final WorkoutSession _self;
  final $Res Function(WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? startedAt = null,Object? endedAt = freezed,Object? routineId = freezed,Object? notes = freezed,Object? perceivedEffort = freezed,Object? source = null,Object? durationSec = freezed,Object? volumeKg = freezed,Object? caloriesKcal = freezed,Object? exercises = null,Object? updatedAt = null,}) {
  return _then(WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,routineId: freezed == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,perceivedEffort: freezed == perceivedEffort ? _self.perceivedEffort : perceivedEffort // ignore: cast_nullable_to_non_nullable
as int?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SessionSource,durationSec: freezed == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as int?,volumeKg: freezed == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as double?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSession].
extension WorkoutSessionPatterns on WorkoutSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSession value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSession value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name, @UtcDateTimeConverter()  DateTime startedAt, @NullableUtcDateTimeConverter()  DateTime? endedAt,  String? routineId,  String? notes,  int? perceivedEffort,  SessionSource source,  int? durationSec,  double? volumeKg,  double? caloriesKcal,  List<SessionExercise> exercises, @UtcDateTimeConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.name,_that.startedAt,_that.endedAt,_that.routineId,_that.notes,_that.perceivedEffort,_that.source,_that.durationSec,_that.volumeKg,_that.caloriesKcal,_that.exercises,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name, @UtcDateTimeConverter()  DateTime startedAt, @NullableUtcDateTimeConverter()  DateTime? endedAt,  String? routineId,  String? notes,  int? perceivedEffort,  SessionSource source,  int? durationSec,  double? volumeKg,  double? caloriesKcal,  List<SessionExercise> exercises, @UtcDateTimeConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession():
return $default(_that.id,_that.name,_that.startedAt,_that.endedAt,_that.routineId,_that.notes,_that.perceivedEffort,_that.source,_that.durationSec,_that.volumeKg,_that.caloriesKcal,_that.exercises,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name, @UtcDateTimeConverter()  DateTime startedAt, @NullableUtcDateTimeConverter()  DateTime? endedAt,  String? routineId,  String? notes,  int? perceivedEffort,  SessionSource source,  int? durationSec,  double? volumeKg,  double? caloriesKcal,  List<SessionExercise> exercises, @UtcDateTimeConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.name,_that.startedAt,_that.endedAt,_that.routineId,_that.notes,_that.perceivedEffort,_that.source,_that.durationSec,_that.volumeKg,_that.caloriesKcal,_that.exercises,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSession implements WorkoutSession {
  const _WorkoutSession({required this.id, this.name, @UtcDateTimeConverter() required this.startedAt, @NullableUtcDateTimeConverter() this.endedAt, this.routineId, this.notes, this.perceivedEffort, this.source = SessionSource.manual, this.durationSec, this.volumeKg, this.caloriesKcal,  List<SessionExercise> exercises = const <SessionExercise>[], @UtcDateTimeConverter() required this.updatedAt}): _exercises = exercises;
  factory _WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);

@override final  String id;
@override final  String? name;
@override@UtcDateTimeConverter() final  DateTime startedAt;
@override@NullableUtcDateTimeConverter() final  DateTime? endedAt;
@override final  String? routineId;
@override final  String? notes;
/// 1 to 10.
@override final  int? perceivedEffort;
@override@JsonKey() final  SessionSource source;
/// Cached at finish and recomputed on edit. Estimates, not truth.
@override final  int? durationSec;
@override final  double? volumeKg;
@override final  double? caloriesKcal;
 final  List<SessionExercise> _exercises;
@override@JsonKey() List<SessionExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@UtcDateTimeConverter() final  DateTime updatedAt;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSessionCopyWith<_WorkoutSession> get copyWith => __$WorkoutSessionCopyWithImpl<_WorkoutSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSessionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSession&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.perceivedEffort, perceivedEffort) || other.perceivedEffort == perceivedEffort)&&(identical(other.source, source) || other.source == source)&&(identical(other.durationSec, durationSec) || other.durationSec == durationSec)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.caloriesKcal, caloriesKcal) || other.caloriesKcal == caloriesKcal)&&const DeepCollectionEquality().equals(other.exercises, _exercises)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,startedAt,endedAt,routineId,notes,perceivedEffort,source,durationSec,volumeKg,caloriesKcal,const DeepCollectionEquality().hash(_exercises),updatedAt);
}

@override
String toString() {
    return 'WorkoutSession(id: $id, name: $name, startedAt: $startedAt, endedAt: $endedAt, routineId: $routineId, notes: $notes, perceivedEffort: $perceivedEffort, source: $source, durationSec: $durationSec, volumeKg: $volumeKg, caloriesKcal: $caloriesKcal, exercises: $exercises, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSessionCopyWith<$Res> implements $WorkoutSessionCopyWith<$Res> {
  factory _$WorkoutSessionCopyWith(_WorkoutSession value, $Res Function(_WorkoutSession) _then) = __$WorkoutSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name,@UtcDateTimeConverter() DateTime startedAt,@NullableUtcDateTimeConverter() DateTime? endedAt, String? routineId, String? notes, int? perceivedEffort, SessionSource source, int? durationSec, double? volumeKg, double? caloriesKcal, List<SessionExercise> exercises,@UtcDateTimeConverter() DateTime updatedAt
});




}
/// @nodoc
class __$WorkoutSessionCopyWithImpl<$Res>
    implements _$WorkoutSessionCopyWith<$Res> {
  __$WorkoutSessionCopyWithImpl(this._self, this._then);

  final _WorkoutSession _self;
  final $Res Function(_WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? startedAt = null,Object? endedAt = freezed,Object? routineId = freezed,Object? notes = freezed,Object? perceivedEffort = freezed,Object? source = null,Object? durationSec = freezed,Object? volumeKg = freezed,Object? caloriesKcal = freezed,Object? exercises = null,Object? updatedAt = null,}) {
  return _then(_WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,routineId: freezed == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,perceivedEffort: freezed == perceivedEffort ? _self.perceivedEffort : perceivedEffort // ignore: cast_nullable_to_non_nullable
as int?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SessionSource,durationSec: freezed == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as int?,volumeKg: freezed == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double?,caloriesKcal: freezed == caloriesKcal ? _self.caloriesKcal : caloriesKcal // ignore: cast_nullable_to_non_nullable
as double?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SessionExercise {

 String get id; String get exerciseId; int get position; int? get supersetGroup; String? get notes; List<SetEntry> get sets;
/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionExerciseCopyWith<SessionExercise> get copyWith => _$SessionExerciseCopyWithImpl<SessionExercise>(this as SessionExercise, _$identity);

  /// Serializes this SessionExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionExercise;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionExercise&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.supersetGroup, _this.supersetGroup) || other.supersetGroup == _this.supersetGroup)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&const DeepCollectionEquality().equals(other.sets, _this.sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionExercise;
  return Object.hash(runtimeType,_this.id,_this.exerciseId,_this.position,_this.supersetGroup,_this.notes,const DeepCollectionEquality().hash(_this.sets));
}

@override
String toString() {
  final _this = this as SessionExercise;
  return 'SessionExercise(id: ${_this.id}, exerciseId: ${_this.exerciseId}, position: ${_this.position}, supersetGroup: ${_this.supersetGroup}, notes: ${_this.notes}, sets: ${_this.sets})';
}


}

/// @nodoc
abstract mixin class $SessionExerciseCopyWith<$Res>  {
  factory $SessionExerciseCopyWith(SessionExercise value, $Res Function(SessionExercise) _then) = _$SessionExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, int position, int? supersetGroup, String? notes, List<SetEntry> sets
});




}
/// @nodoc
class _$SessionExerciseCopyWithImpl<$Res>
    implements $SessionExerciseCopyWith<$Res> {
  _$SessionExerciseCopyWithImpl(this._self, this._then);

  final SessionExercise _self;
  final $Res Function(SessionExercise) _then;

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? position = null,Object? supersetGroup = freezed,Object? notes = freezed,Object? sets = null,}) {
  return _then(SessionExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supersetGroup: freezed == supersetGroup ? _self.supersetGroup : supersetGroup // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<SetEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionExercise].
extension SessionExercisePatterns on SessionExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionExercise value)  $default,){
final _that = this;
switch (_that) {
case _SessionExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionExercise value)?  $default,){
final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int position,  int? supersetGroup,  String? notes,  List<SetEntry> sets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.position,_that.supersetGroup,_that.notes,_that.sets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int position,  int? supersetGroup,  String? notes,  List<SetEntry> sets)  $default,) {final _that = this;
switch (_that) {
case _SessionExercise():
return $default(_that.id,_that.exerciseId,_that.position,_that.supersetGroup,_that.notes,_that.sets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  int position,  int? supersetGroup,  String? notes,  List<SetEntry> sets)?  $default,) {final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.position,_that.supersetGroup,_that.notes,_that.sets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionExercise implements SessionExercise {
  const _SessionExercise({required this.id, required this.exerciseId, required this.position, this.supersetGroup, this.notes,  List<SetEntry> sets = const <SetEntry>[]}): _sets = sets;
  factory _SessionExercise.fromJson(Map<String, dynamic> json) => _$SessionExerciseFromJson(json);

@override final  String id;
@override final  String exerciseId;
@override final  int position;
@override final  int? supersetGroup;
@override final  String? notes;
 final  List<SetEntry> _sets;
@override@JsonKey() List<SetEntry> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}


/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionExerciseCopyWith<_SessionExercise> get copyWith => __$SessionExerciseCopyWithImpl<_SessionExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.position, position) || other.position == position)&&(identical(other.supersetGroup, supersetGroup) || other.supersetGroup == supersetGroup)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.sets, _sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,exerciseId,position,supersetGroup,notes,const DeepCollectionEquality().hash(_sets));
}

@override
String toString() {
    return 'SessionExercise(id: $id, exerciseId: $exerciseId, position: $position, supersetGroup: $supersetGroup, notes: $notes, sets: $sets)';
}


}

/// @nodoc
abstract mixin class _$SessionExerciseCopyWith<$Res> implements $SessionExerciseCopyWith<$Res> {
  factory _$SessionExerciseCopyWith(_SessionExercise value, $Res Function(_SessionExercise) _then) = __$SessionExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, int position, int? supersetGroup, String? notes, List<SetEntry> sets
});




}
/// @nodoc
class __$SessionExerciseCopyWithImpl<$Res>
    implements _$SessionExerciseCopyWith<$Res> {
  __$SessionExerciseCopyWithImpl(this._self, this._then);

  final _SessionExercise _self;
  final $Res Function(_SessionExercise) _then;

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? position = null,Object? supersetGroup = freezed,Object? notes = freezed,Object? sets = null,}) {
  return _then(_SessionExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supersetGroup: freezed == supersetGroup ? _self.supersetGroup : supersetGroup // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<SetEntry>,
  ));
}


}


/// @nodoc
mixin _$SetEntry {

 String get id; int get position; SetType get type; double? get weightKg; int? get reps; int? get durationSec; double? get distanceM; int? get rounds; int? get holdSec; bool get completed; bool get isWarmup; bool get isPR;@NullableUtcDateTimeConverter() DateTime? get completedAt;
/// Create a copy of SetEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetEntryCopyWith<SetEntry> get copyWith => _$SetEntryCopyWithImpl<SetEntry>(this as SetEntry, _$identity);

  /// Serializes this SetEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.weightKg, _this.weightKg) || other.weightKg == _this.weightKg)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.durationSec, _this.durationSec) || other.durationSec == _this.durationSec)&&(identical(other.distanceM, _this.distanceM) || other.distanceM == _this.distanceM)&&(identical(other.rounds, _this.rounds) || other.rounds == _this.rounds)&&(identical(other.holdSec, _this.holdSec) || other.holdSec == _this.holdSec)&&(identical(other.completed, _this.completed) || other.completed == _this.completed)&&(identical(other.isWarmup, _this.isWarmup) || other.isWarmup == _this.isWarmup)&&(identical(other.isPR, _this.isPR) || other.isPR == _this.isPR)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetEntry;
  return Object.hash(runtimeType,_this.id,_this.position,_this.type,_this.weightKg,_this.reps,_this.durationSec,_this.distanceM,_this.rounds,_this.holdSec,_this.completed,_this.isWarmup,_this.isPR,_this.completedAt);
}

@override
String toString() {
  final _this = this as SetEntry;
  return 'SetEntry(id: ${_this.id}, position: ${_this.position}, type: ${_this.type}, weightKg: ${_this.weightKg}, reps: ${_this.reps}, durationSec: ${_this.durationSec}, distanceM: ${_this.distanceM}, rounds: ${_this.rounds}, holdSec: ${_this.holdSec}, completed: ${_this.completed}, isWarmup: ${_this.isWarmup}, isPR: ${_this.isPR}, completedAt: ${_this.completedAt})';
}


}

/// @nodoc
abstract mixin class $SetEntryCopyWith<$Res>  {
  factory $SetEntryCopyWith(SetEntry value, $Res Function(SetEntry) _then) = _$SetEntryCopyWithImpl;
@useResult
$Res call({
 String id, int position, SetType type, double? weightKg, int? reps, int? durationSec, double? distanceM, int? rounds, int? holdSec, bool completed, bool isWarmup, bool isPR,@NullableUtcDateTimeConverter() DateTime? completedAt
});




}
/// @nodoc
class _$SetEntryCopyWithImpl<$Res>
    implements $SetEntryCopyWith<$Res> {
  _$SetEntryCopyWithImpl(this._self, this._then);

  final SetEntry _self;
  final $Res Function(SetEntry) _then;

/// Create a copy of SetEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? position = null,Object? type = null,Object? weightKg = freezed,Object? reps = freezed,Object? durationSec = freezed,Object? distanceM = freezed,Object? rounds = freezed,Object? holdSec = freezed,Object? completed = null,Object? isWarmup = null,Object? isPR = null,Object? completedAt = freezed,}) {
  return _then(SetEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SetType,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,durationSec: freezed == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as int?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double?,rounds: freezed == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int?,holdSec: freezed == holdSec ? _self.holdSec : holdSec // ignore: cast_nullable_to_non_nullable
as int?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,isWarmup: null == isWarmup ? _self.isWarmup : isWarmup // ignore: cast_nullable_to_non_nullable
as bool,isPR: null == isPR ? _self.isPR : isPR // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SetEntry].
extension SetEntryPatterns on SetEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetEntry value)  $default,){
final _that = this;
switch (_that) {
case _SetEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SetEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int position,  SetType type,  double? weightKg,  int? reps,  int? durationSec,  double? distanceM,  int? rounds,  int? holdSec,  bool completed,  bool isWarmup,  bool isPR, @NullableUtcDateTimeConverter()  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetEntry() when $default != null:
return $default(_that.id,_that.position,_that.type,_that.weightKg,_that.reps,_that.durationSec,_that.distanceM,_that.rounds,_that.holdSec,_that.completed,_that.isWarmup,_that.isPR,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int position,  SetType type,  double? weightKg,  int? reps,  int? durationSec,  double? distanceM,  int? rounds,  int? holdSec,  bool completed,  bool isWarmup,  bool isPR, @NullableUtcDateTimeConverter()  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _SetEntry():
return $default(_that.id,_that.position,_that.type,_that.weightKg,_that.reps,_that.durationSec,_that.distanceM,_that.rounds,_that.holdSec,_that.completed,_that.isWarmup,_that.isPR,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int position,  SetType type,  double? weightKg,  int? reps,  int? durationSec,  double? distanceM,  int? rounds,  int? holdSec,  bool completed,  bool isWarmup,  bool isPR, @NullableUtcDateTimeConverter()  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _SetEntry() when $default != null:
return $default(_that.id,_that.position,_that.type,_that.weightKg,_that.reps,_that.durationSec,_that.distanceM,_that.rounds,_that.holdSec,_that.completed,_that.isWarmup,_that.isPR,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetEntry implements SetEntry {
  const _SetEntry({required this.id, required this.position, this.type = SetType.normal, this.weightKg, this.reps, this.durationSec, this.distanceM, this.rounds, this.holdSec, this.completed = false, this.isWarmup = false, this.isPR = false, @NullableUtcDateTimeConverter() this.completedAt});
  factory _SetEntry.fromJson(Map<String, dynamic> json) => _$SetEntryFromJson(json);

@override final  String id;
@override final  int position;
@override@JsonKey() final  SetType type;
@override final  double? weightKg;
@override final  int? reps;
@override final  int? durationSec;
@override final  double? distanceM;
@override final  int? rounds;
@override final  int? holdSec;
@override@JsonKey() final  bool completed;
@override@JsonKey() final  bool isWarmup;
@override@JsonKey() final  bool isPR;
@override@NullableUtcDateTimeConverter() final  DateTime? completedAt;

/// Create a copy of SetEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetEntryCopyWith<_SetEntry> get copyWith => __$SetEntryCopyWithImpl<_SetEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&(identical(other.type, type) || other.type == type)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.durationSec, durationSec) || other.durationSec == durationSec)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.rounds, rounds) || other.rounds == rounds)&&(identical(other.holdSec, holdSec) || other.holdSec == holdSec)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.isWarmup, isWarmup) || other.isWarmup == isWarmup)&&(identical(other.isPR, isPR) || other.isPR == isPR)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,position,type,weightKg,reps,durationSec,distanceM,rounds,holdSec,completed,isWarmup,isPR,completedAt);
}

@override
String toString() {
    return 'SetEntry(id: $id, position: $position, type: $type, weightKg: $weightKg, reps: $reps, durationSec: $durationSec, distanceM: $distanceM, rounds: $rounds, holdSec: $holdSec, completed: $completed, isWarmup: $isWarmup, isPR: $isPR, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$SetEntryCopyWith<$Res> implements $SetEntryCopyWith<$Res> {
  factory _$SetEntryCopyWith(_SetEntry value, $Res Function(_SetEntry) _then) = __$SetEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, int position, SetType type, double? weightKg, int? reps, int? durationSec, double? distanceM, int? rounds, int? holdSec, bool completed, bool isWarmup, bool isPR,@NullableUtcDateTimeConverter() DateTime? completedAt
});




}
/// @nodoc
class __$SetEntryCopyWithImpl<$Res>
    implements _$SetEntryCopyWith<$Res> {
  __$SetEntryCopyWithImpl(this._self, this._then);

  final _SetEntry _self;
  final $Res Function(_SetEntry) _then;

/// Create a copy of SetEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? position = null,Object? type = null,Object? weightKg = freezed,Object? reps = freezed,Object? durationSec = freezed,Object? distanceM = freezed,Object? rounds = freezed,Object? holdSec = freezed,Object? completed = null,Object? isWarmup = null,Object? isPR = null,Object? completedAt = freezed,}) {
  return _then(_SetEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SetType,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,durationSec: freezed == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as int?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double?,rounds: freezed == rounds ? _self.rounds : rounds // ignore: cast_nullable_to_non_nullable
as int?,holdSec: freezed == holdSec ? _self.holdSec : holdSec // ignore: cast_nullable_to_non_nullable
as int?,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,isWarmup: null == isWarmup ? _self.isWarmup : isWarmup // ignore: cast_nullable_to_non_nullable
as bool,isPR: null == isPR ? _self.isPR : isPR // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
