import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'utc_date_time.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// The one user profile. Every value is metric; units only change display.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    Sex? sex,
    int? birthYear,
    double? heightCm,
    @Default(ActivityLevel.moderate) ActivityLevel activityLevel,
    @Default(WeightUnit.kg) WeightUnit weightUnit,
    @Default(LengthUnit.cm) LengthUnit lengthUnit,
    @Default(DistanceUnit.km) DistanceUnit distanceUnit,
    @Default(BmiCutoffs.who) BmiCutoffs bmiCutoffs,
    @NullableUtcDateTimeConverter() DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
