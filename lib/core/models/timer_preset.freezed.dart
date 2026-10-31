// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimerPreset {

 int get schemaVersion; String get id; String get name; TimerMode get mode; List<TimerStepSpec> get steps; TimerCues get cues; int get position; bool get builtIn; DateTime get updatedAt;
/// Create a copy of TimerPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerPresetCopyWith<TimerPreset> get copyWith => _$TimerPresetCopyWithImpl<TimerPreset>(this as TimerPreset, _$identity);

  /// Serializes this TimerPreset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TimerPreset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerPreset&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&const DeepCollectionEquality().equals(other.steps, _this.steps)&&(identical(other.cues, _this.cues) || other.cues == _this.cues)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.builtIn, _this.builtIn) || other.builtIn == _this.builtIn)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimerPreset;
  return Object.hash(runtimeType,_this.schemaVersion,_this.id,_this.name,_this.mode,const DeepCollectionEquality().hash(_this.steps),_this.cues,_this.position,_this.builtIn,_this.updatedAt);
}

@override
String toString() {
  final _this = this as TimerPreset;
  return 'TimerPreset(schemaVersion: ${_this.schemaVersion}, id: ${_this.id}, name: ${_this.name}, mode: ${_this.mode}, steps: ${_this.steps}, cues: ${_this.cues}, position: ${_this.position}, builtIn: ${_this.builtIn}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $TimerPresetCopyWith<$Res>  {
  factory $TimerPresetCopyWith(TimerPreset value, $Res Function(TimerPreset) _then) = _$TimerPresetCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String id, String name, TimerMode mode, List<TimerStepSpec> steps, TimerCues cues, int position, bool builtIn, DateTime updatedAt
});


$TimerCuesCopyWith<$Res> get cues;

}
/// @nodoc
class _$TimerPresetCopyWithImpl<$Res>
    implements $TimerPresetCopyWith<$Res> {
  _$TimerPresetCopyWithImpl(this._self, this._then);

  final TimerPreset _self;
  final $Res Function(TimerPreset) _then;

/// Create a copy of TimerPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? id = null,Object? name = null,Object? mode = null,Object? steps = null,Object? cues = null,Object? position = null,Object? builtIn = null,Object? updatedAt = null,}) {
  return _then(TimerPreset(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as TimerMode,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<TimerStepSpec>,cues: null == cues ? _self.cues : cues // ignore: cast_nullable_to_non_nullable
as TimerCues,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,builtIn: null == builtIn ? _self.builtIn : builtIn // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of TimerPreset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimerCuesCopyWith<$Res> get cues {
  
  return $TimerCuesCopyWith<$Res>(_self.cues, (value) {
    return _then(_self.copyWith(cues: value));
  });
}
}


/// Adds pattern-matching-related methods to [TimerPreset].
extension TimerPresetPatterns on TimerPreset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerPreset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerPreset value)  $default,){
final _that = this;
switch (_that) {
case _TimerPreset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerPreset value)?  $default,){
final _that = this;
switch (_that) {
case _TimerPreset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String name,  TimerMode mode,  List<TimerStepSpec> steps,  TimerCues cues,  int position,  bool builtIn,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerPreset() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.name,_that.mode,_that.steps,_that.cues,_that.position,_that.builtIn,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String name,  TimerMode mode,  List<TimerStepSpec> steps,  TimerCues cues,  int position,  bool builtIn,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TimerPreset():
return $default(_that.schemaVersion,_that.id,_that.name,_that.mode,_that.steps,_that.cues,_that.position,_that.builtIn,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String id,  String name,  TimerMode mode,  List<TimerStepSpec> steps,  TimerCues cues,  int position,  bool builtIn,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TimerPreset() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.name,_that.mode,_that.steps,_that.cues,_that.position,_that.builtIn,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimerPreset implements TimerPreset {
  const _TimerPreset({this.schemaVersion = TimerPreset.currentSchemaVersion, required this.id, required this.name, required this.mode,  List<TimerStepSpec> steps = const <TimerStepSpec>[], this.cues = const TimerCues(), this.position = 0, this.builtIn = false, required this.updatedAt}): _steps = steps;
  factory _TimerPreset.fromJson(Map<String, dynamic> json) => _$TimerPresetFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override final  String id;
@override final  String name;
@override final  TimerMode mode;
 final  List<TimerStepSpec> _steps;
@override@JsonKey() List<TimerStepSpec> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

@override@JsonKey() final  TimerCues cues;
@override@JsonKey() final  int position;
@override@JsonKey() final  bool builtIn;
@override final  DateTime updatedAt;

/// Create a copy of TimerPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerPresetCopyWith<_TimerPreset> get copyWith => __$TimerPresetCopyWithImpl<_TimerPreset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimerPresetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerPreset&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other.steps, _steps)&&(identical(other.cues, cues) || other.cues == cues)&&(identical(other.position, position) || other.position == position)&&(identical(other.builtIn, builtIn) || other.builtIn == builtIn)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,id,name,mode,const DeepCollectionEquality().hash(_steps),cues,position,builtIn,updatedAt);
}

@override
String toString() {
    return 'TimerPreset(schemaVersion: $schemaVersion, id: $id, name: $name, mode: $mode, steps: $steps, cues: $cues, position: $position, builtIn: $builtIn, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TimerPresetCopyWith<$Res> implements $TimerPresetCopyWith<$Res> {
  factory _$TimerPresetCopyWith(_TimerPreset value, $Res Function(_TimerPreset) _then) = __$TimerPresetCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String id, String name, TimerMode mode, List<TimerStepSpec> steps, TimerCues cues, int position, bool builtIn, DateTime updatedAt
});


@override $TimerCuesCopyWith<$Res> get cues;

}
/// @nodoc
class __$TimerPresetCopyWithImpl<$Res>
    implements _$TimerPresetCopyWith<$Res> {
  __$TimerPresetCopyWithImpl(this._self, this._then);

  final _TimerPreset _self;
  final $Res Function(_TimerPreset) _then;

/// Create a copy of TimerPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? id = null,Object? name = null,Object? mode = null,Object? steps = null,Object? cues = null,Object? position = null,Object? builtIn = null,Object? updatedAt = null,}) {
  return _then(_TimerPreset(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as TimerMode,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<TimerStepSpec>,cues: null == cues ? _self.cues : cues // ignore: cast_nullable_to_non_nullable
as TimerCues,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,builtIn: null == builtIn ? _self.builtIn : builtIn // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of TimerPreset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimerCuesCopyWith<$Res> get cues {
  
  return $TimerCuesCopyWith<$Res>(_self.cues, (value) {
    return _then(_self.copyWith(cues: value));
  });
}
}


/// @nodoc
mixin _$TimerStepSpec {

 String get label; int? get durationMs;@JsonKey(unknownEnumValue: TimerPhase.work) TimerPhase get phase; String? get exerciseId;
/// Create a copy of TimerStepSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerStepSpecCopyWith<TimerStepSpec> get copyWith => _$TimerStepSpecCopyWithImpl<TimerStepSpec>(this as TimerStepSpec, _$identity);

  /// Serializes this TimerStepSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TimerStepSpec;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerStepSpec&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.durationMs, _this.durationMs) || other.durationMs == _this.durationMs)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimerStepSpec;
  return Object.hash(runtimeType,_this.label,_this.durationMs,_this.phase,_this.exerciseId);
}

@override
String toString() {
  final _this = this as TimerStepSpec;
  return 'TimerStepSpec(label: ${_this.label}, durationMs: ${_this.durationMs}, phase: ${_this.phase}, exerciseId: ${_this.exerciseId})';
}


}

/// @nodoc
abstract mixin class $TimerStepSpecCopyWith<$Res>  {
  factory $TimerStepSpecCopyWith(TimerStepSpec value, $Res Function(TimerStepSpec) _then) = _$TimerStepSpecCopyWithImpl;
@useResult
$Res call({
 String label, int? durationMs,@JsonKey(unknownEnumValue: TimerPhase.work) TimerPhase phase, String? exerciseId
});




}
/// @nodoc
class _$TimerStepSpecCopyWithImpl<$Res>
    implements $TimerStepSpecCopyWith<$Res> {
  _$TimerStepSpecCopyWithImpl(this._self, this._then);

  final TimerStepSpec _self;
  final $Res Function(TimerStepSpec) _then;

/// Create a copy of TimerStepSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? durationMs = freezed,Object? phase = null,Object? exerciseId = freezed,}) {
  return _then(TimerStepSpec(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TimerPhase,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerStepSpec].
extension TimerStepSpecPatterns on TimerStepSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerStepSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerStepSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerStepSpec value)  $default,){
final _that = this;
switch (_that) {
case _TimerStepSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerStepSpec value)?  $default,){
final _that = this;
switch (_that) {
case _TimerStepSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int? durationMs, @JsonKey(unknownEnumValue: TimerPhase.work)  TimerPhase phase,  String? exerciseId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerStepSpec() when $default != null:
return $default(_that.label,_that.durationMs,_that.phase,_that.exerciseId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int? durationMs, @JsonKey(unknownEnumValue: TimerPhase.work)  TimerPhase phase,  String? exerciseId)  $default,) {final _that = this;
switch (_that) {
case _TimerStepSpec():
return $default(_that.label,_that.durationMs,_that.phase,_that.exerciseId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int? durationMs, @JsonKey(unknownEnumValue: TimerPhase.work)  TimerPhase phase,  String? exerciseId)?  $default,) {final _that = this;
switch (_that) {
case _TimerStepSpec() when $default != null:
return $default(_that.label,_that.durationMs,_that.phase,_that.exerciseId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimerStepSpec implements TimerStepSpec {
  const _TimerStepSpec({required this.label, this.durationMs, @JsonKey(unknownEnumValue: TimerPhase.work) required this.phase, this.exerciseId});
  factory _TimerStepSpec.fromJson(Map<String, dynamic> json) => _$TimerStepSpecFromJson(json);

@override final  String label;
@override final  int? durationMs;
@override@JsonKey(unknownEnumValue: TimerPhase.work) final  TimerPhase phase;
@override final  String? exerciseId;

/// Create a copy of TimerStepSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerStepSpecCopyWith<_TimerStepSpec> get copyWith => __$TimerStepSpecCopyWithImpl<_TimerStepSpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimerStepSpecToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerStepSpec&&(identical(other.label, label) || other.label == label)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,durationMs,phase,exerciseId);
}

@override
String toString() {
    return 'TimerStepSpec(label: $label, durationMs: $durationMs, phase: $phase, exerciseId: $exerciseId)';
}


}

/// @nodoc
abstract mixin class _$TimerStepSpecCopyWith<$Res> implements $TimerStepSpecCopyWith<$Res> {
  factory _$TimerStepSpecCopyWith(_TimerStepSpec value, $Res Function(_TimerStepSpec) _then) = __$TimerStepSpecCopyWithImpl;
@override @useResult
$Res call({
 String label, int? durationMs,@JsonKey(unknownEnumValue: TimerPhase.work) TimerPhase phase, String? exerciseId
});




}
/// @nodoc
class __$TimerStepSpecCopyWithImpl<$Res>
    implements _$TimerStepSpecCopyWith<$Res> {
  __$TimerStepSpecCopyWithImpl(this._self, this._then);

  final _TimerStepSpec _self;
  final $Res Function(_TimerStepSpec) _then;

/// Create a copy of TimerStepSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? durationMs = freezed,Object? phase = null,Object? exerciseId = freezed,}) {
  return _then(_TimerStepSpec(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TimerPhase,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TimerCues {

 bool get sound; bool get haptic; bool get voice;/// Spoken/beeped countdown over the last N seconds of a step.
 int get countdownSec;/// A warning this many seconds before a step ends (boxing: 10).
 int? get warningSec;
/// Create a copy of TimerCues
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerCuesCopyWith<TimerCues> get copyWith => _$TimerCuesCopyWithImpl<TimerCues>(this as TimerCues, _$identity);

  /// Serializes this TimerCues to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TimerCues;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerCues&&(identical(other.sound, _this.sound) || other.sound == _this.sound)&&(identical(other.haptic, _this.haptic) || other.haptic == _this.haptic)&&(identical(other.voice, _this.voice) || other.voice == _this.voice)&&(identical(other.countdownSec, _this.countdownSec) || other.countdownSec == _this.countdownSec)&&(identical(other.warningSec, _this.warningSec) || other.warningSec == _this.warningSec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimerCues;
  return Object.hash(runtimeType,_this.sound,_this.haptic,_this.voice,_this.countdownSec,_this.warningSec);
}

@override
String toString() {
  final _this = this as TimerCues;
  return 'TimerCues(sound: ${_this.sound}, haptic: ${_this.haptic}, voice: ${_this.voice}, countdownSec: ${_this.countdownSec}, warningSec: ${_this.warningSec})';
}


}

/// @nodoc
abstract mixin class $TimerCuesCopyWith<$Res>  {
  factory $TimerCuesCopyWith(TimerCues value, $Res Function(TimerCues) _then) = _$TimerCuesCopyWithImpl;
@useResult
$Res call({
 bool sound, bool haptic, bool voice, int countdownSec, int? warningSec
});




}
/// @nodoc
class _$TimerCuesCopyWithImpl<$Res>
    implements $TimerCuesCopyWith<$Res> {
  _$TimerCuesCopyWithImpl(this._self, this._then);

  final TimerCues _self;
  final $Res Function(TimerCues) _then;

/// Create a copy of TimerCues
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sound = null,Object? haptic = null,Object? voice = null,Object? countdownSec = null,Object? warningSec = freezed,}) {
  return _then(TimerCues(
sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as bool,haptic: null == haptic ? _self.haptic : haptic // ignore: cast_nullable_to_non_nullable
as bool,voice: null == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as bool,countdownSec: null == countdownSec ? _self.countdownSec : countdownSec // ignore: cast_nullable_to_non_nullable
as int,warningSec: freezed == warningSec ? _self.warningSec : warningSec // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerCues].
extension TimerCuesPatterns on TimerCues {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerCues value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerCues() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerCues value)  $default,){
final _that = this;
switch (_that) {
case _TimerCues():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerCues value)?  $default,){
final _that = this;
switch (_that) {
case _TimerCues() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool sound,  bool haptic,  bool voice,  int countdownSec,  int? warningSec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerCues() when $default != null:
return $default(_that.sound,_that.haptic,_that.voice,_that.countdownSec,_that.warningSec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool sound,  bool haptic,  bool voice,  int countdownSec,  int? warningSec)  $default,) {final _that = this;
switch (_that) {
case _TimerCues():
return $default(_that.sound,_that.haptic,_that.voice,_that.countdownSec,_that.warningSec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool sound,  bool haptic,  bool voice,  int countdownSec,  int? warningSec)?  $default,) {final _that = this;
switch (_that) {
case _TimerCues() when $default != null:
return $default(_that.sound,_that.haptic,_that.voice,_that.countdownSec,_that.warningSec);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimerCues implements TimerCues {
  const _TimerCues({this.sound = true, this.haptic = true, this.voice = false, this.countdownSec = 3, this.warningSec});
  factory _TimerCues.fromJson(Map<String, dynamic> json) => _$TimerCuesFromJson(json);

@override@JsonKey() final  bool sound;
@override@JsonKey() final  bool haptic;
@override@JsonKey() final  bool voice;
/// Spoken/beeped countdown over the last N seconds of a step.
@override@JsonKey() final  int countdownSec;
/// A warning this many seconds before a step ends (boxing: 10).
@override final  int? warningSec;

/// Create a copy of TimerCues
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerCuesCopyWith<_TimerCues> get copyWith => __$TimerCuesCopyWithImpl<_TimerCues>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimerCuesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerCues&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.haptic, haptic) || other.haptic == haptic)&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.countdownSec, countdownSec) || other.countdownSec == countdownSec)&&(identical(other.warningSec, warningSec) || other.warningSec == warningSec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sound,haptic,voice,countdownSec,warningSec);
}

@override
String toString() {
    return 'TimerCues(sound: $sound, haptic: $haptic, voice: $voice, countdownSec: $countdownSec, warningSec: $warningSec)';
}


}

/// @nodoc
abstract mixin class _$TimerCuesCopyWith<$Res> implements $TimerCuesCopyWith<$Res> {
  factory _$TimerCuesCopyWith(_TimerCues value, $Res Function(_TimerCues) _then) = __$TimerCuesCopyWithImpl;
@override @useResult
$Res call({
 bool sound, bool haptic, bool voice, int countdownSec, int? warningSec
});




}
/// @nodoc
class __$TimerCuesCopyWithImpl<$Res>
    implements _$TimerCuesCopyWith<$Res> {
  __$TimerCuesCopyWithImpl(this._self, this._then);

  final _TimerCues _self;
  final $Res Function(_TimerCues) _then;

/// Create a copy of TimerCues
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sound = null,Object? haptic = null,Object? voice = null,Object? countdownSec = null,Object? warningSec = freezed,}) {
  return _then(_TimerCues(
sound: null == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as bool,haptic: null == haptic ? _self.haptic : haptic // ignore: cast_nullable_to_non_nullable
as bool,voice: null == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as bool,countdownSec: null == countdownSec ? _self.countdownSec : countdownSec // ignore: cast_nullable_to_non_nullable
as int,warningSec: freezed == warningSec ? _self.warningSec : warningSec // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
