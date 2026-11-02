/// Inputs a body stat can depend on. The UI uses the list in
/// [MissingInputs] to explain a locked card.
enum StatInput {
  weight,
  height,
  age,
  sex,
  waist,
  neck,
  hips,
  bodyFat,
  activityLevel,
}

/// The outcome of one stat: a value, the inputs that are missing, or inputs
/// that are present but cannot produce a number. Sealed, so a `switch` over
/// it is exhaustive. Never NaN, never throws.
sealed class StatResult<T> {
  const StatResult();

  /// The value, or null when the stat is locked or invalid.
  T? get valueOrNull {
    final StatResult<T> self = this;
    return self is StatValue<T> ? self.value : null;
  }
}

final class StatValue<T> extends StatResult<T> {
  const StatValue(
    this.value, {
    this.approximate = false,
    this.estimated = false,
  });

  final T value;

  /// A needed input was defaulted (for example BMR with no sex set).
  final bool approximate;

  /// An inherently rough figure (calories burned, a Navy body fat estimate).
  final bool estimated;

  @override
  bool operator ==(Object other) =>
      other is StatValue<T> &&
      other.value == value &&
      other.approximate == approximate &&
      other.estimated == estimated;

  @override
  int get hashCode => Object.hash(value, approximate, estimated);

  @override
  String toString() =>
      'StatValue($value, approximate: $approximate, estimated: $estimated)';
}

final class MissingInputs<T> extends StatResult<T> {
  const MissingInputs(this.missing);

  final List<StatInput> missing;

  @override
  bool operator ==(Object other) =>
      other is MissingInputs<T> && _listEq(other.missing, missing);

  @override
  int get hashCode => Object.hashAll(missing);

  @override
  String toString() => 'MissingInputs($missing)';
}

/// Inputs are all present but the geometry is impossible (waist not larger
/// than neck, a non-positive height). [invalid] names the offending inputs.
final class InvalidInputs<T> extends StatResult<T> {
  const InvalidInputs(this.invalid);

  final List<StatInput> invalid;

  @override
  bool operator ==(Object other) =>
      other is InvalidInputs<T> && _listEq(other.invalid, invalid);

  @override
  int get hashCode => Object.hashAll(invalid);

  @override
  String toString() => 'InvalidInputs($invalid)';
}

bool _listEq(List<StatInput> a, List<StatInput> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
