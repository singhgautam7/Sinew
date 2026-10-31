import 'package:drift/drift.dart';

import '../../models/profile.dart';
import '../ids.dart';
import '../user/user_db.dart';

/// The single user profile. Missing row reads as defaults.
class ProfileRepository {
  ProfileRepository(this._db, {this._clock = systemClock});

  final UserDatabase _db;
  final Clock _clock;

  Future<Profile> get() async => _map(await _query().getSingleOrNull());

  Stream<Profile> watch() => _query().watchSingleOrNull().map(_map);

  Future<void> save(Profile p) => _db
      .into(_db.profiles)
      .insertOnConflictUpdate(
        ProfilesCompanion.insert(
          id: const Value<String>('me'),
          sex: Value(p.sex),
          birthYear: Value(p.birthYear),
          heightCm: Value(p.heightCm),
          activityLevel: Value(p.activityLevel),
          weightUnit: Value(p.weightUnit),
          lengthUnit: Value(p.lengthUnit),
          distanceUnit: Value(p.distanceUnit),
          bmiCutoffs: Value(p.bmiCutoffs),
          updatedAt: p.updatedAt ?? _clock(),
        ),
      );

  SingleOrNullSelectable<ProfileRow> _query() =>
      _db.select(_db.profiles)..where(($ProfilesTable t) => t.id.equals('me'));

  static Profile _map(ProfileRow? r) => r == null
      ? const Profile()
      : Profile(
          sex: r.sex,
          birthYear: r.birthYear,
          heightCm: r.heightCm,
          activityLevel: r.activityLevel,
          weightUnit: r.weightUnit,
          lengthUnit: r.lengthUnit,
          distanceUnit: r.distanceUnit,
          bmiCutoffs: r.bmiCutoffs,
          updatedAt: r.updatedAt,
        );
}
