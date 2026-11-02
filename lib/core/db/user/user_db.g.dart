// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_db.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('me'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Sex?, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Sex?>($ProfilesTable.$convertersexn);
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityLevel, String>
  activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(ActivityLevel.moderate.name),
  ).withConverter<ActivityLevel>($ProfilesTable.$converteractivityLevel);
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, String> weightUnit =
      GeneratedColumn<String>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(WeightUnit.kg.name),
      ).withConverter<WeightUnit>($ProfilesTable.$converterweightUnit);
  @override
  late final GeneratedColumnWithTypeConverter<LengthUnit, String> lengthUnit =
      GeneratedColumn<String>(
        'length_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(LengthUnit.cm.name),
      ).withConverter<LengthUnit>($ProfilesTable.$converterlengthUnit);
  @override
  late final GeneratedColumnWithTypeConverter<DistanceUnit, String>
  distanceUnit = GeneratedColumn<String>(
    'distance_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(DistanceUnit.km.name),
  ).withConverter<DistanceUnit>($ProfilesTable.$converterdistanceUnit);
  @override
  late final GeneratedColumnWithTypeConverter<BmiCutoffs, String> bmiCutoffs =
      GeneratedColumn<String>(
        'bmi_cutoffs',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(BmiCutoffs.who.name),
      ).withConverter<BmiCutoffs>($ProfilesTable.$converterbmiCutoffs);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sex,
    birthYear,
    heightCm,
    activityLevel,
    weightUnit,
    lengthUnit,
    distanceUnit,
    bmiCutoffs,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sex: $ProfilesTable.$convertersexn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        ),
      ),
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      activityLevel: $ProfilesTable.$converteractivityLevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_level'],
        )!,
      ),
      weightUnit: $ProfilesTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
      lengthUnit: $ProfilesTable.$converterlengthUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}length_unit'],
        )!,
      ),
      distanceUnit: $ProfilesTable.$converterdistanceUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}distance_unit'],
        )!,
      ),
      bmiCutoffs: $ProfilesTable.$converterbmiCutoffs.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}bmi_cutoffs'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Sex, String, String> $convertersex =
      const EnumNameConverter<Sex>(Sex.values);
  static JsonTypeConverter2<Sex?, String?, String?> $convertersexn =
      JsonTypeConverter2.asNullable($convertersex);
  static JsonTypeConverter2<ActivityLevel, String, String>
  $converteractivityLevel = const EnumNameConverter<ActivityLevel>(
    ActivityLevel.values,
  );
  static JsonTypeConverter2<WeightUnit, String, String> $converterweightUnit =
      const EnumNameConverter<WeightUnit>(WeightUnit.values);
  static JsonTypeConverter2<LengthUnit, String, String> $converterlengthUnit =
      const EnumNameConverter<LengthUnit>(LengthUnit.values);
  static JsonTypeConverter2<DistanceUnit, String, String>
  $converterdistanceUnit = const EnumNameConverter<DistanceUnit>(
    DistanceUnit.values,
  );
  static JsonTypeConverter2<BmiCutoffs, String, String> $converterbmiCutoffs =
      const EnumNameConverter<BmiCutoffs>(BmiCutoffs.values);
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String id;
  final Sex? sex;
  final int? birthYear;
  final double? heightCm;
  final ActivityLevel activityLevel;
  final WeightUnit weightUnit;
  final LengthUnit lengthUnit;
  final DistanceUnit distanceUnit;
  final BmiCutoffs bmiCutoffs;
  final DateTime updatedAt;
  const ProfileRow({
    required this.id,
    this.sex,
    this.birthYear,
    this.heightCm,
    required this.activityLevel,
    required this.weightUnit,
    required this.lengthUnit,
    required this.distanceUnit,
    required this.bmiCutoffs,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>($ProfilesTable.$convertersexn.toSql(sex));
    }
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    {
      map['activity_level'] = Variable<String>(
        $ProfilesTable.$converteractivityLevel.toSql(activityLevel),
      );
    }
    {
      map['weight_unit'] = Variable<String>(
        $ProfilesTable.$converterweightUnit.toSql(weightUnit),
      );
    }
    {
      map['length_unit'] = Variable<String>(
        $ProfilesTable.$converterlengthUnit.toSql(lengthUnit),
      );
    }
    {
      map['distance_unit'] = Variable<String>(
        $ProfilesTable.$converterdistanceUnit.toSql(distanceUnit),
      );
    }
    {
      map['bmi_cutoffs'] = Variable<String>(
        $ProfilesTable.$converterbmiCutoffs.toSql(bmiCutoffs),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      birthYear: birthYear == null && nullToAbsent
          ? const Value.absent()
          : Value(birthYear),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      activityLevel: Value(activityLevel),
      weightUnit: Value(weightUnit),
      lengthUnit: Value(lengthUnit),
      distanceUnit: Value(distanceUnit),
      bmiCutoffs: Value(bmiCutoffs),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<String>(json['id']),
      sex: $ProfilesTable.$convertersexn.fromJson(
        serializer.fromJson<String?>(json['sex']),
      ),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      activityLevel: $ProfilesTable.$converteractivityLevel.fromJson(
        serializer.fromJson<String>(json['activityLevel']),
      ),
      weightUnit: $ProfilesTable.$converterweightUnit.fromJson(
        serializer.fromJson<String>(json['weightUnit']),
      ),
      lengthUnit: $ProfilesTable.$converterlengthUnit.fromJson(
        serializer.fromJson<String>(json['lengthUnit']),
      ),
      distanceUnit: $ProfilesTable.$converterdistanceUnit.fromJson(
        serializer.fromJson<String>(json['distanceUnit']),
      ),
      bmiCutoffs: $ProfilesTable.$converterbmiCutoffs.fromJson(
        serializer.fromJson<String>(json['bmiCutoffs']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sex': serializer.toJson<String?>(
        $ProfilesTable.$convertersexn.toJson(sex),
      ),
      'birthYear': serializer.toJson<int?>(birthYear),
      'heightCm': serializer.toJson<double?>(heightCm),
      'activityLevel': serializer.toJson<String>(
        $ProfilesTable.$converteractivityLevel.toJson(activityLevel),
      ),
      'weightUnit': serializer.toJson<String>(
        $ProfilesTable.$converterweightUnit.toJson(weightUnit),
      ),
      'lengthUnit': serializer.toJson<String>(
        $ProfilesTable.$converterlengthUnit.toJson(lengthUnit),
      ),
      'distanceUnit': serializer.toJson<String>(
        $ProfilesTable.$converterdistanceUnit.toJson(distanceUnit),
      ),
      'bmiCutoffs': serializer.toJson<String>(
        $ProfilesTable.$converterbmiCutoffs.toJson(bmiCutoffs),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileRow copyWith({
    String? id,
    Value<Sex?> sex = const Value.absent(),
    Value<int?> birthYear = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    ActivityLevel? activityLevel,
    WeightUnit? weightUnit,
    LengthUnit? lengthUnit,
    DistanceUnit? distanceUnit,
    BmiCutoffs? bmiCutoffs,
    DateTime? updatedAt,
  }) => ProfileRow(
    id: id ?? this.id,
    sex: sex.present ? sex.value : this.sex,
    birthYear: birthYear.present ? birthYear.value : this.birthYear,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    activityLevel: activityLevel ?? this.activityLevel,
    weightUnit: weightUnit ?? this.weightUnit,
    lengthUnit: lengthUnit ?? this.lengthUnit,
    distanceUnit: distanceUnit ?? this.distanceUnit,
    bmiCutoffs: bmiCutoffs ?? this.bmiCutoffs,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      lengthUnit: data.lengthUnit.present
          ? data.lengthUnit.value
          : this.lengthUnit,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      bmiCutoffs: data.bmiCutoffs.present
          ? data.bmiCutoffs.value
          : this.bmiCutoffs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('bmiCutoffs: $bmiCutoffs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sex,
    birthYear,
    heightCm,
    activityLevel,
    weightUnit,
    lengthUnit,
    distanceUnit,
    bmiCutoffs,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.sex == this.sex &&
          other.birthYear == this.birthYear &&
          other.heightCm == this.heightCm &&
          other.activityLevel == this.activityLevel &&
          other.weightUnit == this.weightUnit &&
          other.lengthUnit == this.lengthUnit &&
          other.distanceUnit == this.distanceUnit &&
          other.bmiCutoffs == this.bmiCutoffs &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> id;
  final Value<Sex?> sex;
  final Value<int?> birthYear;
  final Value<double?> heightCm;
  final Value<ActivityLevel> activityLevel;
  final Value<WeightUnit> weightUnit;
  final Value<LengthUnit> lengthUnit;
  final Value<DistanceUnit> distanceUnit;
  final Value<BmiCutoffs> bmiCutoffs;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.bmiCutoffs = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.bmiCutoffs = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<ProfileRow> custom({
    Expression<String>? id,
    Expression<String>? sex,
    Expression<int>? birthYear,
    Expression<double>? heightCm,
    Expression<String>? activityLevel,
    Expression<String>? weightUnit,
    Expression<String>? lengthUnit,
    Expression<String>? distanceUnit,
    Expression<String>? bmiCutoffs,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sex != null) 'sex': sex,
      if (birthYear != null) 'birth_year': birthYear,
      if (heightCm != null) 'height_cm': heightCm,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (lengthUnit != null) 'length_unit': lengthUnit,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (bmiCutoffs != null) 'bmi_cutoffs': bmiCutoffs,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<Sex?>? sex,
    Value<int?>? birthYear,
    Value<double?>? heightCm,
    Value<ActivityLevel>? activityLevel,
    Value<WeightUnit>? weightUnit,
    Value<LengthUnit>? lengthUnit,
    Value<DistanceUnit>? distanceUnit,
    Value<BmiCutoffs>? bmiCutoffs,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      weightUnit: weightUnit ?? this.weightUnit,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      bmiCutoffs: bmiCutoffs ?? this.bmiCutoffs,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(
        $ProfilesTable.$convertersexn.toSql(sex.value),
      );
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(
        $ProfilesTable.$converteractivityLevel.toSql(activityLevel.value),
      );
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
        $ProfilesTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    if (lengthUnit.present) {
      map['length_unit'] = Variable<String>(
        $ProfilesTable.$converterlengthUnit.toSql(lengthUnit.value),
      );
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(
        $ProfilesTable.$converterdistanceUnit.toSql(distanceUnit.value),
      );
    }
    if (bmiCutoffs.present) {
      map['bmi_cutoffs'] = Variable<String>(
        $ProfilesTable.$converterbmiCutoffs.toSql(bmiCutoffs.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('bmiCutoffs: $bmiCutoffs, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomExercisesTable extends CustomExercises
    with TableInfo<$CustomExercisesTable, CustomExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> aliases =
      GeneratedColumn<String>(
        'aliases',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CustomExercisesTable.$converteraliases);
  static const VerificationMeta _sanskritNameMeta = const VerificationMeta(
    'sanskritName',
  );
  @override
  late final GeneratedColumn<String> sanskritName = GeneratedColumn<String>(
    'sanskrit_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TrackingType, String>
  trackingType = GeneratedColumn<String>(
    'tracking_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TrackingType>($CustomExercisesTable.$convertertrackingType);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($CustomExercisesTable.$converterprimaryMuscles);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  secondaryMuscles =
      GeneratedColumn<String>(
        'secondary_muscles',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>(
        $CustomExercisesTable.$convertersecondaryMuscles,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> equipment =
      GeneratedColumn<String>(
        'equipment',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CustomExercisesTable.$converterequipment);
  @override
  late final GeneratedColumnWithTypeConverter<Difficulty?, String> difficulty =
      GeneratedColumn<String>(
        'difficulty',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Difficulty?>($CustomExercisesTable.$converterdifficultyn);
  static const VerificationMeta _unilateralMeta = const VerificationMeta(
    'unilateral',
  );
  @override
  late final GeneratedColumn<bool> unilateral = GeneratedColumn<bool>(
    'unilateral',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("unilateral" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mechanicMeta = const VerificationMeta(
    'mechanic',
  );
  @override
  late final GeneratedColumn<String> mechanic = GeneratedColumn<String>(
    'mechanic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forceMeta = const VerificationMeta('force');
  @override
  late final GeneratedColumn<String> force = GeneratedColumn<String>(
    'force',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> steps =
      GeneratedColumn<String>(
        'steps',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CustomExercisesTable.$convertersteps);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tips =
      GeneratedColumn<String>(
        'tips',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CustomExercisesTable.$convertertips);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  commonMistakes = GeneratedColumn<String>(
    'common_mistakes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($CustomExercisesTable.$convertercommonMistakes);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  safetyNotes = GeneratedColumn<String>(
    'safety_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($CustomExercisesTable.$convertersafetyNotes);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  contraindications =
      GeneratedColumn<String>(
        'contraindications',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>(
        $CustomExercisesTable.$convertercontraindications,
      );
  static const VerificationMeta _metValueMeta = const VerificationMeta(
    'metValue',
  );
  @override
  late final GeneratedColumn<double> metValue = GeneratedColumn<double>(
    'met_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultRestSecMeta = const VerificationMeta(
    'defaultRestSec',
  );
  @override
  late final GeneratedColumn<int> defaultRestSec = GeneratedColumn<int>(
    'default_rest_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultHoldSecMeta = const VerificationMeta(
    'defaultHoldSec',
  );
  @override
  late final GeneratedColumn<int> defaultHoldSec = GeneratedColumn<int>(
    'default_hold_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variationOfMeta = const VerificationMeta(
    'variationOf',
  );
  @override
  late final GeneratedColumn<String> variationOf = GeneratedColumn<String>(
    'variation_of',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CustomExercisesTable.$convertertags);
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    aliases,
    sanskritName,
    category,
    subcategory,
    trackingType,
    primaryMuscles,
    secondaryMuscles,
    equipment,
    difficulty,
    unilateral,
    mechanic,
    force,
    steps,
    tips,
    commonMistakes,
    safetyNotes,
    contraindications,
    metValue,
    defaultRestSec,
    defaultHoldSec,
    variationOf,
    tags,
    archived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sanskrit_name')) {
      context.handle(
        _sanskritNameMeta,
        sanskritName.isAcceptableOrUnknown(
          data['sanskrit_name']!,
          _sanskritNameMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('unilateral')) {
      context.handle(
        _unilateralMeta,
        unilateral.isAcceptableOrUnknown(data['unilateral']!, _unilateralMeta),
      );
    }
    if (data.containsKey('mechanic')) {
      context.handle(
        _mechanicMeta,
        mechanic.isAcceptableOrUnknown(data['mechanic']!, _mechanicMeta),
      );
    }
    if (data.containsKey('force')) {
      context.handle(
        _forceMeta,
        force.isAcceptableOrUnknown(data['force']!, _forceMeta),
      );
    }
    if (data.containsKey('met_value')) {
      context.handle(
        _metValueMeta,
        metValue.isAcceptableOrUnknown(data['met_value']!, _metValueMeta),
      );
    }
    if (data.containsKey('default_rest_sec')) {
      context.handle(
        _defaultRestSecMeta,
        defaultRestSec.isAcceptableOrUnknown(
          data['default_rest_sec']!,
          _defaultRestSecMeta,
        ),
      );
    }
    if (data.containsKey('default_hold_sec')) {
      context.handle(
        _defaultHoldSecMeta,
        defaultHoldSec.isAcceptableOrUnknown(
          data['default_hold_sec']!,
          _defaultHoldSecMeta,
        ),
      );
    }
    if (data.containsKey('variation_of')) {
      context.handle(
        _variationOfMeta,
        variationOf.isAcceptableOrUnknown(
          data['variation_of']!,
          _variationOfMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      aliases: $CustomExercisesTable.$converteraliases.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}aliases'],
        )!,
      ),
      sanskritName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sanskrit_name'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      trackingType: $CustomExercisesTable.$convertertrackingType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tracking_type'],
        )!,
      ),
      primaryMuscles: $CustomExercisesTable.$converterprimaryMuscles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}primary_muscles'],
        )!,
      ),
      secondaryMuscles: $CustomExercisesTable.$convertersecondaryMuscles
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}secondary_muscles'],
            )!,
          ),
      equipment: $CustomExercisesTable.$converterequipment.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}equipment'],
        )!,
      ),
      difficulty: $CustomExercisesTable.$converterdifficultyn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}difficulty'],
        ),
      ),
      unilateral: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}unilateral'],
      )!,
      mechanic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mechanic'],
      ),
      force: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}force'],
      ),
      steps: $CustomExercisesTable.$convertersteps.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}steps'],
        )!,
      ),
      tips: $CustomExercisesTable.$convertertips.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tips'],
        )!,
      ),
      commonMistakes: $CustomExercisesTable.$convertercommonMistakes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}common_mistakes'],
        )!,
      ),
      safetyNotes: $CustomExercisesTable.$convertersafetyNotes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}safety_notes'],
        )!,
      ),
      contraindications: $CustomExercisesTable.$convertercontraindications
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}contraindications'],
            )!,
          ),
      metValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}met_value'],
      ),
      defaultRestSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_rest_sec'],
      ),
      defaultHoldSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_hold_sec'],
      ),
      variationOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variation_of'],
      ),
      tags: $CustomExercisesTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomExercisesTable createAlias(String alias) {
    return $CustomExercisesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converteraliases =
      const StringListConverter();
  static JsonTypeConverter2<TrackingType, String, String>
  $convertertrackingType = const EnumNameConverter<TrackingType>(
    TrackingType.values,
  );
  static TypeConverter<List<String>, String> $converterprimaryMuscles =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertersecondaryMuscles =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterequipment =
      const StringListConverter();
  static JsonTypeConverter2<Difficulty, String, String> $converterdifficulty =
      const EnumNameConverter<Difficulty>(Difficulty.values);
  static JsonTypeConverter2<Difficulty?, String?, String?>
  $converterdifficultyn = JsonTypeConverter2.asNullable($converterdifficulty);
  static TypeConverter<List<String>, String> $convertersteps =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertertips =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertercommonMistakes =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertersafetyNotes =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertercontraindications =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class CustomExerciseRow extends DataClass
    implements Insertable<CustomExerciseRow> {
  final String id;
  final String name;
  final List<String> aliases;
  final String? sanskritName;
  final String category;
  final String? subcategory;
  final TrackingType trackingType;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> equipment;
  final Difficulty? difficulty;
  final bool unilateral;
  final String? mechanic;
  final String? force;
  final List<String> steps;
  final List<String> tips;
  final List<String> commonMistakes;
  final List<String> safetyNotes;
  final List<String> contraindications;
  final double? metValue;
  final int? defaultRestSec;
  final int? defaultHoldSec;
  final String? variationOf;
  final List<String> tags;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CustomExerciseRow({
    required this.id,
    required this.name,
    required this.aliases,
    this.sanskritName,
    required this.category,
    this.subcategory,
    required this.trackingType,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    this.difficulty,
    required this.unilateral,
    this.mechanic,
    this.force,
    required this.steps,
    required this.tips,
    required this.commonMistakes,
    required this.safetyNotes,
    required this.contraindications,
    this.metValue,
    this.defaultRestSec,
    this.defaultHoldSec,
    this.variationOf,
    required this.tags,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['aliases'] = Variable<String>(
        $CustomExercisesTable.$converteraliases.toSql(aliases),
      );
    }
    if (!nullToAbsent || sanskritName != null) {
      map['sanskrit_name'] = Variable<String>(sanskritName);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    {
      map['tracking_type'] = Variable<String>(
        $CustomExercisesTable.$convertertrackingType.toSql(trackingType),
      );
    }
    {
      map['primary_muscles'] = Variable<String>(
        $CustomExercisesTable.$converterprimaryMuscles.toSql(primaryMuscles),
      );
    }
    {
      map['secondary_muscles'] = Variable<String>(
        $CustomExercisesTable.$convertersecondaryMuscles.toSql(
          secondaryMuscles,
        ),
      );
    }
    {
      map['equipment'] = Variable<String>(
        $CustomExercisesTable.$converterequipment.toSql(equipment),
      );
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(
        $CustomExercisesTable.$converterdifficultyn.toSql(difficulty),
      );
    }
    map['unilateral'] = Variable<bool>(unilateral);
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] = Variable<String>(mechanic);
    }
    if (!nullToAbsent || force != null) {
      map['force'] = Variable<String>(force);
    }
    {
      map['steps'] = Variable<String>(
        $CustomExercisesTable.$convertersteps.toSql(steps),
      );
    }
    {
      map['tips'] = Variable<String>(
        $CustomExercisesTable.$convertertips.toSql(tips),
      );
    }
    {
      map['common_mistakes'] = Variable<String>(
        $CustomExercisesTable.$convertercommonMistakes.toSql(commonMistakes),
      );
    }
    {
      map['safety_notes'] = Variable<String>(
        $CustomExercisesTable.$convertersafetyNotes.toSql(safetyNotes),
      );
    }
    {
      map['contraindications'] = Variable<String>(
        $CustomExercisesTable.$convertercontraindications.toSql(
          contraindications,
        ),
      );
    }
    if (!nullToAbsent || metValue != null) {
      map['met_value'] = Variable<double>(metValue);
    }
    if (!nullToAbsent || defaultRestSec != null) {
      map['default_rest_sec'] = Variable<int>(defaultRestSec);
    }
    if (!nullToAbsent || defaultHoldSec != null) {
      map['default_hold_sec'] = Variable<int>(defaultHoldSec);
    }
    if (!nullToAbsent || variationOf != null) {
      map['variation_of'] = Variable<String>(variationOf);
    }
    {
      map['tags'] = Variable<String>(
        $CustomExercisesTable.$convertertags.toSql(tags),
      );
    }
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomExercisesCompanion toCompanion(bool nullToAbsent) {
    return CustomExercisesCompanion(
      id: Value(id),
      name: Value(name),
      aliases: Value(aliases),
      sanskritName: sanskritName == null && nullToAbsent
          ? const Value.absent()
          : Value(sanskritName),
      category: Value(category),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      trackingType: Value(trackingType),
      primaryMuscles: Value(primaryMuscles),
      secondaryMuscles: Value(secondaryMuscles),
      equipment: Value(equipment),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      unilateral: Value(unilateral),
      mechanic: mechanic == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanic),
      force: force == null && nullToAbsent
          ? const Value.absent()
          : Value(force),
      steps: Value(steps),
      tips: Value(tips),
      commonMistakes: Value(commonMistakes),
      safetyNotes: Value(safetyNotes),
      contraindications: Value(contraindications),
      metValue: metValue == null && nullToAbsent
          ? const Value.absent()
          : Value(metValue),
      defaultRestSec: defaultRestSec == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultRestSec),
      defaultHoldSec: defaultHoldSec == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultHoldSec),
      variationOf: variationOf == null && nullToAbsent
          ? const Value.absent()
          : Value(variationOf),
      tags: Value(tags),
      archived: Value(archived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CustomExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      aliases: serializer.fromJson<List<String>>(json['aliases']),
      sanskritName: serializer.fromJson<String?>(json['sanskritName']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      trackingType: $CustomExercisesTable.$convertertrackingType.fromJson(
        serializer.fromJson<String>(json['trackingType']),
      ),
      primaryMuscles: serializer.fromJson<List<String>>(json['primaryMuscles']),
      secondaryMuscles: serializer.fromJson<List<String>>(
        json['secondaryMuscles'],
      ),
      equipment: serializer.fromJson<List<String>>(json['equipment']),
      difficulty: $CustomExercisesTable.$converterdifficultyn.fromJson(
        serializer.fromJson<String?>(json['difficulty']),
      ),
      unilateral: serializer.fromJson<bool>(json['unilateral']),
      mechanic: serializer.fromJson<String?>(json['mechanic']),
      force: serializer.fromJson<String?>(json['force']),
      steps: serializer.fromJson<List<String>>(json['steps']),
      tips: serializer.fromJson<List<String>>(json['tips']),
      commonMistakes: serializer.fromJson<List<String>>(json['commonMistakes']),
      safetyNotes: serializer.fromJson<List<String>>(json['safetyNotes']),
      contraindications: serializer.fromJson<List<String>>(
        json['contraindications'],
      ),
      metValue: serializer.fromJson<double?>(json['metValue']),
      defaultRestSec: serializer.fromJson<int?>(json['defaultRestSec']),
      defaultHoldSec: serializer.fromJson<int?>(json['defaultHoldSec']),
      variationOf: serializer.fromJson<String?>(json['variationOf']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'aliases': serializer.toJson<List<String>>(aliases),
      'sanskritName': serializer.toJson<String?>(sanskritName),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'trackingType': serializer.toJson<String>(
        $CustomExercisesTable.$convertertrackingType.toJson(trackingType),
      ),
      'primaryMuscles': serializer.toJson<List<String>>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<List<String>>(secondaryMuscles),
      'equipment': serializer.toJson<List<String>>(equipment),
      'difficulty': serializer.toJson<String?>(
        $CustomExercisesTable.$converterdifficultyn.toJson(difficulty),
      ),
      'unilateral': serializer.toJson<bool>(unilateral),
      'mechanic': serializer.toJson<String?>(mechanic),
      'force': serializer.toJson<String?>(force),
      'steps': serializer.toJson<List<String>>(steps),
      'tips': serializer.toJson<List<String>>(tips),
      'commonMistakes': serializer.toJson<List<String>>(commonMistakes),
      'safetyNotes': serializer.toJson<List<String>>(safetyNotes),
      'contraindications': serializer.toJson<List<String>>(contraindications),
      'metValue': serializer.toJson<double?>(metValue),
      'defaultRestSec': serializer.toJson<int?>(defaultRestSec),
      'defaultHoldSec': serializer.toJson<int?>(defaultHoldSec),
      'variationOf': serializer.toJson<String?>(variationOf),
      'tags': serializer.toJson<List<String>>(tags),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CustomExerciseRow copyWith({
    String? id,
    String? name,
    List<String>? aliases,
    Value<String?> sanskritName = const Value.absent(),
    String? category,
    Value<String?> subcategory = const Value.absent(),
    TrackingType? trackingType,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    List<String>? equipment,
    Value<Difficulty?> difficulty = const Value.absent(),
    bool? unilateral,
    Value<String?> mechanic = const Value.absent(),
    Value<String?> force = const Value.absent(),
    List<String>? steps,
    List<String>? tips,
    List<String>? commonMistakes,
    List<String>? safetyNotes,
    List<String>? contraindications,
    Value<double?> metValue = const Value.absent(),
    Value<int?> defaultRestSec = const Value.absent(),
    Value<int?> defaultHoldSec = const Value.absent(),
    Value<String?> variationOf = const Value.absent(),
    List<String>? tags,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CustomExerciseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    aliases: aliases ?? this.aliases,
    sanskritName: sanskritName.present ? sanskritName.value : this.sanskritName,
    category: category ?? this.category,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    trackingType: trackingType ?? this.trackingType,
    primaryMuscles: primaryMuscles ?? this.primaryMuscles,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    equipment: equipment ?? this.equipment,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    unilateral: unilateral ?? this.unilateral,
    mechanic: mechanic.present ? mechanic.value : this.mechanic,
    force: force.present ? force.value : this.force,
    steps: steps ?? this.steps,
    tips: tips ?? this.tips,
    commonMistakes: commonMistakes ?? this.commonMistakes,
    safetyNotes: safetyNotes ?? this.safetyNotes,
    contraindications: contraindications ?? this.contraindications,
    metValue: metValue.present ? metValue.value : this.metValue,
    defaultRestSec: defaultRestSec.present
        ? defaultRestSec.value
        : this.defaultRestSec,
    defaultHoldSec: defaultHoldSec.present
        ? defaultHoldSec.value
        : this.defaultHoldSec,
    variationOf: variationOf.present ? variationOf.value : this.variationOf,
    tags: tags ?? this.tags,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CustomExerciseRow copyWithCompanion(CustomExercisesCompanion data) {
    return CustomExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      sanskritName: data.sanskritName.present
          ? data.sanskritName.value
          : this.sanskritName,
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      trackingType: data.trackingType.present
          ? data.trackingType.value
          : this.trackingType,
      primaryMuscles: data.primaryMuscles.present
          ? data.primaryMuscles.value
          : this.primaryMuscles,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      unilateral: data.unilateral.present
          ? data.unilateral.value
          : this.unilateral,
      mechanic: data.mechanic.present ? data.mechanic.value : this.mechanic,
      force: data.force.present ? data.force.value : this.force,
      steps: data.steps.present ? data.steps.value : this.steps,
      tips: data.tips.present ? data.tips.value : this.tips,
      commonMistakes: data.commonMistakes.present
          ? data.commonMistakes.value
          : this.commonMistakes,
      safetyNotes: data.safetyNotes.present
          ? data.safetyNotes.value
          : this.safetyNotes,
      contraindications: data.contraindications.present
          ? data.contraindications.value
          : this.contraindications,
      metValue: data.metValue.present ? data.metValue.value : this.metValue,
      defaultRestSec: data.defaultRestSec.present
          ? data.defaultRestSec.value
          : this.defaultRestSec,
      defaultHoldSec: data.defaultHoldSec.present
          ? data.defaultHoldSec.value
          : this.defaultHoldSec,
      variationOf: data.variationOf.present
          ? data.variationOf.value
          : this.variationOf,
      tags: data.tags.present ? data.tags.value : this.tags,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomExerciseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('sanskritName: $sanskritName, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('trackingType: $trackingType, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('equipment: $equipment, ')
          ..write('difficulty: $difficulty, ')
          ..write('unilateral: $unilateral, ')
          ..write('mechanic: $mechanic, ')
          ..write('force: $force, ')
          ..write('steps: $steps, ')
          ..write('tips: $tips, ')
          ..write('commonMistakes: $commonMistakes, ')
          ..write('safetyNotes: $safetyNotes, ')
          ..write('contraindications: $contraindications, ')
          ..write('metValue: $metValue, ')
          ..write('defaultRestSec: $defaultRestSec, ')
          ..write('defaultHoldSec: $defaultHoldSec, ')
          ..write('variationOf: $variationOf, ')
          ..write('tags: $tags, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    aliases,
    sanskritName,
    category,
    subcategory,
    trackingType,
    primaryMuscles,
    secondaryMuscles,
    equipment,
    difficulty,
    unilateral,
    mechanic,
    force,
    steps,
    tips,
    commonMistakes,
    safetyNotes,
    contraindications,
    metValue,
    defaultRestSec,
    defaultHoldSec,
    variationOf,
    tags,
    archived,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExerciseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.aliases == this.aliases &&
          other.sanskritName == this.sanskritName &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.trackingType == this.trackingType &&
          other.primaryMuscles == this.primaryMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.equipment == this.equipment &&
          other.difficulty == this.difficulty &&
          other.unilateral == this.unilateral &&
          other.mechanic == this.mechanic &&
          other.force == this.force &&
          other.steps == this.steps &&
          other.tips == this.tips &&
          other.commonMistakes == this.commonMistakes &&
          other.safetyNotes == this.safetyNotes &&
          other.contraindications == this.contraindications &&
          other.metValue == this.metValue &&
          other.defaultRestSec == this.defaultRestSec &&
          other.defaultHoldSec == this.defaultHoldSec &&
          other.variationOf == this.variationOf &&
          other.tags == this.tags &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExerciseRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<List<String>> aliases;
  final Value<String?> sanskritName;
  final Value<String> category;
  final Value<String?> subcategory;
  final Value<TrackingType> trackingType;
  final Value<List<String>> primaryMuscles;
  final Value<List<String>> secondaryMuscles;
  final Value<List<String>> equipment;
  final Value<Difficulty?> difficulty;
  final Value<bool> unilateral;
  final Value<String?> mechanic;
  final Value<String?> force;
  final Value<List<String>> steps;
  final Value<List<String>> tips;
  final Value<List<String>> commonMistakes;
  final Value<List<String>> safetyNotes;
  final Value<List<String>> contraindications;
  final Value<double?> metValue;
  final Value<int?> defaultRestSec;
  final Value<int?> defaultHoldSec;
  final Value<String?> variationOf;
  final Value<List<String>> tags;
  final Value<bool> archived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.aliases = const Value.absent(),
    this.sanskritName = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.trackingType = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.equipment = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.unilateral = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.force = const Value.absent(),
    this.steps = const Value.absent(),
    this.tips = const Value.absent(),
    this.commonMistakes = const Value.absent(),
    this.safetyNotes = const Value.absent(),
    this.contraindications = const Value.absent(),
    this.metValue = const Value.absent(),
    this.defaultRestSec = const Value.absent(),
    this.defaultHoldSec = const Value.absent(),
    this.variationOf = const Value.absent(),
    this.tags = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    required String id,
    required String name,
    this.aliases = const Value.absent(),
    this.sanskritName = const Value.absent(),
    required String category,
    this.subcategory = const Value.absent(),
    required TrackingType trackingType,
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.equipment = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.unilateral = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.force = const Value.absent(),
    this.steps = const Value.absent(),
    this.tips = const Value.absent(),
    this.commonMistakes = const Value.absent(),
    this.safetyNotes = const Value.absent(),
    this.contraindications = const Value.absent(),
    this.metValue = const Value.absent(),
    this.defaultRestSec = const Value.absent(),
    this.defaultHoldSec = const Value.absent(),
    this.variationOf = const Value.absent(),
    this.tags = const Value.absent(),
    this.archived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       trackingType = Value(trackingType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? aliases,
    Expression<String>? sanskritName,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? trackingType,
    Expression<String>? primaryMuscles,
    Expression<String>? secondaryMuscles,
    Expression<String>? equipment,
    Expression<String>? difficulty,
    Expression<bool>? unilateral,
    Expression<String>? mechanic,
    Expression<String>? force,
    Expression<String>? steps,
    Expression<String>? tips,
    Expression<String>? commonMistakes,
    Expression<String>? safetyNotes,
    Expression<String>? contraindications,
    Expression<double>? metValue,
    Expression<int>? defaultRestSec,
    Expression<int>? defaultHoldSec,
    Expression<String>? variationOf,
    Expression<String>? tags,
    Expression<bool>? archived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (aliases != null) 'aliases': aliases,
      if (sanskritName != null) 'sanskrit_name': sanskritName,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (trackingType != null) 'tracking_type': trackingType,
      if (primaryMuscles != null) 'primary_muscles': primaryMuscles,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (equipment != null) 'equipment': equipment,
      if (difficulty != null) 'difficulty': difficulty,
      if (unilateral != null) 'unilateral': unilateral,
      if (mechanic != null) 'mechanic': mechanic,
      if (force != null) 'force': force,
      if (steps != null) 'steps': steps,
      if (tips != null) 'tips': tips,
      if (commonMistakes != null) 'common_mistakes': commonMistakes,
      if (safetyNotes != null) 'safety_notes': safetyNotes,
      if (contraindications != null) 'contraindications': contraindications,
      if (metValue != null) 'met_value': metValue,
      if (defaultRestSec != null) 'default_rest_sec': defaultRestSec,
      if (defaultHoldSec != null) 'default_hold_sec': defaultHoldSec,
      if (variationOf != null) 'variation_of': variationOf,
      if (tags != null) 'tags': tags,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<List<String>>? aliases,
    Value<String?>? sanskritName,
    Value<String>? category,
    Value<String?>? subcategory,
    Value<TrackingType>? trackingType,
    Value<List<String>>? primaryMuscles,
    Value<List<String>>? secondaryMuscles,
    Value<List<String>>? equipment,
    Value<Difficulty?>? difficulty,
    Value<bool>? unilateral,
    Value<String?>? mechanic,
    Value<String?>? force,
    Value<List<String>>? steps,
    Value<List<String>>? tips,
    Value<List<String>>? commonMistakes,
    Value<List<String>>? safetyNotes,
    Value<List<String>>? contraindications,
    Value<double?>? metValue,
    Value<int?>? defaultRestSec,
    Value<int?>? defaultHoldSec,
    Value<String?>? variationOf,
    Value<List<String>>? tags,
    Value<bool>? archived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      sanskritName: sanskritName ?? this.sanskritName,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      trackingType: trackingType ?? this.trackingType,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      unilateral: unilateral ?? this.unilateral,
      mechanic: mechanic ?? this.mechanic,
      force: force ?? this.force,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      safetyNotes: safetyNotes ?? this.safetyNotes,
      contraindications: contraindications ?? this.contraindications,
      metValue: metValue ?? this.metValue,
      defaultRestSec: defaultRestSec ?? this.defaultRestSec,
      defaultHoldSec: defaultHoldSec ?? this.defaultHoldSec,
      variationOf: variationOf ?? this.variationOf,
      tags: tags ?? this.tags,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(
        $CustomExercisesTable.$converteraliases.toSql(aliases.value),
      );
    }
    if (sanskritName.present) {
      map['sanskrit_name'] = Variable<String>(sanskritName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (trackingType.present) {
      map['tracking_type'] = Variable<String>(
        $CustomExercisesTable.$convertertrackingType.toSql(trackingType.value),
      );
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(
        $CustomExercisesTable.$converterprimaryMuscles.toSql(
          primaryMuscles.value,
        ),
      );
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(
        $CustomExercisesTable.$convertersecondaryMuscles.toSql(
          secondaryMuscles.value,
        ),
      );
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
        $CustomExercisesTable.$converterequipment.toSql(equipment.value),
      );
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(
        $CustomExercisesTable.$converterdifficultyn.toSql(difficulty.value),
      );
    }
    if (unilateral.present) {
      map['unilateral'] = Variable<bool>(unilateral.value);
    }
    if (mechanic.present) {
      map['mechanic'] = Variable<String>(mechanic.value);
    }
    if (force.present) {
      map['force'] = Variable<String>(force.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(
        $CustomExercisesTable.$convertersteps.toSql(steps.value),
      );
    }
    if (tips.present) {
      map['tips'] = Variable<String>(
        $CustomExercisesTable.$convertertips.toSql(tips.value),
      );
    }
    if (commonMistakes.present) {
      map['common_mistakes'] = Variable<String>(
        $CustomExercisesTable.$convertercommonMistakes.toSql(
          commonMistakes.value,
        ),
      );
    }
    if (safetyNotes.present) {
      map['safety_notes'] = Variable<String>(
        $CustomExercisesTable.$convertersafetyNotes.toSql(safetyNotes.value),
      );
    }
    if (contraindications.present) {
      map['contraindications'] = Variable<String>(
        $CustomExercisesTable.$convertercontraindications.toSql(
          contraindications.value,
        ),
      );
    }
    if (metValue.present) {
      map['met_value'] = Variable<double>(metValue.value);
    }
    if (defaultRestSec.present) {
      map['default_rest_sec'] = Variable<int>(defaultRestSec.value);
    }
    if (defaultHoldSec.present) {
      map['default_hold_sec'] = Variable<int>(defaultHoldSec.value);
    }
    if (variationOf.present) {
      map['variation_of'] = Variable<String>(variationOf.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $CustomExercisesTable.$convertertags.toSql(tags.value),
      );
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('sanskritName: $sanskritName, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('trackingType: $trackingType, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('equipment: $equipment, ')
          ..write('difficulty: $difficulty, ')
          ..write('unilateral: $unilateral, ')
          ..write('mechanic: $mechanic, ')
          ..write('force: $force, ')
          ..write('steps: $steps, ')
          ..write('tips: $tips, ')
          ..write('commonMistakes: $commonMistakes, ')
          ..write('safetyNotes: $safetyNotes, ')
          ..write('contraindications: $contraindications, ')
          ..write('metValue: $metValue, ')
          ..write('defaultRestSec: $defaultRestSec, ')
          ..write('defaultHoldSec: $defaultHoldSec, ')
          ..write('variationOf: $variationOf, ')
          ..write('tags: $tags, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseTombstonesTable extends ExerciseTombstones
    with TableInfo<$ExerciseTombstonesTable, ExerciseTombstoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TrackingType, String>
  trackingType =
      GeneratedColumn<String>(
        'tracking_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TrackingType>(
        $ExerciseTombstonesTable.$convertertrackingType,
      );
  static const VerificationMeta _removedInLibraryVersionMeta =
      const VerificationMeta('removedInLibraryVersion');
  @override
  late final GeneratedColumn<String> removedInLibraryVersion =
      GeneratedColumn<String>(
        'removed_in_library_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    name,
    trackingType,
    removedInLibraryVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseTombstoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('removed_in_library_version')) {
      context.handle(
        _removedInLibraryVersionMeta,
        removedInLibraryVersion.isAcceptableOrUnknown(
          data['removed_in_library_version']!,
          _removedInLibraryVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_removedInLibraryVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseTombstoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseTombstoneRow(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      trackingType: $ExerciseTombstonesTable.$convertertrackingType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tracking_type'],
        )!,
      ),
      removedInLibraryVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}removed_in_library_version'],
      )!,
    );
  }

  @override
  $ExerciseTombstonesTable createAlias(String alias) {
    return $ExerciseTombstonesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TrackingType, String, String>
  $convertertrackingType = const EnumNameConverter<TrackingType>(
    TrackingType.values,
  );
}

class ExerciseTombstoneRow extends DataClass
    implements Insertable<ExerciseTombstoneRow> {
  final String exerciseId;
  final String name;
  final TrackingType trackingType;
  final String removedInLibraryVersion;
  const ExerciseTombstoneRow({
    required this.exerciseId,
    required this.name,
    required this.trackingType,
    required this.removedInLibraryVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['name'] = Variable<String>(name);
    {
      map['tracking_type'] = Variable<String>(
        $ExerciseTombstonesTable.$convertertrackingType.toSql(trackingType),
      );
    }
    map['removed_in_library_version'] = Variable<String>(
      removedInLibraryVersion,
    );
    return map;
  }

  ExerciseTombstonesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseTombstonesCompanion(
      exerciseId: Value(exerciseId),
      name: Value(name),
      trackingType: Value(trackingType),
      removedInLibraryVersion: Value(removedInLibraryVersion),
    );
  }

  factory ExerciseTombstoneRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseTombstoneRow(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      name: serializer.fromJson<String>(json['name']),
      trackingType: $ExerciseTombstonesTable.$convertertrackingType.fromJson(
        serializer.fromJson<String>(json['trackingType']),
      ),
      removedInLibraryVersion: serializer.fromJson<String>(
        json['removedInLibraryVersion'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'name': serializer.toJson<String>(name),
      'trackingType': serializer.toJson<String>(
        $ExerciseTombstonesTable.$convertertrackingType.toJson(trackingType),
      ),
      'removedInLibraryVersion': serializer.toJson<String>(
        removedInLibraryVersion,
      ),
    };
  }

  ExerciseTombstoneRow copyWith({
    String? exerciseId,
    String? name,
    TrackingType? trackingType,
    String? removedInLibraryVersion,
  }) => ExerciseTombstoneRow(
    exerciseId: exerciseId ?? this.exerciseId,
    name: name ?? this.name,
    trackingType: trackingType ?? this.trackingType,
    removedInLibraryVersion:
        removedInLibraryVersion ?? this.removedInLibraryVersion,
  );
  ExerciseTombstoneRow copyWithCompanion(ExerciseTombstonesCompanion data) {
    return ExerciseTombstoneRow(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      name: data.name.present ? data.name.value : this.name,
      trackingType: data.trackingType.present
          ? data.trackingType.value
          : this.trackingType,
      removedInLibraryVersion: data.removedInLibraryVersion.present
          ? data.removedInLibraryVersion.value
          : this.removedInLibraryVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTombstoneRow(')
          ..write('exerciseId: $exerciseId, ')
          ..write('name: $name, ')
          ..write('trackingType: $trackingType, ')
          ..write('removedInLibraryVersion: $removedInLibraryVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(exerciseId, name, trackingType, removedInLibraryVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseTombstoneRow &&
          other.exerciseId == this.exerciseId &&
          other.name == this.name &&
          other.trackingType == this.trackingType &&
          other.removedInLibraryVersion == this.removedInLibraryVersion);
}

class ExerciseTombstonesCompanion
    extends UpdateCompanion<ExerciseTombstoneRow> {
  final Value<String> exerciseId;
  final Value<String> name;
  final Value<TrackingType> trackingType;
  final Value<String> removedInLibraryVersion;
  final Value<int> rowid;
  const ExerciseTombstonesCompanion({
    this.exerciseId = const Value.absent(),
    this.name = const Value.absent(),
    this.trackingType = const Value.absent(),
    this.removedInLibraryVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseTombstonesCompanion.insert({
    required String exerciseId,
    required String name,
    required TrackingType trackingType,
    required String removedInLibraryVersion,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       name = Value(name),
       trackingType = Value(trackingType),
       removedInLibraryVersion = Value(removedInLibraryVersion);
  static Insertable<ExerciseTombstoneRow> custom({
    Expression<String>? exerciseId,
    Expression<String>? name,
    Expression<String>? trackingType,
    Expression<String>? removedInLibraryVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (name != null) 'name': name,
      if (trackingType != null) 'tracking_type': trackingType,
      if (removedInLibraryVersion != null)
        'removed_in_library_version': removedInLibraryVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseTombstonesCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? name,
    Value<TrackingType>? trackingType,
    Value<String>? removedInLibraryVersion,
    Value<int>? rowid,
  }) {
    return ExerciseTombstonesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      trackingType: trackingType ?? this.trackingType,
      removedInLibraryVersion:
          removedInLibraryVersion ?? this.removedInLibraryVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (trackingType.present) {
      map['tracking_type'] = Variable<String>(
        $ExerciseTombstonesTable.$convertertrackingType.toSql(
          trackingType.value,
        ),
      );
    }
    if (removedInLibraryVersion.present) {
      map['removed_in_library_version'] = Variable<String>(
        removedInLibraryVersion.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTombstonesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('name: $name, ')
          ..write('trackingType: $trackingType, ')
          ..write('removedInLibraryVersion: $removedInLibraryVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    notes,
    position,
    archived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final String id;
  final String name;
  final String? notes;
  final int position;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RoutineRow({
    required this.id,
    required this.name,
    this.notes,
    required this.position,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['position'] = Variable<int>(position);
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      position: Value(position),
      archived: Value(archived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      position: serializer.fromJson<int>(json['position']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'position': serializer.toJson<int>(position),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RoutineRow copyWith({
    String? id,
    String? name,
    Value<String?> notes = const Value.absent(),
    int? position,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RoutineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    position: position ?? this.position,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      position: data.position.present ? data.position.value : this.position,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('position: $position, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, notes, position, archived, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.position == this.position &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> notes;
  final Value<int> position;
  final Value<bool> archived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.position = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    required String name,
    this.notes = const Value.absent(),
    this.position = const Value.absent(),
    this.archived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<int>? position,
    Expression<bool>? archived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (position != null) 'position': position,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? notes,
    Value<int>? position,
    Value<bool>? archived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      position: position ?? this.position,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('position: $position, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineItemsTable extends RoutineItems
    with TableInfo<$RoutineItemsTable, RoutineItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersetGroupMeta = const VerificationMeta(
    'supersetGroup',
  );
  @override
  late final GeneratedColumn<int> supersetGroup = GeneratedColumn<int>(
    'superset_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDurationSecMeta = const VerificationMeta(
    'targetDurationSec',
  );
  @override
  late final GeneratedColumn<int> targetDurationSec = GeneratedColumn<int>(
    'target_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDistanceMMeta = const VerificationMeta(
    'targetDistanceM',
  );
  @override
  late final GeneratedColumn<double> targetDistanceM = GeneratedColumn<double>(
    'target_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecMeta = const VerificationMeta(
    'restSec',
  );
  @override
  late final GeneratedColumn<int> restSec = GeneratedColumn<int>(
    'rest_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    exerciseId,
    position,
    supersetGroup,
    targetSets,
    targetReps,
    targetDurationSec,
    targetDistanceM,
    targetWeightKg,
    restSec,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('superset_group')) {
      context.handle(
        _supersetGroupMeta,
        supersetGroup.isAcceptableOrUnknown(
          data['superset_group']!,
          _supersetGroupMeta,
        ),
      );
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    }
    if (data.containsKey('target_duration_sec')) {
      context.handle(
        _targetDurationSecMeta,
        targetDurationSec.isAcceptableOrUnknown(
          data['target_duration_sec']!,
          _targetDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('target_distance_m')) {
      context.handle(
        _targetDistanceMMeta,
        targetDistanceM.isAcceptableOrUnknown(
          data['target_distance_m']!,
          _targetDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('rest_sec')) {
      context.handle(
        _restSecMeta,
        restSec.isAcceptableOrUnknown(data['rest_sec']!, _restSecMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      supersetGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superset_group'],
      ),
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      ),
      targetDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_duration_sec'],
      ),
      targetDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_distance_m'],
      ),
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      restSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_sec'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $RoutineItemsTable createAlias(String alias) {
    return $RoutineItemsTable(attachedDatabase, alias);
  }
}

class RoutineItemRow extends DataClass implements Insertable<RoutineItemRow> {
  final String id;
  final String routineId;
  final String exerciseId;
  final int position;
  final int? supersetGroup;
  final int targetSets;
  final int? targetReps;
  final int? targetDurationSec;
  final double? targetDistanceM;
  final double? targetWeightKg;
  final int? restSec;
  final String? notes;
  const RoutineItemRow({
    required this.id,
    required this.routineId,
    required this.exerciseId,
    required this.position,
    this.supersetGroup,
    required this.targetSets,
    this.targetReps,
    this.targetDurationSec,
    this.targetDistanceM,
    this.targetWeightKg,
    this.restSec,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || supersetGroup != null) {
      map['superset_group'] = Variable<int>(supersetGroup);
    }
    map['target_sets'] = Variable<int>(targetSets);
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    if (!nullToAbsent || targetDurationSec != null) {
      map['target_duration_sec'] = Variable<int>(targetDurationSec);
    }
    if (!nullToAbsent || targetDistanceM != null) {
      map['target_distance_m'] = Variable<double>(targetDistanceM);
    }
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    if (!nullToAbsent || restSec != null) {
      map['rest_sec'] = Variable<int>(restSec);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  RoutineItemsCompanion toCompanion(bool nullToAbsent) {
    return RoutineItemsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      supersetGroup: supersetGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroup),
      targetSets: Value(targetSets),
      targetReps: targetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetReps),
      targetDurationSec: targetDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDurationSec),
      targetDistanceM: targetDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDistanceM),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      restSec: restSec == null && nullToAbsent
          ? const Value.absent()
          : Value(restSec),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory RoutineItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineItemRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      supersetGroup: serializer.fromJson<int?>(json['supersetGroup']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      targetReps: serializer.fromJson<int?>(json['targetReps']),
      targetDurationSec: serializer.fromJson<int?>(json['targetDurationSec']),
      targetDistanceM: serializer.fromJson<double?>(json['targetDistanceM']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      restSec: serializer.fromJson<int?>(json['restSec']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'position': serializer.toJson<int>(position),
      'supersetGroup': serializer.toJson<int?>(supersetGroup),
      'targetSets': serializer.toJson<int>(targetSets),
      'targetReps': serializer.toJson<int?>(targetReps),
      'targetDurationSec': serializer.toJson<int?>(targetDurationSec),
      'targetDistanceM': serializer.toJson<double?>(targetDistanceM),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'restSec': serializer.toJson<int?>(restSec),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  RoutineItemRow copyWith({
    String? id,
    String? routineId,
    String? exerciseId,
    int? position,
    Value<int?> supersetGroup = const Value.absent(),
    int? targetSets,
    Value<int?> targetReps = const Value.absent(),
    Value<int?> targetDurationSec = const Value.absent(),
    Value<double?> targetDistanceM = const Value.absent(),
    Value<double?> targetWeightKg = const Value.absent(),
    Value<int?> restSec = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => RoutineItemRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    supersetGroup: supersetGroup.present
        ? supersetGroup.value
        : this.supersetGroup,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps.present ? targetReps.value : this.targetReps,
    targetDurationSec: targetDurationSec.present
        ? targetDurationSec.value
        : this.targetDurationSec,
    targetDistanceM: targetDistanceM.present
        ? targetDistanceM.value
        : this.targetDistanceM,
    targetWeightKg: targetWeightKg.present
        ? targetWeightKg.value
        : this.targetWeightKg,
    restSec: restSec.present ? restSec.value : this.restSec,
    notes: notes.present ? notes.value : this.notes,
  );
  RoutineItemRow copyWithCompanion(RoutineItemsCompanion data) {
    return RoutineItemRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      supersetGroup: data.supersetGroup.present
          ? data.supersetGroup.value
          : this.supersetGroup,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
      targetDurationSec: data.targetDurationSec.present
          ? data.targetDurationSec.value
          : this.targetDurationSec,
      targetDistanceM: data.targetDistanceM.present
          ? data.targetDistanceM.value
          : this.targetDistanceM,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      restSec: data.restSec.present ? data.restSec.value : this.restSec,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('supersetGroup: $supersetGroup, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('targetDurationSec: $targetDurationSec, ')
          ..write('targetDistanceM: $targetDistanceM, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('restSec: $restSec, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    exerciseId,
    position,
    supersetGroup,
    targetSets,
    targetReps,
    targetDurationSec,
    targetDistanceM,
    targetWeightKg,
    restSec,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineItemRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.supersetGroup == this.supersetGroup &&
          other.targetSets == this.targetSets &&
          other.targetReps == this.targetReps &&
          other.targetDurationSec == this.targetDurationSec &&
          other.targetDistanceM == this.targetDistanceM &&
          other.targetWeightKg == this.targetWeightKg &&
          other.restSec == this.restSec &&
          other.notes == this.notes);
}

class RoutineItemsCompanion extends UpdateCompanion<RoutineItemRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String> exerciseId;
  final Value<int> position;
  final Value<int?> supersetGroup;
  final Value<int> targetSets;
  final Value<int?> targetReps;
  final Value<int?> targetDurationSec;
  final Value<double?> targetDistanceM;
  final Value<double?> targetWeightKg;
  final Value<int?> restSec;
  final Value<String?> notes;
  final Value<int> rowid;
  const RoutineItemsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.supersetGroup = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.targetDurationSec = const Value.absent(),
    this.targetDistanceM = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.restSec = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineItemsCompanion.insert({
    required String id,
    required String routineId,
    required String exerciseId,
    required int position,
    this.supersetGroup = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.targetDurationSec = const Value.absent(),
    this.targetDistanceM = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.restSec = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       routineId = Value(routineId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<RoutineItemRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? exerciseId,
    Expression<int>? position,
    Expression<int>? supersetGroup,
    Expression<int>? targetSets,
    Expression<int>? targetReps,
    Expression<int>? targetDurationSec,
    Expression<double>? targetDistanceM,
    Expression<double>? targetWeightKg,
    Expression<int>? restSec,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (supersetGroup != null) 'superset_group': supersetGroup,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetReps != null) 'target_reps': targetReps,
      if (targetDurationSec != null) 'target_duration_sec': targetDurationSec,
      if (targetDistanceM != null) 'target_distance_m': targetDistanceM,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (restSec != null) 'rest_sec': restSec,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<String>? exerciseId,
    Value<int>? position,
    Value<int?>? supersetGroup,
    Value<int>? targetSets,
    Value<int?>? targetReps,
    Value<int?>? targetDurationSec,
    Value<double?>? targetDistanceM,
    Value<double?>? targetWeightKg,
    Value<int?>? restSec,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return RoutineItemsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      supersetGroup: supersetGroup ?? this.supersetGroup,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetDurationSec: targetDurationSec ?? this.targetDurationSec,
      targetDistanceM: targetDistanceM ?? this.targetDistanceM,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      restSec: restSec ?? this.restSec,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (supersetGroup.present) {
      map['superset_group'] = Variable<int>(supersetGroup.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (targetDurationSec.present) {
      map['target_duration_sec'] = Variable<int>(targetDurationSec.value);
    }
    if (targetDistanceM.present) {
      map['target_distance_m'] = Variable<double>(targetDistanceM.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (restSec.present) {
      map['rest_sec'] = Variable<int>(restSec.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('supersetGroup: $supersetGroup, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('targetDurationSec: $targetDurationSec, ')
          ..write('targetDistanceM: $targetDistanceM, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('restSec: $restSec, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _perceivedEffortMeta = const VerificationMeta(
    'perceivedEffort',
  );
  @override
  late final GeneratedColumn<int> perceivedEffort = GeneratedColumn<int>(
    'perceived_effort',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SessionSource.manual.name),
      ).withConverter<SessionSource>($WorkoutSessionsTable.$convertersource);
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _volumeKgMeta = const VerificationMeta(
    'volumeKg',
  );
  @override
  late final GeneratedColumn<double> volumeKg = GeneratedColumn<double>(
    'volume_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesKcalMeta = const VerificationMeta(
    'caloriesKcal',
  );
  @override
  late final GeneratedColumn<double> caloriesKcal = GeneratedColumn<double>(
    'calories_kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startedAt,
    endedAt,
    routineId,
    notes,
    perceivedEffort,
    source,
    durationSec,
    volumeKg,
    caloriesKcal,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('perceived_effort')) {
      context.handle(
        _perceivedEffortMeta,
        perceivedEffort.isAcceptableOrUnknown(
          data['perceived_effort']!,
          _perceivedEffortMeta,
        ),
      );
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    if (data.containsKey('volume_kg')) {
      context.handle(
        _volumeKgMeta,
        volumeKg.isAcceptableOrUnknown(data['volume_kg']!, _volumeKgMeta),
      );
    }
    if (data.containsKey('calories_kcal')) {
      context.handle(
        _caloriesKcalMeta,
        caloriesKcal.isAcceptableOrUnknown(
          data['calories_kcal']!,
          _caloriesKcalMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      perceivedEffort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perceived_effort'],
      ),
      source: $WorkoutSessionsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      ),
      volumeKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume_kg'],
      ),
      caloriesKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_kcal'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionSource, String, String> $convertersource =
      const EnumNameConverter<SessionSource>(SessionSource.values);
}

class WorkoutSessionRow extends DataClass
    implements Insertable<WorkoutSessionRow> {
  final String id;
  final String? name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? routineId;
  final String? notes;
  final int? perceivedEffort;
  final SessionSource source;
  final int? durationSec;
  final double? volumeKg;
  final double? caloriesKcal;
  final DateTime updatedAt;
  const WorkoutSessionRow({
    required this.id,
    this.name,
    required this.startedAt,
    this.endedAt,
    this.routineId,
    this.notes,
    this.perceivedEffort,
    required this.source,
    this.durationSec,
    this.volumeKg,
    this.caloriesKcal,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || routineId != null) {
      map['routine_id'] = Variable<String>(routineId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || perceivedEffort != null) {
      map['perceived_effort'] = Variable<int>(perceivedEffort);
    }
    {
      map['source'] = Variable<String>(
        $WorkoutSessionsTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || durationSec != null) {
      map['duration_sec'] = Variable<int>(durationSec);
    }
    if (!nullToAbsent || volumeKg != null) {
      map['volume_kg'] = Variable<double>(volumeKg);
    }
    if (!nullToAbsent || caloriesKcal != null) {
      map['calories_kcal'] = Variable<double>(caloriesKcal);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      routineId: routineId == null && nullToAbsent
          ? const Value.absent()
          : Value(routineId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      perceivedEffort: perceivedEffort == null && nullToAbsent
          ? const Value.absent()
          : Value(perceivedEffort),
      source: Value(source),
      durationSec: durationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSec),
      volumeKg: volumeKg == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeKg),
      caloriesKcal: caloriesKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(caloriesKcal),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkoutSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      routineId: serializer.fromJson<String?>(json['routineId']),
      notes: serializer.fromJson<String?>(json['notes']),
      perceivedEffort: serializer.fromJson<int?>(json['perceivedEffort']),
      source: $WorkoutSessionsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      durationSec: serializer.fromJson<int?>(json['durationSec']),
      volumeKg: serializer.fromJson<double?>(json['volumeKg']),
      caloriesKcal: serializer.fromJson<double?>(json['caloriesKcal']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'routineId': serializer.toJson<String?>(routineId),
      'notes': serializer.toJson<String?>(notes),
      'perceivedEffort': serializer.toJson<int?>(perceivedEffort),
      'source': serializer.toJson<String>(
        $WorkoutSessionsTable.$convertersource.toJson(source),
      ),
      'durationSec': serializer.toJson<int?>(durationSec),
      'volumeKg': serializer.toJson<double?>(volumeKg),
      'caloriesKcal': serializer.toJson<double?>(caloriesKcal),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkoutSessionRow copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> routineId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> perceivedEffort = const Value.absent(),
    SessionSource? source,
    Value<int?> durationSec = const Value.absent(),
    Value<double?> volumeKg = const Value.absent(),
    Value<double?> caloriesKcal = const Value.absent(),
    DateTime? updatedAt,
  }) => WorkoutSessionRow(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    routineId: routineId.present ? routineId.value : this.routineId,
    notes: notes.present ? notes.value : this.notes,
    perceivedEffort: perceivedEffort.present
        ? perceivedEffort.value
        : this.perceivedEffort,
    source: source ?? this.source,
    durationSec: durationSec.present ? durationSec.value : this.durationSec,
    volumeKg: volumeKg.present ? volumeKg.value : this.volumeKg,
    caloriesKcal: caloriesKcal.present ? caloriesKcal.value : this.caloriesKcal,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkoutSessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      notes: data.notes.present ? data.notes.value : this.notes,
      perceivedEffort: data.perceivedEffort.present
          ? data.perceivedEffort.value
          : this.perceivedEffort,
      source: data.source.present ? data.source.value : this.source,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      volumeKg: data.volumeKg.present ? data.volumeKg.value : this.volumeKg,
      caloriesKcal: data.caloriesKcal.present
          ? data.caloriesKcal.value
          : this.caloriesKcal,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('routineId: $routineId, ')
          ..write('notes: $notes, ')
          ..write('perceivedEffort: $perceivedEffort, ')
          ..write('source: $source, ')
          ..write('durationSec: $durationSec, ')
          ..write('volumeKg: $volumeKg, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    startedAt,
    endedAt,
    routineId,
    notes,
    perceivedEffort,
    source,
    durationSec,
    volumeKg,
    caloriesKcal,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.routineId == this.routineId &&
          other.notes == this.notes &&
          other.perceivedEffort == this.perceivedEffort &&
          other.source == this.source &&
          other.durationSec == this.durationSec &&
          other.volumeKg == this.volumeKg &&
          other.caloriesKcal == this.caloriesKcal &&
          other.updatedAt == this.updatedAt);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSessionRow> {
  final Value<String> id;
  final Value<String?> name;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> routineId;
  final Value<String?> notes;
  final Value<int?> perceivedEffort;
  final Value<SessionSource> source;
  final Value<int?> durationSec;
  final Value<double?> volumeKg;
  final Value<double?> caloriesKcal;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.routineId = const Value.absent(),
    this.notes = const Value.absent(),
    this.perceivedEffort = const Value.absent(),
    this.source = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.volumeKg = const Value.absent(),
    this.caloriesKcal = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.routineId = const Value.absent(),
    this.notes = const Value.absent(),
    this.perceivedEffort = const Value.absent(),
    this.source = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.volumeKg = const Value.absent(),
    this.caloriesKcal = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkoutSessionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? routineId,
    Expression<String>? notes,
    Expression<int>? perceivedEffort,
    Expression<String>? source,
    Expression<int>? durationSec,
    Expression<double>? volumeKg,
    Expression<double>? caloriesKcal,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (routineId != null) 'routine_id': routineId,
      if (notes != null) 'notes': notes,
      if (perceivedEffort != null) 'perceived_effort': perceivedEffort,
      if (source != null) 'source': source,
      if (durationSec != null) 'duration_sec': durationSec,
      if (volumeKg != null) 'volume_kg': volumeKg,
      if (caloriesKcal != null) 'calories_kcal': caloriesKcal,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? routineId,
    Value<String?>? notes,
    Value<int?>? perceivedEffort,
    Value<SessionSource>? source,
    Value<int?>? durationSec,
    Value<double?>? volumeKg,
    Value<double?>? caloriesKcal,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      routineId: routineId ?? this.routineId,
      notes: notes ?? this.notes,
      perceivedEffort: perceivedEffort ?? this.perceivedEffort,
      source: source ?? this.source,
      durationSec: durationSec ?? this.durationSec,
      volumeKg: volumeKg ?? this.volumeKg,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (perceivedEffort.present) {
      map['perceived_effort'] = Variable<int>(perceivedEffort.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $WorkoutSessionsTable.$convertersource.toSql(source.value),
      );
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (volumeKg.present) {
      map['volume_kg'] = Variable<double>(volumeKg.value);
    }
    if (caloriesKcal.present) {
      map['calories_kcal'] = Variable<double>(caloriesKcal.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('routineId: $routineId, ')
          ..write('notes: $notes, ')
          ..write('perceivedEffort: $perceivedEffort, ')
          ..write('source: $source, ')
          ..write('durationSec: $durationSec, ')
          ..write('volumeKg: $volumeKg, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionExercisesTable extends SessionExercises
    with TableInfo<$SessionExercisesTable, SessionExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersetGroupMeta = const VerificationMeta(
    'supersetGroup',
  );
  @override
  late final GeneratedColumn<int> supersetGroup = GeneratedColumn<int>(
    'superset_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    position,
    supersetGroup,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('superset_group')) {
      context.handle(
        _supersetGroupMeta,
        supersetGroup.isAcceptableOrUnknown(
          data['superset_group']!,
          _supersetGroupMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      supersetGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superset_group'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SessionExercisesTable createAlias(String alias) {
    return $SessionExercisesTable(attachedDatabase, alias);
  }
}

class SessionExerciseRow extends DataClass
    implements Insertable<SessionExerciseRow> {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int position;
  final int? supersetGroup;
  final String? notes;
  const SessionExerciseRow({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.position,
    this.supersetGroup,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || supersetGroup != null) {
      map['superset_group'] = Variable<int>(supersetGroup);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      supersetGroup: supersetGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroup),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SessionExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      supersetGroup: serializer.fromJson<int?>(json['supersetGroup']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'position': serializer.toJson<int>(position),
      'supersetGroup': serializer.toJson<int?>(supersetGroup),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SessionExerciseRow copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    int? position,
    Value<int?> supersetGroup = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SessionExerciseRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    supersetGroup: supersetGroup.present
        ? supersetGroup.value
        : this.supersetGroup,
    notes: notes.present ? notes.value : this.notes,
  );
  SessionExerciseRow copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      supersetGroup: data.supersetGroup.present
          ? data.supersetGroup.value
          : this.supersetGroup,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('supersetGroup: $supersetGroup, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, exerciseId, position, supersetGroup, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExerciseRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.supersetGroup == this.supersetGroup &&
          other.notes == this.notes);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExerciseRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<int> position;
  final Value<int?> supersetGroup;
  final Value<String?> notes;
  final Value<int> rowid;
  const SessionExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.supersetGroup = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int position,
    this.supersetGroup = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<SessionExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<int>? position,
    Expression<int>? supersetGroup,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (supersetGroup != null) 'superset_group': supersetGroup,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? exerciseId,
    Value<int>? position,
    Value<int?>? supersetGroup,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return SessionExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      supersetGroup: supersetGroup ?? this.supersetGroup,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (supersetGroup.present) {
      map['superset_group'] = Variable<int>(supersetGroup.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('supersetGroup: $supersetGroup, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetEntriesTable extends SetEntries
    with TableInfo<$SetEntriesTable, SetEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta(
    'sessionExerciseId',
  );
  @override
  late final GeneratedColumn<String> sessionExerciseId =
      GeneratedColumn<String>(
        'session_exercise_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES session_exercises (id) ON DELETE CASCADE',
        ),
      );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SetType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SetType.normal.name),
      ).withConverter<SetType>($SetEntriesTable.$convertertype);
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holdSecMeta = const VerificationMeta(
    'holdSec',
  );
  @override
  late final GeneratedColumn<int> holdSec = GeneratedColumn<int>(
    'hold_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWarmupMeta = const VerificationMeta(
    'isWarmup',
  );
  @override
  late final GeneratedColumn<bool> isWarmup = GeneratedColumn<bool>(
    'is_warmup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_warmup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPrMeta = const VerificationMeta('isPr');
  @override
  late final GeneratedColumn<bool> isPr = GeneratedColumn<bool>(
    'is_pr',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pr" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionExerciseId,
    position,
    type,
    weightKg,
    reps,
    durationSec,
    distanceM,
    rounds,
    holdSec,
    completed,
    isWarmup,
    isPr,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(
        _sessionExerciseIdMeta,
        sessionExerciseId.isAcceptableOrUnknown(
          data['session_exercise_id']!,
          _sessionExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    }
    if (data.containsKey('hold_sec')) {
      context.handle(
        _holdSecMeta,
        holdSec.isAcceptableOrUnknown(data['hold_sec']!, _holdSecMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('is_warmup')) {
      context.handle(
        _isWarmupMeta,
        isWarmup.isAcceptableOrUnknown(data['is_warmup']!, _isWarmupMeta),
      );
    }
    if (data.containsKey('is_pr')) {
      context.handle(
        _isPrMeta,
        isPr.isAcceptableOrUnknown(data['is_pr']!, _isPrMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      type: $SetEntriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      ),
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      ),
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      ),
      holdSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hold_sec'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      isWarmup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_warmup'],
      )!,
      isPr: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pr'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $SetEntriesTable createAlias(String alias) {
    return $SetEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SetType, String, String> $convertertype =
      const EnumNameConverter<SetType>(SetType.values);
}

class SetEntryRow extends DataClass implements Insertable<SetEntryRow> {
  final String id;
  final String sessionExerciseId;
  final int position;
  final SetType type;
  final double? weightKg;
  final int? reps;
  final int? durationSec;
  final double? distanceM;
  final int? rounds;
  final int? holdSec;
  final bool completed;
  final bool isWarmup;
  final bool isPr;
  final DateTime? completedAt;
  const SetEntryRow({
    required this.id,
    required this.sessionExerciseId,
    required this.position,
    required this.type,
    this.weightKg,
    this.reps,
    this.durationSec,
    this.distanceM,
    this.rounds,
    this.holdSec,
    required this.completed,
    required this.isWarmup,
    required this.isPr,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_exercise_id'] = Variable<String>(sessionExerciseId);
    map['position'] = Variable<int>(position);
    {
      map['type'] = Variable<String>(
        $SetEntriesTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || durationSec != null) {
      map['duration_sec'] = Variable<int>(durationSec);
    }
    if (!nullToAbsent || distanceM != null) {
      map['distance_m'] = Variable<double>(distanceM);
    }
    if (!nullToAbsent || rounds != null) {
      map['rounds'] = Variable<int>(rounds);
    }
    if (!nullToAbsent || holdSec != null) {
      map['hold_sec'] = Variable<int>(holdSec);
    }
    map['completed'] = Variable<bool>(completed);
    map['is_warmup'] = Variable<bool>(isWarmup);
    map['is_pr'] = Variable<bool>(isPr);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  SetEntriesCompanion toCompanion(bool nullToAbsent) {
    return SetEntriesCompanion(
      id: Value(id),
      sessionExerciseId: Value(sessionExerciseId),
      position: Value(position),
      type: Value(type),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      durationSec: durationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSec),
      distanceM: distanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceM),
      rounds: rounds == null && nullToAbsent
          ? const Value.absent()
          : Value(rounds),
      holdSec: holdSec == null && nullToAbsent
          ? const Value.absent()
          : Value(holdSec),
      completed: Value(completed),
      isWarmup: Value(isWarmup),
      isPr: Value(isPr),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory SetEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetEntryRow(
      id: serializer.fromJson<String>(json['id']),
      sessionExerciseId: serializer.fromJson<String>(json['sessionExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      type: $SetEntriesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      reps: serializer.fromJson<int?>(json['reps']),
      durationSec: serializer.fromJson<int?>(json['durationSec']),
      distanceM: serializer.fromJson<double?>(json['distanceM']),
      rounds: serializer.fromJson<int?>(json['rounds']),
      holdSec: serializer.fromJson<int?>(json['holdSec']),
      completed: serializer.fromJson<bool>(json['completed']),
      isWarmup: serializer.fromJson<bool>(json['isWarmup']),
      isPr: serializer.fromJson<bool>(json['isPr']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionExerciseId': serializer.toJson<String>(sessionExerciseId),
      'position': serializer.toJson<int>(position),
      'type': serializer.toJson<String>(
        $SetEntriesTable.$convertertype.toJson(type),
      ),
      'weightKg': serializer.toJson<double?>(weightKg),
      'reps': serializer.toJson<int?>(reps),
      'durationSec': serializer.toJson<int?>(durationSec),
      'distanceM': serializer.toJson<double?>(distanceM),
      'rounds': serializer.toJson<int?>(rounds),
      'holdSec': serializer.toJson<int?>(holdSec),
      'completed': serializer.toJson<bool>(completed),
      'isWarmup': serializer.toJson<bool>(isWarmup),
      'isPr': serializer.toJson<bool>(isPr),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  SetEntryRow copyWith({
    String? id,
    String? sessionExerciseId,
    int? position,
    SetType? type,
    Value<double?> weightKg = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> durationSec = const Value.absent(),
    Value<double?> distanceM = const Value.absent(),
    Value<int?> rounds = const Value.absent(),
    Value<int?> holdSec = const Value.absent(),
    bool? completed,
    bool? isWarmup,
    bool? isPr,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => SetEntryRow(
    id: id ?? this.id,
    sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
    position: position ?? this.position,
    type: type ?? this.type,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    reps: reps.present ? reps.value : this.reps,
    durationSec: durationSec.present ? durationSec.value : this.durationSec,
    distanceM: distanceM.present ? distanceM.value : this.distanceM,
    rounds: rounds.present ? rounds.value : this.rounds,
    holdSec: holdSec.present ? holdSec.value : this.holdSec,
    completed: completed ?? this.completed,
    isWarmup: isWarmup ?? this.isWarmup,
    isPr: isPr ?? this.isPr,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  SetEntryRow copyWithCompanion(SetEntriesCompanion data) {
    return SetEntryRow(
      id: data.id.present ? data.id.value : this.id,
      sessionExerciseId: data.sessionExerciseId.present
          ? data.sessionExerciseId.value
          : this.sessionExerciseId,
      position: data.position.present ? data.position.value : this.position,
      type: data.type.present ? data.type.value : this.type,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      holdSec: data.holdSec.present ? data.holdSec.value : this.holdSec,
      completed: data.completed.present ? data.completed.value : this.completed,
      isWarmup: data.isWarmup.present ? data.isWarmup.value : this.isWarmup,
      isPr: data.isPr.present ? data.isPr.value : this.isPr,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetEntryRow(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('type: $type, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('durationSec: $durationSec, ')
          ..write('distanceM: $distanceM, ')
          ..write('rounds: $rounds, ')
          ..write('holdSec: $holdSec, ')
          ..write('completed: $completed, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('isPr: $isPr, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionExerciseId,
    position,
    type,
    weightKg,
    reps,
    durationSec,
    distanceM,
    rounds,
    holdSec,
    completed,
    isWarmup,
    isPr,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetEntryRow &&
          other.id == this.id &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.position == this.position &&
          other.type == this.type &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.durationSec == this.durationSec &&
          other.distanceM == this.distanceM &&
          other.rounds == this.rounds &&
          other.holdSec == this.holdSec &&
          other.completed == this.completed &&
          other.isWarmup == this.isWarmup &&
          other.isPr == this.isPr &&
          other.completedAt == this.completedAt);
}

class SetEntriesCompanion extends UpdateCompanion<SetEntryRow> {
  final Value<String> id;
  final Value<String> sessionExerciseId;
  final Value<int> position;
  final Value<SetType> type;
  final Value<double?> weightKg;
  final Value<int?> reps;
  final Value<int?> durationSec;
  final Value<double?> distanceM;
  final Value<int?> rounds;
  final Value<int?> holdSec;
  final Value<bool> completed;
  final Value<bool> isWarmup;
  final Value<bool> isPr;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const SetEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.type = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.rounds = const Value.absent(),
    this.holdSec = const Value.absent(),
    this.completed = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.isPr = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetEntriesCompanion.insert({
    required String id,
    required String sessionExerciseId,
    required int position,
    this.type = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.rounds = const Value.absent(),
    this.holdSec = const Value.absent(),
    this.completed = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.isPr = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionExerciseId = Value(sessionExerciseId),
       position = Value(position);
  static Insertable<SetEntryRow> custom({
    Expression<String>? id,
    Expression<String>? sessionExerciseId,
    Expression<int>? position,
    Expression<String>? type,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<int>? durationSec,
    Expression<double>? distanceM,
    Expression<int>? rounds,
    Expression<int>? holdSec,
    Expression<bool>? completed,
    Expression<bool>? isWarmup,
    Expression<bool>? isPr,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (position != null) 'position': position,
      if (type != null) 'type': type,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (durationSec != null) 'duration_sec': durationSec,
      if (distanceM != null) 'distance_m': distanceM,
      if (rounds != null) 'rounds': rounds,
      if (holdSec != null) 'hold_sec': holdSec,
      if (completed != null) 'completed': completed,
      if (isWarmup != null) 'is_warmup': isWarmup,
      if (isPr != null) 'is_pr': isPr,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionExerciseId,
    Value<int>? position,
    Value<SetType>? type,
    Value<double?>? weightKg,
    Value<int?>? reps,
    Value<int?>? durationSec,
    Value<double?>? distanceM,
    Value<int?>? rounds,
    Value<int?>? holdSec,
    Value<bool>? completed,
    Value<bool>? isWarmup,
    Value<bool>? isPr,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return SetEntriesCompanion(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      position: position ?? this.position,
      type: type ?? this.type,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      durationSec: durationSec ?? this.durationSec,
      distanceM: distanceM ?? this.distanceM,
      rounds: rounds ?? this.rounds,
      holdSec: holdSec ?? this.holdSec,
      completed: completed ?? this.completed,
      isWarmup: isWarmup ?? this.isWarmup,
      isPr: isPr ?? this.isPr,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<String>(sessionExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $SetEntriesTable.$convertertype.toSql(type.value),
      );
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (holdSec.present) {
      map['hold_sec'] = Variable<int>(holdSec.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (isWarmup.present) {
      map['is_warmup'] = Variable<bool>(isWarmup.value);
    }
    if (isPr.present) {
      map['is_pr'] = Variable<bool>(isPr.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('position: $position, ')
          ..write('type: $type, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('durationSec: $durationSec, ')
          ..write('distanceM: $distanceM, ')
          ..write('rounds: $rounds, ')
          ..write('holdSec: $holdSec, ')
          ..write('completed: $completed, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('isPr: $isPr, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementFieldsTable extends MeasurementFields
    with TableInfo<$MeasurementFieldsTable, MeasurementFieldRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MeasurementUnitType, String>
  unitType =
      GeneratedColumn<String>(
        'unit_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MeasurementUnitType>(
        $MeasurementFieldsTable.$converterunitType,
      );
  static const VerificationMeta _customUnitMeta = const VerificationMeta(
    'customUnit',
  );
  @override
  late final GeneratedColumn<String> customUnit = GeneratedColumn<String>(
    'custom_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BodySide, String> side =
      GeneratedColumn<String>(
        'side',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(BodySide.none.name),
      ).withConverter<BodySide>($MeasurementFieldsTable.$converterside);
  static const VerificationMeta _pairIdMeta = const VerificationMeta('pairId');
  @override
  late final GeneratedColumn<String> pairId = GeneratedColumn<String>(
    'pair_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BodyAnchor?, String> bodyAnchor =
      GeneratedColumn<String>(
        'body_anchor',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<BodyAnchor?>(
        $MeasurementFieldsTable.$converterbodyAnchorn,
      );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta(
    'builtIn',
  );
  @override
  late final GeneratedColumn<bool> builtIn = GeneratedColumn<bool>(
    'built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    unitType,
    customUnit,
    side,
    pairId,
    bodyAnchor,
    enabled,
    position,
    builtIn,
    archived,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementFieldRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('custom_unit')) {
      context.handle(
        _customUnitMeta,
        customUnit.isAcceptableOrUnknown(data['custom_unit']!, _customUnitMeta),
      );
    }
    if (data.containsKey('pair_id')) {
      context.handle(
        _pairIdMeta,
        pairId.isAcceptableOrUnknown(data['pair_id']!, _pairIdMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('built_in')) {
      context.handle(
        _builtInMeta,
        builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementFieldRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementFieldRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unitType: $MeasurementFieldsTable.$converterunitType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit_type'],
        )!,
      ),
      customUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_unit'],
      ),
      side: $MeasurementFieldsTable.$converterside.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}side'],
        )!,
      ),
      pairId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pair_id'],
      ),
      bodyAnchor: $MeasurementFieldsTable.$converterbodyAnchorn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}body_anchor'],
        ),
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      builtIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}built_in'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MeasurementFieldsTable createAlias(String alias) {
    return $MeasurementFieldsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MeasurementUnitType, String, String>
  $converterunitType = const EnumNameConverter<MeasurementUnitType>(
    MeasurementUnitType.values,
  );
  static JsonTypeConverter2<BodySide, String, String> $converterside =
      const EnumNameConverter<BodySide>(BodySide.values);
  static JsonTypeConverter2<BodyAnchor, String, String> $converterbodyAnchor =
      const EnumNameConverter<BodyAnchor>(BodyAnchor.values);
  static JsonTypeConverter2<BodyAnchor?, String?, String?>
  $converterbodyAnchorn = JsonTypeConverter2.asNullable($converterbodyAnchor);
}

class MeasurementFieldRow extends DataClass
    implements Insertable<MeasurementFieldRow> {
  final String id;
  final String name;
  final MeasurementUnitType unitType;
  final String? customUnit;
  final BodySide side;
  final String? pairId;
  final BodyAnchor? bodyAnchor;
  final bool enabled;
  final int position;
  final bool builtIn;
  final bool archived;
  final DateTime updatedAt;
  const MeasurementFieldRow({
    required this.id,
    required this.name,
    required this.unitType,
    this.customUnit,
    required this.side,
    this.pairId,
    this.bodyAnchor,
    required this.enabled,
    required this.position,
    required this.builtIn,
    required this.archived,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['unit_type'] = Variable<String>(
        $MeasurementFieldsTable.$converterunitType.toSql(unitType),
      );
    }
    if (!nullToAbsent || customUnit != null) {
      map['custom_unit'] = Variable<String>(customUnit);
    }
    {
      map['side'] = Variable<String>(
        $MeasurementFieldsTable.$converterside.toSql(side),
      );
    }
    if (!nullToAbsent || pairId != null) {
      map['pair_id'] = Variable<String>(pairId);
    }
    if (!nullToAbsent || bodyAnchor != null) {
      map['body_anchor'] = Variable<String>(
        $MeasurementFieldsTable.$converterbodyAnchorn.toSql(bodyAnchor),
      );
    }
    map['enabled'] = Variable<bool>(enabled);
    map['position'] = Variable<int>(position);
    map['built_in'] = Variable<bool>(builtIn);
    map['archived'] = Variable<bool>(archived);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MeasurementFieldsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementFieldsCompanion(
      id: Value(id),
      name: Value(name),
      unitType: Value(unitType),
      customUnit: customUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(customUnit),
      side: Value(side),
      pairId: pairId == null && nullToAbsent
          ? const Value.absent()
          : Value(pairId),
      bodyAnchor: bodyAnchor == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyAnchor),
      enabled: Value(enabled),
      position: Value(position),
      builtIn: Value(builtIn),
      archived: Value(archived),
      updatedAt: Value(updatedAt),
    );
  }

  factory MeasurementFieldRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementFieldRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      unitType: $MeasurementFieldsTable.$converterunitType.fromJson(
        serializer.fromJson<String>(json['unitType']),
      ),
      customUnit: serializer.fromJson<String?>(json['customUnit']),
      side: $MeasurementFieldsTable.$converterside.fromJson(
        serializer.fromJson<String>(json['side']),
      ),
      pairId: serializer.fromJson<String?>(json['pairId']),
      bodyAnchor: $MeasurementFieldsTable.$converterbodyAnchorn.fromJson(
        serializer.fromJson<String?>(json['bodyAnchor']),
      ),
      enabled: serializer.fromJson<bool>(json['enabled']),
      position: serializer.fromJson<int>(json['position']),
      builtIn: serializer.fromJson<bool>(json['builtIn']),
      archived: serializer.fromJson<bool>(json['archived']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'unitType': serializer.toJson<String>(
        $MeasurementFieldsTable.$converterunitType.toJson(unitType),
      ),
      'customUnit': serializer.toJson<String?>(customUnit),
      'side': serializer.toJson<String>(
        $MeasurementFieldsTable.$converterside.toJson(side),
      ),
      'pairId': serializer.toJson<String?>(pairId),
      'bodyAnchor': serializer.toJson<String?>(
        $MeasurementFieldsTable.$converterbodyAnchorn.toJson(bodyAnchor),
      ),
      'enabled': serializer.toJson<bool>(enabled),
      'position': serializer.toJson<int>(position),
      'builtIn': serializer.toJson<bool>(builtIn),
      'archived': serializer.toJson<bool>(archived),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MeasurementFieldRow copyWith({
    String? id,
    String? name,
    MeasurementUnitType? unitType,
    Value<String?> customUnit = const Value.absent(),
    BodySide? side,
    Value<String?> pairId = const Value.absent(),
    Value<BodyAnchor?> bodyAnchor = const Value.absent(),
    bool? enabled,
    int? position,
    bool? builtIn,
    bool? archived,
    DateTime? updatedAt,
  }) => MeasurementFieldRow(
    id: id ?? this.id,
    name: name ?? this.name,
    unitType: unitType ?? this.unitType,
    customUnit: customUnit.present ? customUnit.value : this.customUnit,
    side: side ?? this.side,
    pairId: pairId.present ? pairId.value : this.pairId,
    bodyAnchor: bodyAnchor.present ? bodyAnchor.value : this.bodyAnchor,
    enabled: enabled ?? this.enabled,
    position: position ?? this.position,
    builtIn: builtIn ?? this.builtIn,
    archived: archived ?? this.archived,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MeasurementFieldRow copyWithCompanion(MeasurementFieldsCompanion data) {
    return MeasurementFieldRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      customUnit: data.customUnit.present
          ? data.customUnit.value
          : this.customUnit,
      side: data.side.present ? data.side.value : this.side,
      pairId: data.pairId.present ? data.pairId.value : this.pairId,
      bodyAnchor: data.bodyAnchor.present
          ? data.bodyAnchor.value
          : this.bodyAnchor,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      position: data.position.present ? data.position.value : this.position,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      archived: data.archived.present ? data.archived.value : this.archived,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementFieldRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unitType: $unitType, ')
          ..write('customUnit: $customUnit, ')
          ..write('side: $side, ')
          ..write('pairId: $pairId, ')
          ..write('bodyAnchor: $bodyAnchor, ')
          ..write('enabled: $enabled, ')
          ..write('position: $position, ')
          ..write('builtIn: $builtIn, ')
          ..write('archived: $archived, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    unitType,
    customUnit,
    side,
    pairId,
    bodyAnchor,
    enabled,
    position,
    builtIn,
    archived,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementFieldRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.unitType == this.unitType &&
          other.customUnit == this.customUnit &&
          other.side == this.side &&
          other.pairId == this.pairId &&
          other.bodyAnchor == this.bodyAnchor &&
          other.enabled == this.enabled &&
          other.position == this.position &&
          other.builtIn == this.builtIn &&
          other.archived == this.archived &&
          other.updatedAt == this.updatedAt);
}

class MeasurementFieldsCompanion extends UpdateCompanion<MeasurementFieldRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<MeasurementUnitType> unitType;
  final Value<String?> customUnit;
  final Value<BodySide> side;
  final Value<String?> pairId;
  final Value<BodyAnchor?> bodyAnchor;
  final Value<bool> enabled;
  final Value<int> position;
  final Value<bool> builtIn;
  final Value<bool> archived;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MeasurementFieldsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.unitType = const Value.absent(),
    this.customUnit = const Value.absent(),
    this.side = const Value.absent(),
    this.pairId = const Value.absent(),
    this.bodyAnchor = const Value.absent(),
    this.enabled = const Value.absent(),
    this.position = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.archived = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementFieldsCompanion.insert({
    required String id,
    required String name,
    required MeasurementUnitType unitType,
    this.customUnit = const Value.absent(),
    this.side = const Value.absent(),
    this.pairId = const Value.absent(),
    this.bodyAnchor = const Value.absent(),
    this.enabled = const Value.absent(),
    this.position = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.archived = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       unitType = Value(unitType),
       updatedAt = Value(updatedAt);
  static Insertable<MeasurementFieldRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? unitType,
    Expression<String>? customUnit,
    Expression<String>? side,
    Expression<String>? pairId,
    Expression<String>? bodyAnchor,
    Expression<bool>? enabled,
    Expression<int>? position,
    Expression<bool>? builtIn,
    Expression<bool>? archived,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (unitType != null) 'unit_type': unitType,
      if (customUnit != null) 'custom_unit': customUnit,
      if (side != null) 'side': side,
      if (pairId != null) 'pair_id': pairId,
      if (bodyAnchor != null) 'body_anchor': bodyAnchor,
      if (enabled != null) 'enabled': enabled,
      if (position != null) 'position': position,
      if (builtIn != null) 'built_in': builtIn,
      if (archived != null) 'archived': archived,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementFieldsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<MeasurementUnitType>? unitType,
    Value<String?>? customUnit,
    Value<BodySide>? side,
    Value<String?>? pairId,
    Value<BodyAnchor?>? bodyAnchor,
    Value<bool>? enabled,
    Value<int>? position,
    Value<bool>? builtIn,
    Value<bool>? archived,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MeasurementFieldsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      unitType: unitType ?? this.unitType,
      customUnit: customUnit ?? this.customUnit,
      side: side ?? this.side,
      pairId: pairId ?? this.pairId,
      bodyAnchor: bodyAnchor ?? this.bodyAnchor,
      enabled: enabled ?? this.enabled,
      position: position ?? this.position,
      builtIn: builtIn ?? this.builtIn,
      archived: archived ?? this.archived,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(
        $MeasurementFieldsTable.$converterunitType.toSql(unitType.value),
      );
    }
    if (customUnit.present) {
      map['custom_unit'] = Variable<String>(customUnit.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(
        $MeasurementFieldsTable.$converterside.toSql(side.value),
      );
    }
    if (pairId.present) {
      map['pair_id'] = Variable<String>(pairId.value);
    }
    if (bodyAnchor.present) {
      map['body_anchor'] = Variable<String>(
        $MeasurementFieldsTable.$converterbodyAnchorn.toSql(bodyAnchor.value),
      );
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<bool>(builtIn.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementFieldsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unitType: $unitType, ')
          ..write('customUnit: $customUnit, ')
          ..write('side: $side, ')
          ..write('pairId: $pairId, ')
          ..write('bodyAnchor: $bodyAnchor, ')
          ..write('enabled: $enabled, ')
          ..write('position: $position, ')
          ..write('builtIn: $builtIn, ')
          ..write('archived: $archived, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementEntriesTable extends MeasurementEntries
    with TableInfo<$MeasurementEntriesTable, MeasurementEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, note, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MeasurementEntriesTable createAlias(String alias) {
    return $MeasurementEntriesTable(attachedDatabase, alias);
  }
}

class MeasurementEntryRow extends DataClass
    implements Insertable<MeasurementEntryRow> {
  final String id;
  final DateTime date;
  final String? note;
  final DateTime updatedAt;
  const MeasurementEntryRow({
    required this.id,
    required this.date,
    this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MeasurementEntriesCompanion toCompanion(bool nullToAbsent) {
    return MeasurementEntriesCompanion(
      id: Value(id),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory MeasurementEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementEntryRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MeasurementEntryRow copyWith({
    String? id,
    DateTime? date,
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
  }) => MeasurementEntryRow(
    id: id ?? this.id,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MeasurementEntryRow copyWithCompanion(MeasurementEntriesCompanion data) {
    return MeasurementEntryRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementEntryRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, note, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementEntryRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class MeasurementEntriesCompanion extends UpdateCompanion<MeasurementEntryRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MeasurementEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementEntriesCompanion.insert({
    required String id,
    required DateTime date,
    this.note = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       updatedAt = Value(updatedAt);
  static Insertable<MeasurementEntryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MeasurementEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementValuesTable extends MeasurementValues
    with TableInfo<$MeasurementValuesTable, MeasurementValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurement_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fieldIdMeta = const VerificationMeta(
    'fieldId',
  );
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
    'field_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, fieldId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(
        _fieldIdMeta,
        fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, fieldId};
  @override
  MeasurementValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementValueRow(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      fieldId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MeasurementValuesTable createAlias(String alias) {
    return $MeasurementValuesTable(attachedDatabase, alias);
  }
}

class MeasurementValueRow extends DataClass
    implements Insertable<MeasurementValueRow> {
  final String entryId;
  final String fieldId;
  final double value;
  const MeasurementValueRow({
    required this.entryId,
    required this.fieldId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['field_id'] = Variable<String>(fieldId);
    map['value'] = Variable<double>(value);
    return map;
  }

  MeasurementValuesCompanion toCompanion(bool nullToAbsent) {
    return MeasurementValuesCompanion(
      entryId: Value(entryId),
      fieldId: Value(fieldId),
      value: Value(value),
    );
  }

  factory MeasurementValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementValueRow(
      entryId: serializer.fromJson<String>(json['entryId']),
      fieldId: serializer.fromJson<String>(json['fieldId']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'fieldId': serializer.toJson<String>(fieldId),
      'value': serializer.toJson<double>(value),
    };
  }

  MeasurementValueRow copyWith({
    String? entryId,
    String? fieldId,
    double? value,
  }) => MeasurementValueRow(
    entryId: entryId ?? this.entryId,
    fieldId: fieldId ?? this.fieldId,
    value: value ?? this.value,
  );
  MeasurementValueRow copyWithCompanion(MeasurementValuesCompanion data) {
    return MeasurementValueRow(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementValueRow(')
          ..write('entryId: $entryId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, fieldId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementValueRow &&
          other.entryId == this.entryId &&
          other.fieldId == this.fieldId &&
          other.value == this.value);
}

class MeasurementValuesCompanion extends UpdateCompanion<MeasurementValueRow> {
  final Value<String> entryId;
  final Value<String> fieldId;
  final Value<double> value;
  final Value<int> rowid;
  const MeasurementValuesCompanion({
    this.entryId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementValuesCompanion.insert({
    required String entryId,
    required String fieldId,
    required double value,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       fieldId = Value(fieldId),
       value = Value(value);
  static Insertable<MeasurementValueRow> custom({
    Expression<String>? entryId,
    Expression<String>? fieldId,
    Expression<double>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (fieldId != null) 'field_id': fieldId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementValuesCompanion copyWith({
    Value<String>? entryId,
    Value<String>? fieldId,
    Value<double>? value,
    Value<int>? rowid,
  }) {
    return MeasurementValuesCompanion(
      entryId: entryId ?? this.entryId,
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementValuesCompanion(')
          ..write('entryId: $entryId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerPresetsTable extends TimerPresets
    with TableInfo<$TimerPresetsTable, TimerPresetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TimerMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TimerMode>($TimerPresetsTable.$convertermode);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta(
    'builtIn',
  );
  @override
  late final GeneratedColumn<bool> builtIn = GeneratedColumn<bool>(
    'built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    mode,
    payload,
    position,
    builtIn,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerPresetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('built_in')) {
      context.handle(
        _builtInMeta,
        builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerPresetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerPresetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mode: $TimerPresetsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      builtIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}built_in'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TimerPresetsTable createAlias(String alias) {
    return $TimerPresetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TimerMode, String, String> $convertermode =
      const EnumNameConverter<TimerMode>(TimerMode.values);
}

class TimerPresetRow extends DataClass implements Insertable<TimerPresetRow> {
  final String id;
  final String name;
  final TimerMode mode;
  final String payload;
  final int position;
  final bool builtIn;
  final DateTime updatedAt;
  const TimerPresetRow({
    required this.id,
    required this.name,
    required this.mode,
    required this.payload,
    required this.position,
    required this.builtIn,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['mode'] = Variable<String>(
        $TimerPresetsTable.$convertermode.toSql(mode),
      );
    }
    map['payload'] = Variable<String>(payload);
    map['position'] = Variable<int>(position);
    map['built_in'] = Variable<bool>(builtIn);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TimerPresetsCompanion toCompanion(bool nullToAbsent) {
    return TimerPresetsCompanion(
      id: Value(id),
      name: Value(name),
      mode: Value(mode),
      payload: Value(payload),
      position: Value(position),
      builtIn: Value(builtIn),
      updatedAt: Value(updatedAt),
    );
  }

  factory TimerPresetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerPresetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mode: $TimerPresetsTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      payload: serializer.fromJson<String>(json['payload']),
      position: serializer.fromJson<int>(json['position']),
      builtIn: serializer.fromJson<bool>(json['builtIn']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'mode': serializer.toJson<String>(
        $TimerPresetsTable.$convertermode.toJson(mode),
      ),
      'payload': serializer.toJson<String>(payload),
      'position': serializer.toJson<int>(position),
      'builtIn': serializer.toJson<bool>(builtIn),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TimerPresetRow copyWith({
    String? id,
    String? name,
    TimerMode? mode,
    String? payload,
    int? position,
    bool? builtIn,
    DateTime? updatedAt,
  }) => TimerPresetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    mode: mode ?? this.mode,
    payload: payload ?? this.payload,
    position: position ?? this.position,
    builtIn: builtIn ?? this.builtIn,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TimerPresetRow copyWithCompanion(TimerPresetsCompanion data) {
    return TimerPresetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mode: data.mode.present ? data.mode.value : this.mode,
      payload: data.payload.present ? data.payload.value : this.payload,
      position: data.position.present ? data.position.value : this.position,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerPresetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mode: $mode, ')
          ..write('payload: $payload, ')
          ..write('position: $position, ')
          ..write('builtIn: $builtIn, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, mode, payload, position, builtIn, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerPresetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.mode == this.mode &&
          other.payload == this.payload &&
          other.position == this.position &&
          other.builtIn == this.builtIn &&
          other.updatedAt == this.updatedAt);
}

class TimerPresetsCompanion extends UpdateCompanion<TimerPresetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<TimerMode> mode;
  final Value<String> payload;
  final Value<int> position;
  final Value<bool> builtIn;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TimerPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mode = const Value.absent(),
    this.payload = const Value.absent(),
    this.position = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimerPresetsCompanion.insert({
    required String id,
    required String name,
    required TimerMode mode,
    required String payload,
    this.position = const Value.absent(),
    this.builtIn = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       mode = Value(mode),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<TimerPresetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mode,
    Expression<String>? payload,
    Expression<int>? position,
    Expression<bool>? builtIn,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mode != null) 'mode': mode,
      if (payload != null) 'payload': payload,
      if (position != null) 'position': position,
      if (builtIn != null) 'built_in': builtIn,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimerPresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<TimerMode>? mode,
    Value<String>? payload,
    Value<int>? position,
    Value<bool>? builtIn,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TimerPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      payload: payload ?? this.payload,
      position: position ?? this.position,
      builtIn: builtIn ?? this.builtIn,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $TimerPresetsTable.$convertermode.toSql(mode.value),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<bool>(builtIn.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mode: $mode, ')
          ..write('payload: $payload, ')
          ..write('position: $position, ')
          ..write('builtIn: $builtIn, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlateInventoriesTable extends PlateInventories
    with TableInfo<$PlateInventoriesTable, PlateInventoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlateInventoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plate_inventories';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlateInventoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlateInventoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlateInventoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlateInventoriesTable createAlias(String alias) {
    return $PlateInventoriesTable(attachedDatabase, alias);
  }
}

class PlateInventoryRow extends DataClass
    implements Insertable<PlateInventoryRow> {
  final String id;
  final String payload;
  final DateTime updatedAt;
  const PlateInventoryRow({
    required this.id,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlateInventoriesCompanion toCompanion(bool nullToAbsent) {
    return PlateInventoriesCompanion(
      id: Value(id),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlateInventoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlateInventoryRow(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlateInventoryRow copyWith({
    String? id,
    String? payload,
    DateTime? updatedAt,
  }) => PlateInventoryRow(
    id: id ?? this.id,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlateInventoryRow copyWithCompanion(PlateInventoriesCompanion data) {
    return PlateInventoryRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlateInventoryRow(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlateInventoryRow &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class PlateInventoriesCompanion extends UpdateCompanion<PlateInventoryRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlateInventoriesCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlateInventoriesCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<PlateInventoryRow> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlateInventoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlateInventoriesCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlateInventoriesCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RuntimeStatesTable extends RuntimeStates
    with TableInfo<$RuntimeStatesTable, RuntimeStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuntimeStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runtime_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<RuntimeStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  RuntimeStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuntimeStateRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RuntimeStatesTable createAlias(String alias) {
    return $RuntimeStatesTable(attachedDatabase, alias);
  }
}

class RuntimeStateRow extends DataClass implements Insertable<RuntimeStateRow> {
  final String key;
  final String payload;
  final DateTime updatedAt;
  const RuntimeStateRow({
    required this.key,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RuntimeStatesCompanion toCompanion(bool nullToAbsent) {
    return RuntimeStatesCompanion(
      key: Value(key),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory RuntimeStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuntimeStateRow(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RuntimeStateRow copyWith({
    String? key,
    String? payload,
    DateTime? updatedAt,
  }) => RuntimeStateRow(
    key: key ?? this.key,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RuntimeStateRow copyWithCompanion(RuntimeStatesCompanion data) {
    return RuntimeStateRow(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuntimeStateRow(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuntimeStateRow &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class RuntimeStatesCompanion extends UpdateCompanion<RuntimeStateRow> {
  final Value<String> key;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RuntimeStatesCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RuntimeStatesCompanion.insert({
    required String key,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<RuntimeStateRow> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RuntimeStatesCompanion copyWith({
    Value<String>? key,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RuntimeStatesCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuntimeStatesCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $CustomExercisesTable customExercises = $CustomExercisesTable(
    this,
  );
  late final $ExerciseTombstonesTable exerciseTombstones =
      $ExerciseTombstonesTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineItemsTable routineItems = $RoutineItemsTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $SessionExercisesTable sessionExercises = $SessionExercisesTable(
    this,
  );
  late final $SetEntriesTable setEntries = $SetEntriesTable(this);
  late final $MeasurementFieldsTable measurementFields =
      $MeasurementFieldsTable(this);
  late final $MeasurementEntriesTable measurementEntries =
      $MeasurementEntriesTable(this);
  late final $MeasurementValuesTable measurementValues =
      $MeasurementValuesTable(this);
  late final $TimerPresetsTable timerPresets = $TimerPresetsTable(this);
  late final $PlateInventoriesTable plateInventories = $PlateInventoriesTable(
    this,
  );
  late final $RuntimeStatesTable runtimeStates = $RuntimeStatesTable(this);
  late final Index routineItemsRoutine = Index(
    'routine_items_routine',
    'CREATE INDEX routine_items_routine ON routine_items (routine_id)',
  );
  late final Index workoutSessionsStarted = Index(
    'workout_sessions_started',
    'CREATE INDEX workout_sessions_started ON workout_sessions (started_at)',
  );
  late final Index sessionExercisesSession = Index(
    'session_exercises_session',
    'CREATE INDEX session_exercises_session ON session_exercises (session_id)',
  );
  late final Index sessionExercisesExercise = Index(
    'session_exercises_exercise',
    'CREATE INDEX session_exercises_exercise ON session_exercises (exercise_id)',
  );
  late final Index setEntriesSessionExercise = Index(
    'set_entries_session_exercise',
    'CREATE INDEX set_entries_session_exercise ON set_entries (session_exercise_id)',
  );
  late final Index measurementEntriesDate = Index(
    'measurement_entries_date',
    'CREATE INDEX measurement_entries_date ON measurement_entries (date)',
  );
  late final Index measurementValuesField = Index(
    'measurement_values_field',
    'CREATE INDEX measurement_values_field ON measurement_values (field_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    customExercises,
    exerciseTombstones,
    routines,
    routineItems,
    workoutSessions,
    sessionExercises,
    setEntries,
    measurementFields,
    measurementEntries,
    measurementValues,
    timerPresets,
    plateInventories,
    runtimeStates,
    routineItemsRoutine,
    workoutSessionsStarted,
    sessionExercisesSession,
    sessionExercisesExercise,
    setEntriesSessionExercise,
    measurementEntriesDate,
    measurementValuesField,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session_exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('set_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'measurement_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('measurement_values', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<Sex?> sex,
  Value<int?> birthYear,
  Value<double?> heightCm,
  Value<ActivityLevel> activityLevel,
  Value<WeightUnit> weightUnit,
  Value<LengthUnit> lengthUnit,
  Value<DistanceUnit> distanceUnit,
  Value<BmiCutoffs> bmiCutoffs,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<Sex?> sex,
  Value<int?> birthYear,
  Value<double?> heightCm,
  Value<ActivityLevel> activityLevel,
  Value<WeightUnit> weightUnit,
  Value<LengthUnit> lengthUnit,
  Value<DistanceUnit> distanceUnit,
  Value<BmiCutoffs> bmiCutoffs,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$UserDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Sex?, Sex, String> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityLevel, ActivityLevel, String>
  get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, String>
  get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LengthUnit, LengthUnit, String>
  get lengthUnit => $composableBuilder(
    column: $table.lengthUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DistanceUnit, DistanceUnit, String>
  get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<BmiCutoffs, BmiCutoffs, String>
  get bmiCutoffs => $composableBuilder(
    column: $table.bmiCutoffs,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$UserDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lengthUnit => $composableBuilder(
    column: $table.lengthUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bmiCutoffs => $composableBuilder(
    column: $table.bmiCutoffs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$UserDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sex?, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityLevel, String> get activityLevel =>
      $composableBuilder(
        column: $table.activityLevel,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<WeightUnit, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<LengthUnit, String> get lengthUnit =>
      $composableBuilder(
        column: $table.lengthUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DistanceUnit, String> get distanceUnit =>
      $composableBuilder(
        column: $table.distanceUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<BmiCutoffs, String> get bmiCutoffs =>
      $composableBuilder(
        column: $table.bmiCutoffs,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$UserDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$UserDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Sex?> sex = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<ActivityLevel> activityLevel = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<LengthUnit> lengthUnit = const Value.absent(),
                Value<DistanceUnit> distanceUnit = const Value.absent(),
                Value<BmiCutoffs> bmiCutoffs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                activityLevel: activityLevel,
                weightUnit: weightUnit,
                lengthUnit: lengthUnit,
                distanceUnit: distanceUnit,
                bmiCutoffs: bmiCutoffs,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Sex?> sex = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<ActivityLevel> activityLevel = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<LengthUnit> lengthUnit = const Value.absent(),
                Value<DistanceUnit> distanceUnit = const Value.absent(),
                Value<BmiCutoffs> bmiCutoffs = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                activityLevel: activityLevel,
                weightUnit: weightUnit,
                lengthUnit: lengthUnit,
                distanceUnit: distanceUnit,
                bmiCutoffs: bmiCutoffs,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  BaseReferences<_$UserDatabase, $ProfilesTable, ProfileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$UserDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$CustomExercisesTableCreateCompanionBuilder =
    CustomExercisesCompanion Function({
      required String id,
      required String name,
      Value<List<String>> aliases,
      Value<String?> sanskritName,
      required String category,
      Value<String?> subcategory,
      required TrackingType trackingType,
      Value<List<String>> primaryMuscles,
      Value<List<String>> secondaryMuscles,
      Value<List<String>> equipment,
      Value<Difficulty?> difficulty,
      Value<bool> unilateral,
      Value<String?> mechanic,
      Value<String?> force,
      Value<List<String>> steps,
      Value<List<String>> tips,
      Value<List<String>> commonMistakes,
      Value<List<String>> safetyNotes,
      Value<List<String>> contraindications,
      Value<double?> metValue,
      Value<int?> defaultRestSec,
      Value<int?> defaultHoldSec,
      Value<String?> variationOf,
      Value<List<String>> tags,
      Value<bool> archived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CustomExercisesTableUpdateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<List<String>> aliases,
      Value<String?> sanskritName,
      Value<String> category,
      Value<String?> subcategory,
      Value<TrackingType> trackingType,
      Value<List<String>> primaryMuscles,
      Value<List<String>> secondaryMuscles,
      Value<List<String>> equipment,
      Value<Difficulty?> difficulty,
      Value<bool> unilateral,
      Value<String?> mechanic,
      Value<String?> force,
      Value<List<String>> steps,
      Value<List<String>> tips,
      Value<List<String>> commonMistakes,
      Value<List<String>> safetyNotes,
      Value<List<String>> contraindications,
      Value<double?> metValue,
      Value<int?> defaultRestSec,
      Value<int?> defaultHoldSec,
      Value<String?> variationOf,
      Value<List<String>> tags,
      Value<bool> archived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CustomExercisesTableFilterComposer
    extends Composer<_$UserDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get sanskritName => $composableBuilder(
    column: $table.sanskritName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TrackingType, TrackingType, String>
  get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Difficulty?, Difficulty, String>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get unilateral => $composableBuilder(
    column: $table.unilateral,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tips =>
      $composableBuilder(
        column: $table.tips,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get commonMistakes => $composableBuilder(
    column: $table.commonMistakes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get safetyNotes => $composableBuilder(
    column: $table.safetyNotes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get contraindications => $composableBuilder(
    column: $table.contraindications,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get metValue => $composableBuilder(
    column: $table.metValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultRestSec => $composableBuilder(
    column: $table.defaultRestSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultHoldSec => $composableBuilder(
    column: $table.defaultHoldSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variationOf => $composableBuilder(
    column: $table.variationOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomExercisesTableOrderingComposer
    extends Composer<_$UserDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanskritName => $composableBuilder(
    column: $table.sanskritName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get unilateral => $composableBuilder(
    column: $table.unilateral,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tips => $composableBuilder(
    column: $table.tips,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonMistakes => $composableBuilder(
    column: $table.commonMistakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyNotes => $composableBuilder(
    column: $table.safetyNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contraindications => $composableBuilder(
    column: $table.contraindications,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get metValue => $composableBuilder(
    column: $table.metValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultRestSec => $composableBuilder(
    column: $table.defaultRestSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultHoldSec => $composableBuilder(
    column: $table.defaultHoldSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variationOf => $composableBuilder(
    column: $table.variationOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomExercisesTableAnnotationComposer
    extends Composer<_$UserDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get sanskritName => $composableBuilder(
    column: $table.sanskritName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TrackingType, String> get trackingType =>
      $composableBuilder(
        column: $table.trackingType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get primaryMuscles =>
      $composableBuilder(
        column: $table.primaryMuscles,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get secondaryMuscles =>
      $composableBuilder(
        column: $table.secondaryMuscles,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Difficulty?, String> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get unilateral => $composableBuilder(
    column: $table.unilateral,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mechanic =>
      $composableBuilder(column: $table.mechanic, builder: (column) => column);

  GeneratedColumn<String> get force =>
      $composableBuilder(column: $table.force, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tips =>
      $composableBuilder(column: $table.tips, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get commonMistakes =>
      $composableBuilder(
        column: $table.commonMistakes,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get safetyNotes =>
      $composableBuilder(
        column: $table.safetyNotes,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String>
  get contraindications => $composableBuilder(
    column: $table.contraindications,
    builder: (column) => column,
  );

  GeneratedColumn<double> get metValue =>
      $composableBuilder(column: $table.metValue, builder: (column) => column);

  GeneratedColumn<int> get defaultRestSec => $composableBuilder(
    column: $table.defaultRestSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultHoldSec => $composableBuilder(
    column: $table.defaultHoldSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get variationOf => $composableBuilder(
    column: $table.variationOf,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CustomExercisesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $CustomExercisesTable,
          CustomExerciseRow,
          $$CustomExercisesTableFilterComposer,
          $$CustomExercisesTableOrderingComposer,
          $$CustomExercisesTableAnnotationComposer,
          $$CustomExercisesTableCreateCompanionBuilder,
          $$CustomExercisesTableUpdateCompanionBuilder,
          (
            CustomExerciseRow,
            BaseReferences<
              _$UserDatabase,
              $CustomExercisesTable,
              CustomExerciseRow
            >,
          ),
          CustomExerciseRow,
          PrefetchHooks Function()
        > {
  $$CustomExercisesTableTableManager(
    _$UserDatabase db,
    $CustomExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<List<String>> aliases = const Value.absent(),
                Value<String?> sanskritName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<TrackingType> trackingType = const Value.absent(),
                Value<List<String>> primaryMuscles = const Value.absent(),
                Value<List<String>> secondaryMuscles = const Value.absent(),
                Value<List<String>> equipment = const Value.absent(),
                Value<Difficulty?> difficulty = const Value.absent(),
                Value<bool> unilateral = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<List<String>> steps = const Value.absent(),
                Value<List<String>> tips = const Value.absent(),
                Value<List<String>> commonMistakes = const Value.absent(),
                Value<List<String>> safetyNotes = const Value.absent(),
                Value<List<String>> contraindications = const Value.absent(),
                Value<double?> metValue = const Value.absent(),
                Value<int?> defaultRestSec = const Value.absent(),
                Value<int?> defaultHoldSec = const Value.absent(),
                Value<String?> variationOf = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion(
                id: id,
                name: name,
                aliases: aliases,
                sanskritName: sanskritName,
                category: category,
                subcategory: subcategory,
                trackingType: trackingType,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                equipment: equipment,
                difficulty: difficulty,
                unilateral: unilateral,
                mechanic: mechanic,
                force: force,
                steps: steps,
                tips: tips,
                commonMistakes: commonMistakes,
                safetyNotes: safetyNotes,
                contraindications: contraindications,
                metValue: metValue,
                defaultRestSec: defaultRestSec,
                defaultHoldSec: defaultHoldSec,
                variationOf: variationOf,
                tags: tags,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<List<String>> aliases = const Value.absent(),
                Value<String?> sanskritName = const Value.absent(),
                required String category,
                Value<String?> subcategory = const Value.absent(),
                required TrackingType trackingType,
                Value<List<String>> primaryMuscles = const Value.absent(),
                Value<List<String>> secondaryMuscles = const Value.absent(),
                Value<List<String>> equipment = const Value.absent(),
                Value<Difficulty?> difficulty = const Value.absent(),
                Value<bool> unilateral = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<List<String>> steps = const Value.absent(),
                Value<List<String>> tips = const Value.absent(),
                Value<List<String>> commonMistakes = const Value.absent(),
                Value<List<String>> safetyNotes = const Value.absent(),
                Value<List<String>> contraindications = const Value.absent(),
                Value<double?> metValue = const Value.absent(),
                Value<int?> defaultRestSec = const Value.absent(),
                Value<int?> defaultHoldSec = const Value.absent(),
                Value<String?> variationOf = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion.insert(
                id: id,
                name: name,
                aliases: aliases,
                sanskritName: sanskritName,
                category: category,
                subcategory: subcategory,
                trackingType: trackingType,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                equipment: equipment,
                difficulty: difficulty,
                unilateral: unilateral,
                mechanic: mechanic,
                force: force,
                steps: steps,
                tips: tips,
                commonMistakes: commonMistakes,
                safetyNotes: safetyNotes,
                contraindications: contraindications,
                metValue: metValue,
                defaultRestSec: defaultRestSec,
                defaultHoldSec: defaultHoldSec,
                variationOf: variationOf,
                tags: tags,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomExercisesTable, CustomExerciseRow>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $CustomExercisesTable,
                    CustomExerciseRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $CustomExercisesTable,
      CustomExerciseRow,
      $$CustomExercisesTableFilterComposer,
      $$CustomExercisesTableOrderingComposer,
      $$CustomExercisesTableAnnotationComposer,
      $$CustomExercisesTableCreateCompanionBuilder,
      $$CustomExercisesTableUpdateCompanionBuilder,
      (
        CustomExerciseRow,
        BaseReferences<
          _$UserDatabase,
          $CustomExercisesTable,
          CustomExerciseRow
        >,
      ),
      CustomExerciseRow,
      PrefetchHooks Function()
    >;
typedef $$ExerciseTombstonesTableCreateCompanionBuilder =
    ExerciseTombstonesCompanion Function({
      required String exerciseId,
      required String name,
      required TrackingType trackingType,
      required String removedInLibraryVersion,
      Value<int> rowid,
    });
typedef $$ExerciseTombstonesTableUpdateCompanionBuilder =
    ExerciseTombstonesCompanion Function({
      Value<String> exerciseId,
      Value<String> name,
      Value<TrackingType> trackingType,
      Value<String> removedInLibraryVersion,
      Value<int> rowid,
    });

class $$ExerciseTombstonesTableFilterComposer
    extends Composer<_$UserDatabase, $ExerciseTombstonesTable> {
  $$ExerciseTombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TrackingType, TrackingType, String>
  get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get removedInLibraryVersion => $composableBuilder(
    column: $table.removedInLibraryVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseTombstonesTableOrderingComposer
    extends Composer<_$UserDatabase, $ExerciseTombstonesTable> {
  $$ExerciseTombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get removedInLibraryVersion => $composableBuilder(
    column: $table.removedInLibraryVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseTombstonesTableAnnotationComposer
    extends Composer<_$UserDatabase, $ExerciseTombstonesTable> {
  $$ExerciseTombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TrackingType, String> get trackingType =>
      $composableBuilder(
        column: $table.trackingType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get removedInLibraryVersion => $composableBuilder(
    column: $table.removedInLibraryVersion,
    builder: (column) => column,
  );
}

class $$ExerciseTombstonesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $ExerciseTombstonesTable,
          ExerciseTombstoneRow,
          $$ExerciseTombstonesTableFilterComposer,
          $$ExerciseTombstonesTableOrderingComposer,
          $$ExerciseTombstonesTableAnnotationComposer,
          $$ExerciseTombstonesTableCreateCompanionBuilder,
          $$ExerciseTombstonesTableUpdateCompanionBuilder,
          (
            ExerciseTombstoneRow,
            BaseReferences<
              _$UserDatabase,
              $ExerciseTombstonesTable,
              ExerciseTombstoneRow
            >,
          ),
          ExerciseTombstoneRow,
          PrefetchHooks Function()
        > {
  $$ExerciseTombstonesTableTableManager(
    _$UserDatabase db,
    $ExerciseTombstonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseTombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseTombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseTombstonesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<TrackingType> trackingType = const Value.absent(),
                Value<String> removedInLibraryVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTombstonesCompanion(
                exerciseId: exerciseId,
                name: name,
                trackingType: trackingType,
                removedInLibraryVersion: removedInLibraryVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String name,
                required TrackingType trackingType,
                required String removedInLibraryVersion,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTombstonesCompanion.insert(
                exerciseId: exerciseId,
                name: name,
                trackingType: trackingType,
                removedInLibraryVersion: removedInLibraryVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseTombstonesTable, ExerciseTombstoneRow>(
                    table,
                  ),
                  BaseReferences<
                    _$UserDatabase,
                    $ExerciseTombstonesTable,
                    ExerciseTombstoneRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseTombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $ExerciseTombstonesTable,
      ExerciseTombstoneRow,
      $$ExerciseTombstonesTableFilterComposer,
      $$ExerciseTombstonesTableOrderingComposer,
      $$ExerciseTombstonesTableAnnotationComposer,
      $$ExerciseTombstonesTableCreateCompanionBuilder,
      $$ExerciseTombstonesTableUpdateCompanionBuilder,
      (
        ExerciseTombstoneRow,
        BaseReferences<
          _$UserDatabase,
          $ExerciseTombstonesTable,
          ExerciseTombstoneRow
        >,
      ),
      ExerciseTombstoneRow,
      PrefetchHooks Function()
    >;
typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  required String id,
  required String name,
  Value<String?> notes,
  Value<int> position,
  Value<bool> archived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> notes,
  Value<int> position,
  Value<bool> archived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$RoutinesTableReferences
    extends BaseReferences<_$UserDatabase, $RoutinesTable, RoutineRow> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineItemsTable, List<RoutineItemRow>>
  _routineItemsRefsTable(_$UserDatabase db) => MultiTypedResultKey.fromTable(
    db.routineItems,
    aliasName: 'routines__id__routine_items__routine_id',
  );

  $$RoutineItemsTableProcessedTableManager get routineItemsRefs {
    final manager = $$RoutineItemsTableTableManager(
      $_db,
      $_db.routineItems,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$UserDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineItemsRefs(
    Expression<bool> Function($$RoutineItemsTableFilterComposer f) f,
  ) {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$UserDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$UserDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> routineItemsRefs<T extends Object>(
    Expression<T> Function($$RoutineItemsTableAnnotationComposer a) f,
  ) {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $RoutinesTable,
          RoutineRow,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (RoutineRow, $$RoutinesTableReferences),
          RoutineRow,
          PrefetchHooks Function({bool routineItemsRefs})
        > {
  $$RoutinesTableTableManager(_$UserDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                name: name,
                notes: notes,
                position: position,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> notes = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                name: name,
                notes: notes,
                position: position,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTable, RoutineRow>(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineItemsRefs) db.routineItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      RoutineRow,
                      $RoutinesTable,
                      RoutineItemRow,
                      $RoutineItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RoutinesTableReferences
                          ._routineItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoutinesTableReferences(
                        db,
                        table,
                        p0,
                      ).routineItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'routine_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $RoutinesTable,
      RoutineRow,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (RoutineRow, $$RoutinesTableReferences),
      RoutineRow,
      PrefetchHooks Function({bool routineItemsRefs})
    >;
typedef $$RoutineItemsTableCreateCompanionBuilder =
    RoutineItemsCompanion Function({
      required String id,
      required String routineId,
      required String exerciseId,
      required int position,
      Value<int?> supersetGroup,
      Value<int> targetSets,
      Value<int?> targetReps,
      Value<int?> targetDurationSec,
      Value<double?> targetDistanceM,
      Value<double?> targetWeightKg,
      Value<int?> restSec,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$RoutineItemsTableUpdateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<String> exerciseId,
      Value<int> position,
      Value<int?> supersetGroup,
      Value<int> targetSets,
      Value<int?> targetReps,
      Value<int?> targetDurationSec,
      Value<double?> targetDistanceM,
      Value<double?> targetWeightKg,
      Value<int?> restSec,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$RoutineItemsTableReferences
    extends BaseReferences<_$UserDatabase, $RoutineItemsTable, RoutineItemRow> {
  $$RoutineItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$UserDatabase db) =>
      db.routines.createAlias('routine_items__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineItemsTableFilterComposer
    extends Composer<_$UserDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDurationSec => $composableBuilder(
    column: $table.targetDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSec => $composableBuilder(
    column: $table.restSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableOrderingComposer
    extends Composer<_$UserDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDurationSec => $composableBuilder(
    column: $table.targetDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSec => $composableBuilder(
    column: $table.restSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableAnnotationComposer
    extends Composer<_$UserDatabase, $RoutineItemsTable> {
  $$RoutineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetDurationSec => $composableBuilder(
    column: $table.targetDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSec =>
      $composableBuilder(column: $table.restSec, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineItemsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $RoutineItemsTable,
          RoutineItemRow,
          $$RoutineItemsTableFilterComposer,
          $$RoutineItemsTableOrderingComposer,
          $$RoutineItemsTableAnnotationComposer,
          $$RoutineItemsTableCreateCompanionBuilder,
          $$RoutineItemsTableUpdateCompanionBuilder,
          (RoutineItemRow, $$RoutineItemsTableReferences),
          RoutineItemRow,
          PrefetchHooks Function({bool routineId})
        > {
  $$RoutineItemsTableTableManager(_$UserDatabase db, $RoutineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<int?> targetDurationSec = const Value.absent(),
                Value<double?> targetDistanceM = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<int?> restSec = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineItemsCompanion(
                id: id,
                routineId: routineId,
                exerciseId: exerciseId,
                position: position,
                supersetGroup: supersetGroup,
                targetSets: targetSets,
                targetReps: targetReps,
                targetDurationSec: targetDurationSec,
                targetDistanceM: targetDistanceM,
                targetWeightKg: targetWeightKg,
                restSec: restSec,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String routineId,
                required String exerciseId,
                required int position,
                Value<int?> supersetGroup = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<int?> targetDurationSec = const Value.absent(),
                Value<double?> targetDistanceM = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<int?> restSec = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineItemsCompanion.insert(
                id: id,
                routineId: routineId,
                exerciseId: exerciseId,
                position: position,
                supersetGroup: supersetGroup,
                targetSets: targetSets,
                targetReps: targetReps,
                targetDurationSec: targetDurationSec,
                targetDistanceM: targetDistanceM,
                targetWeightKg: targetWeightKg,
                restSec: restSec,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineItemsTable, RoutineItemRow>(table),
                  $$RoutineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineId,
                        referencedTable: $$RoutineItemsTableReferences
                            ._routineIdTable(db),
                        referencedColumn: $$RoutineItemsTableReferences
                            ._routineIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $RoutineItemsTable,
      RoutineItemRow,
      $$RoutineItemsTableFilterComposer,
      $$RoutineItemsTableOrderingComposer,
      $$RoutineItemsTableAnnotationComposer,
      $$RoutineItemsTableCreateCompanionBuilder,
      $$RoutineItemsTableUpdateCompanionBuilder,
      (RoutineItemRow, $$RoutineItemsTableReferences),
      RoutineItemRow,
      PrefetchHooks Function({bool routineId})
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      required String id,
      Value<String?> name,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String?> routineId,
      Value<String?> notes,
      Value<int?> perceivedEffort,
      Value<SessionSource> source,
      Value<int?> durationSec,
      Value<double?> volumeKg,
      Value<double?> caloriesKcal,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> routineId,
      Value<String?> notes,
      Value<int?> perceivedEffort,
      Value<SessionSource> source,
      Value<int?> durationSec,
      Value<double?> volumeKg,
      Value<double?> caloriesKcal,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<
          _$UserDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow
        > {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExerciseRow>>
  _sessionExercisesRefsTable(_$UserDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionExercises,
        aliasName: 'workout_sessions__id__session_exercises__session_id',
      );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$UserDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perceivedEffort => $composableBuilder(
    column: $table.perceivedEffort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionSource, SessionSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volumeKg => $composableBuilder(
    column: $table.volumeKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionExercisesRefs(
    Expression<bool> Function($$SessionExercisesTableFilterComposer f) f,
  ) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$UserDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perceivedEffort => $composableBuilder(
    column: $table.perceivedEffort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volumeKg => $composableBuilder(
    column: $table.volumeKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$UserDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get perceivedEffort => $composableBuilder(
    column: $table.perceivedEffort,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SessionSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get volumeKg =>
      $composableBuilder(column: $table.volumeKg, builder: (column) => column);

  GeneratedColumn<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSessionRow, $$WorkoutSessionsTableReferences),
          WorkoutSessionRow,
          PrefetchHooks Function({bool sessionExercisesRefs})
        > {
  $$WorkoutSessionsTableTableManager(
    _$UserDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> routineId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> perceivedEffort = const Value.absent(),
                Value<SessionSource> source = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<double?> volumeKg = const Value.absent(),
                Value<double?> caloriesKcal = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                name: name,
                startedAt: startedAt,
                endedAt: endedAt,
                routineId: routineId,
                notes: notes,
                perceivedEffort: perceivedEffort,
                source: source,
                durationSec: durationSec,
                volumeKg: volumeKg,
                caloriesKcal: caloriesKcal,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> routineId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> perceivedEffort = const Value.absent(),
                Value<SessionSource> source = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<double?> volumeKg = const Value.absent(),
                Value<double?> caloriesKcal = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                name: name,
                startedAt: startedAt,
                endedAt: endedAt,
                routineId: routineId,
                notes: notes,
                perceivedEffort: perceivedEffort,
                source: source,
                durationSec: durationSec,
                volumeKg: volumeKg,
                caloriesKcal: caloriesKcal,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSessionRow>(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionExercisesRefs) db.sessionExercises,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionExercisesRefs)
                    await $_getPrefetchedDataByColumns<
                      WorkoutSessionRow,
                      $WorkoutSessionsTable,
                      SessionExerciseRow,
                      $SessionExercisesTable
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences
                          ._sessionExercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionExercisesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $WorkoutSessionsTable,
      WorkoutSessionRow,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSessionRow, $$WorkoutSessionsTableReferences),
      WorkoutSessionRow,
      PrefetchHooks Function({bool sessionExercisesRefs})
    >;
typedef $$SessionExercisesTableCreateCompanionBuilder =
    SessionExercisesCompanion Function({
      required String id,
      required String sessionId,
      required String exerciseId,
      required int position,
      Value<int?> supersetGroup,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$SessionExercisesTableUpdateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> exerciseId,
      Value<int> position,
      Value<int?> supersetGroup,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$SessionExercisesTableReferences
    extends
        BaseReferences<
          _$UserDatabase,
          $SessionExercisesTable,
          SessionExerciseRow
        > {
  $$SessionExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionsTable _sessionIdTable(_$UserDatabase db) => db
      .workoutSessions
      .createAlias('session_exercises__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SetEntriesTable, List<SetEntryRow>>
  _setEntriesRefsTable(_$UserDatabase db) => MultiTypedResultKey.fromTable(
    db.setEntries,
    aliasName: 'session_exercises__id__set_entries__session_exercise_id',
  );

  $$SetEntriesTableProcessedTableManager get setEntriesRefs {
    final manager = $$SetEntriesTableTableManager($_db, $_db.setEntries).filter(
      (f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_setEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionExercisesTableFilterComposer
    extends Composer<_$UserDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> setEntriesRefs(
    Expression<bool> Function($$SetEntriesTableFilterComposer f) f,
  ) {
    final $$SetEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setEntries,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetEntriesTableFilterComposer(
            $db: $db,
            $table: $db.setEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionExercisesTableOrderingComposer
    extends Composer<_$UserDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableAnnotationComposer
    extends Composer<_$UserDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> setEntriesRefs<T extends Object>(
    Expression<T> Function($$SetEntriesTableAnnotationComposer a) f,
  ) {
    final $$SetEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setEntries,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.setEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionExercisesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SessionExercisesTable,
          SessionExerciseRow,
          $$SessionExercisesTableFilterComposer,
          $$SessionExercisesTableOrderingComposer,
          $$SessionExercisesTableAnnotationComposer,
          $$SessionExercisesTableCreateCompanionBuilder,
          $$SessionExercisesTableUpdateCompanionBuilder,
          (SessionExerciseRow, $$SessionExercisesTableReferences),
          SessionExerciseRow,
          PrefetchHooks Function({bool sessionId, bool setEntriesRefs})
        > {
  $$SessionExercisesTableTableManager(
    _$UserDatabase db,
    $SessionExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExercisesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                supersetGroup: supersetGroup,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String exerciseId,
                required int position,
                Value<int?> supersetGroup = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                supersetGroup: supersetGroup,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionExercisesTable, SessionExerciseRow>(
                    table,
                  ),
                  $$SessionExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, setEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (setEntriesRefs) db.setEntries],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionExercisesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionExercisesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (setEntriesRefs)
                    await $_getPrefetchedDataByColumns<
                      SessionExerciseRow,
                      $SessionExercisesTable,
                      SetEntryRow,
                      $SetEntriesTable
                    >(
                      currentTable: table,
                      referencedTable: $$SessionExercisesTableReferences
                          ._setEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionExercisesTableReferences(
                            db,
                            table,
                            p0,
                          ).setEntriesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'session_exercise_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SessionExercisesTable,
      SessionExerciseRow,
      $$SessionExercisesTableFilterComposer,
      $$SessionExercisesTableOrderingComposer,
      $$SessionExercisesTableAnnotationComposer,
      $$SessionExercisesTableCreateCompanionBuilder,
      $$SessionExercisesTableUpdateCompanionBuilder,
      (SessionExerciseRow, $$SessionExercisesTableReferences),
      SessionExerciseRow,
      PrefetchHooks Function({bool sessionId, bool setEntriesRefs})
    >;
typedef $$SetEntriesTableCreateCompanionBuilder = SetEntriesCompanion Function({
  required String id,
  required String sessionExerciseId,
  required int position,
  Value<SetType> type,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<int?> durationSec,
  Value<double?> distanceM,
  Value<int?> rounds,
  Value<int?> holdSec,
  Value<bool> completed,
  Value<bool> isWarmup,
  Value<bool> isPr,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$SetEntriesTableUpdateCompanionBuilder = SetEntriesCompanion Function({
  Value<String> id,
  Value<String> sessionExerciseId,
  Value<int> position,
  Value<SetType> type,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<int?> durationSec,
  Value<double?> distanceM,
  Value<int?> rounds,
  Value<int?> holdSec,
  Value<bool> completed,
  Value<bool> isWarmup,
  Value<bool> isPr,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

final class $$SetEntriesTableReferences
    extends BaseReferences<_$UserDatabase, $SetEntriesTable, SetEntryRow> {
  $$SetEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionExercisesTable _sessionExerciseIdTable(_$UserDatabase db) => db
      .sessionExercises
      .createAlias('set_entries__session_exercise_id__session_exercises__id');

  $$SessionExercisesTableProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<String>('session_exercise_id')!;

    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetEntriesTableFilterComposer
    extends Composer<_$UserDatabase, $SetEntriesTable> {
  $$SetEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SetType, SetType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get holdSec => $composableBuilder(
    column: $table.holdSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPr => $composableBuilder(
    column: $table.isPr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionExercisesTableFilterComposer get sessionExerciseId {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableOrderingComposer
    extends Composer<_$UserDatabase, $SetEntriesTable> {
  $$SetEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get holdSec => $composableBuilder(
    column: $table.holdSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPr => $composableBuilder(
    column: $table.isPr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionExercisesTableOrderingComposer get sessionExerciseId {
    final $$SessionExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableAnnotationComposer
    extends Composer<_$UserDatabase, $SetEntriesTable> {
  $$SetEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SetType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get holdSec =>
      $composableBuilder(column: $table.holdSec, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get isWarmup =>
      $composableBuilder(column: $table.isWarmup, builder: (column) => column);

  GeneratedColumn<bool> get isPr =>
      $composableBuilder(column: $table.isPr, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$SessionExercisesTableAnnotationComposer get sessionExerciseId {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetEntriesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SetEntriesTable,
          SetEntryRow,
          $$SetEntriesTableFilterComposer,
          $$SetEntriesTableOrderingComposer,
          $$SetEntriesTableAnnotationComposer,
          $$SetEntriesTableCreateCompanionBuilder,
          $$SetEntriesTableUpdateCompanionBuilder,
          (SetEntryRow, $$SetEntriesTableReferences),
          SetEntryRow,
          PrefetchHooks Function({bool sessionExerciseId})
        > {
  $$SetEntriesTableTableManager(_$UserDatabase db, $SetEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<SetType> type = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<double?> distanceM = const Value.absent(),
                Value<int?> rounds = const Value.absent(),
                Value<int?> holdSec = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<bool> isPr = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetEntriesCompanion(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                type: type,
                weightKg: weightKg,
                reps: reps,
                durationSec: durationSec,
                distanceM: distanceM,
                rounds: rounds,
                holdSec: holdSec,
                completed: completed,
                isWarmup: isWarmup,
                isPr: isPr,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionExerciseId,
                required int position,
                Value<SetType> type = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSec = const Value.absent(),
                Value<double?> distanceM = const Value.absent(),
                Value<int?> rounds = const Value.absent(),
                Value<int?> holdSec = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<bool> isPr = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetEntriesCompanion.insert(
                id: id,
                sessionExerciseId: sessionExerciseId,
                position: position,
                type: type,
                weightKg: weightKg,
                reps: reps,
                durationSec: durationSec,
                distanceM: distanceM,
                rounds: rounds,
                holdSec: holdSec,
                completed: completed,
                isWarmup: isWarmup,
                isPr: isPr,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SetEntriesTable, SetEntryRow>(table),
                  $$SetEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionExerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionExerciseId,
                        referencedTable: $$SetEntriesTableReferences
                            ._sessionExerciseIdTable(db),
                        referencedColumn: $$SetEntriesTableReferences
                            ._sessionExerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SetEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SetEntriesTable,
      SetEntryRow,
      $$SetEntriesTableFilterComposer,
      $$SetEntriesTableOrderingComposer,
      $$SetEntriesTableAnnotationComposer,
      $$SetEntriesTableCreateCompanionBuilder,
      $$SetEntriesTableUpdateCompanionBuilder,
      (SetEntryRow, $$SetEntriesTableReferences),
      SetEntryRow,
      PrefetchHooks Function({bool sessionExerciseId})
    >;
typedef $$MeasurementFieldsTableCreateCompanionBuilder =
    MeasurementFieldsCompanion Function({
      required String id,
      required String name,
      required MeasurementUnitType unitType,
      Value<String?> customUnit,
      Value<BodySide> side,
      Value<String?> pairId,
      Value<BodyAnchor?> bodyAnchor,
      Value<bool> enabled,
      Value<int> position,
      Value<bool> builtIn,
      Value<bool> archived,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MeasurementFieldsTableUpdateCompanionBuilder =
    MeasurementFieldsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<MeasurementUnitType> unitType,
      Value<String?> customUnit,
      Value<BodySide> side,
      Value<String?> pairId,
      Value<BodyAnchor?> bodyAnchor,
      Value<bool> enabled,
      Value<int> position,
      Value<bool> builtIn,
      Value<bool> archived,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MeasurementFieldsTableFilterComposer
    extends Composer<_$UserDatabase, $MeasurementFieldsTable> {
  $$MeasurementFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    MeasurementUnitType,
    MeasurementUnitType,
    String
  >
  get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get customUnit => $composableBuilder(
    column: $table.customUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BodySide, BodySide, String> get side =>
      $composableBuilder(
        column: $table.side,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get pairId => $composableBuilder(
    column: $table.pairId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BodyAnchor?, BodyAnchor, String>
  get bodyAnchor => $composableBuilder(
    column: $table.bodyAnchor,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeasurementFieldsTableOrderingComposer
    extends Composer<_$UserDatabase, $MeasurementFieldsTable> {
  $$MeasurementFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customUnit => $composableBuilder(
    column: $table.customUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pairId => $composableBuilder(
    column: $table.pairId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyAnchor => $composableBuilder(
    column: $table.bodyAnchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementFieldsTableAnnotationComposer
    extends Composer<_$UserDatabase, $MeasurementFieldsTable> {
  $$MeasurementFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MeasurementUnitType, String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<String> get customUnit => $composableBuilder(
    column: $table.customUnit,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BodySide, String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get pairId =>
      $composableBuilder(column: $table.pairId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BodyAnchor?, String> get bodyAnchor =>
      $composableBuilder(
        column: $table.bodyAnchor,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MeasurementFieldsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $MeasurementFieldsTable,
          MeasurementFieldRow,
          $$MeasurementFieldsTableFilterComposer,
          $$MeasurementFieldsTableOrderingComposer,
          $$MeasurementFieldsTableAnnotationComposer,
          $$MeasurementFieldsTableCreateCompanionBuilder,
          $$MeasurementFieldsTableUpdateCompanionBuilder,
          (
            MeasurementFieldRow,
            BaseReferences<
              _$UserDatabase,
              $MeasurementFieldsTable,
              MeasurementFieldRow
            >,
          ),
          MeasurementFieldRow,
          PrefetchHooks Function()
        > {
  $$MeasurementFieldsTableTableManager(
    _$UserDatabase db,
    $MeasurementFieldsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementFieldsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<MeasurementUnitType> unitType = const Value.absent(),
                Value<String?> customUnit = const Value.absent(),
                Value<BodySide> side = const Value.absent(),
                Value<String?> pairId = const Value.absent(),
                Value<BodyAnchor?> bodyAnchor = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementFieldsCompanion(
                id: id,
                name: name,
                unitType: unitType,
                customUnit: customUnit,
                side: side,
                pairId: pairId,
                bodyAnchor: bodyAnchor,
                enabled: enabled,
                position: position,
                builtIn: builtIn,
                archived: archived,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required MeasurementUnitType unitType,
                Value<String?> customUnit = const Value.absent(),
                Value<BodySide> side = const Value.absent(),
                Value<String?> pairId = const Value.absent(),
                Value<BodyAnchor?> bodyAnchor = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementFieldsCompanion.insert(
                id: id,
                name: name,
                unitType: unitType,
                customUnit: customUnit,
                side: side,
                pairId: pairId,
                bodyAnchor: bodyAnchor,
                enabled: enabled,
                position: position,
                builtIn: builtIn,
                archived: archived,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementFieldsTable, MeasurementFieldRow>(
                    table,
                  ),
                  BaseReferences<
                    _$UserDatabase,
                    $MeasurementFieldsTable,
                    MeasurementFieldRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeasurementFieldsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $MeasurementFieldsTable,
      MeasurementFieldRow,
      $$MeasurementFieldsTableFilterComposer,
      $$MeasurementFieldsTableOrderingComposer,
      $$MeasurementFieldsTableAnnotationComposer,
      $$MeasurementFieldsTableCreateCompanionBuilder,
      $$MeasurementFieldsTableUpdateCompanionBuilder,
      (
        MeasurementFieldRow,
        BaseReferences<
          _$UserDatabase,
          $MeasurementFieldsTable,
          MeasurementFieldRow
        >,
      ),
      MeasurementFieldRow,
      PrefetchHooks Function()
    >;
typedef $$MeasurementEntriesTableCreateCompanionBuilder =
    MeasurementEntriesCompanion Function({
      required String id,
      required DateTime date,
      Value<String?> note,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MeasurementEntriesTableUpdateCompanionBuilder =
    MeasurementEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String?> note,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MeasurementEntriesTableReferences
    extends
        BaseReferences<
          _$UserDatabase,
          $MeasurementEntriesTable,
          MeasurementEntryRow
        > {
  $$MeasurementEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MeasurementValuesTable, List<MeasurementValueRow>>
  _measurementValuesRefsTable(_$UserDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementValues,
        aliasName: 'measurement_entries__id__measurement_values__entry_id',
      );

  $$MeasurementValuesTableProcessedTableManager get measurementValuesRefs {
    final manager = $$MeasurementValuesTableTableManager(
      $_db,
      $_db.measurementValues,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementEntriesTableFilterComposer
    extends Composer<_$UserDatabase, $MeasurementEntriesTable> {
  $$MeasurementEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> measurementValuesRefs(
    Expression<bool> Function($$MeasurementValuesTableFilterComposer f) f,
  ) {
    final $$MeasurementValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementValues,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementValuesTableFilterComposer(
            $db: $db,
            $table: $db.measurementValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementEntriesTableOrderingComposer
    extends Composer<_$UserDatabase, $MeasurementEntriesTable> {
  $$MeasurementEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementEntriesTableAnnotationComposer
    extends Composer<_$UserDatabase, $MeasurementEntriesTable> {
  $$MeasurementEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> measurementValuesRefs<T extends Object>(
    Expression<T> Function($$MeasurementValuesTableAnnotationComposer a) f,
  ) {
    final $$MeasurementValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementValues,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MeasurementEntriesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $MeasurementEntriesTable,
          MeasurementEntryRow,
          $$MeasurementEntriesTableFilterComposer,
          $$MeasurementEntriesTableOrderingComposer,
          $$MeasurementEntriesTableAnnotationComposer,
          $$MeasurementEntriesTableCreateCompanionBuilder,
          $$MeasurementEntriesTableUpdateCompanionBuilder,
          (MeasurementEntryRow, $$MeasurementEntriesTableReferences),
          MeasurementEntryRow,
          PrefetchHooks Function({bool measurementValuesRefs})
        > {
  $$MeasurementEntriesTableTableManager(
    _$UserDatabase db,
    $MeasurementEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementEntriesCompanion(
                id: id,
                date: date,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementEntriesCompanion.insert(
                id: id,
                date: date,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementEntriesTable, MeasurementEntryRow>(
                    table,
                  ),
                  $$MeasurementEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementValuesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (measurementValuesRefs) db.measurementValues,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementValuesRefs)
                    await $_getPrefetchedDataByColumns<
                      MeasurementEntryRow,
                      $MeasurementEntriesTable,
                      MeasurementValueRow,
                      $MeasurementValuesTable
                    >(
                      currentTable: table,
                      referencedTable: $$MeasurementEntriesTableReferences
                          ._measurementValuesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MeasurementEntriesTableReferences(
                            db,
                            table,
                            p0,
                          ).measurementValuesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'entry_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $MeasurementEntriesTable,
      MeasurementEntryRow,
      $$MeasurementEntriesTableFilterComposer,
      $$MeasurementEntriesTableOrderingComposer,
      $$MeasurementEntriesTableAnnotationComposer,
      $$MeasurementEntriesTableCreateCompanionBuilder,
      $$MeasurementEntriesTableUpdateCompanionBuilder,
      (MeasurementEntryRow, $$MeasurementEntriesTableReferences),
      MeasurementEntryRow,
      PrefetchHooks Function({bool measurementValuesRefs})
    >;
typedef $$MeasurementValuesTableCreateCompanionBuilder =
    MeasurementValuesCompanion Function({
      required String entryId,
      required String fieldId,
      required double value,
      Value<int> rowid,
    });
typedef $$MeasurementValuesTableUpdateCompanionBuilder =
    MeasurementValuesCompanion Function({
      Value<String> entryId,
      Value<String> fieldId,
      Value<double> value,
      Value<int> rowid,
    });

final class $$MeasurementValuesTableReferences
    extends
        BaseReferences<
          _$UserDatabase,
          $MeasurementValuesTable,
          MeasurementValueRow
        > {
  $$MeasurementValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MeasurementEntriesTable _entryIdTable(_$UserDatabase db) => db
      .measurementEntries
      .createAlias('measurement_values__entry_id__measurement_entries__id');

  $$MeasurementEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$MeasurementEntriesTableTableManager(
      $_db,
      $_db.measurementEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasurementValuesTableFilterComposer
    extends Composer<_$UserDatabase, $MeasurementValuesTable> {
  $$MeasurementValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fieldId => $composableBuilder(
    column: $table.fieldId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$MeasurementEntriesTableFilterComposer get entryId {
    final $$MeasurementEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.measurementEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementEntriesTableFilterComposer(
            $db: $db,
            $table: $db.measurementEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementValuesTableOrderingComposer
    extends Composer<_$UserDatabase, $MeasurementValuesTable> {
  $$MeasurementValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fieldId => $composableBuilder(
    column: $table.fieldId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$MeasurementEntriesTableOrderingComposer get entryId {
    final $$MeasurementEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.measurementEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.measurementEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementValuesTableAnnotationComposer
    extends Composer<_$UserDatabase, $MeasurementValuesTable> {
  $$MeasurementValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fieldId =>
      $composableBuilder(column: $table.fieldId, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$MeasurementEntriesTableAnnotationComposer get entryId {
    final $$MeasurementEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.entryId,
          referencedTable: $db.measurementEntries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MeasurementValuesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $MeasurementValuesTable,
          MeasurementValueRow,
          $$MeasurementValuesTableFilterComposer,
          $$MeasurementValuesTableOrderingComposer,
          $$MeasurementValuesTableAnnotationComposer,
          $$MeasurementValuesTableCreateCompanionBuilder,
          $$MeasurementValuesTableUpdateCompanionBuilder,
          (MeasurementValueRow, $$MeasurementValuesTableReferences),
          MeasurementValueRow,
          PrefetchHooks Function({bool entryId})
        > {
  $$MeasurementValuesTableTableManager(
    _$UserDatabase db,
    $MeasurementValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> fieldId = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementValuesCompanion(
                entryId: entryId,
                fieldId: fieldId,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String fieldId,
                required double value,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementValuesCompanion.insert(
                entryId: entryId,
                fieldId: fieldId,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementValuesTable, MeasurementValueRow>(
                    table,
                  ),
                  $$MeasurementValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.entryId,
                        referencedTable: $$MeasurementValuesTableReferences
                            ._entryIdTable(db),
                        referencedColumn: $$MeasurementValuesTableReferences
                            ._entryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $MeasurementValuesTable,
      MeasurementValueRow,
      $$MeasurementValuesTableFilterComposer,
      $$MeasurementValuesTableOrderingComposer,
      $$MeasurementValuesTableAnnotationComposer,
      $$MeasurementValuesTableCreateCompanionBuilder,
      $$MeasurementValuesTableUpdateCompanionBuilder,
      (MeasurementValueRow, $$MeasurementValuesTableReferences),
      MeasurementValueRow,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$TimerPresetsTableCreateCompanionBuilder =
    TimerPresetsCompanion Function({
      required String id,
      required String name,
      required TimerMode mode,
      required String payload,
      Value<int> position,
      Value<bool> builtIn,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TimerPresetsTableUpdateCompanionBuilder =
    TimerPresetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<TimerMode> mode,
      Value<String> payload,
      Value<int> position,
      Value<bool> builtIn,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TimerPresetsTableFilterComposer
    extends Composer<_$UserDatabase, $TimerPresetsTable> {
  $$TimerPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TimerMode, TimerMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimerPresetsTableOrderingComposer
    extends Composer<_$UserDatabase, $TimerPresetsTable> {
  $$TimerPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerPresetsTableAnnotationComposer
    extends Composer<_$UserDatabase, $TimerPresetsTable> {
  $$TimerPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TimerMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TimerPresetsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $TimerPresetsTable,
          TimerPresetRow,
          $$TimerPresetsTableFilterComposer,
          $$TimerPresetsTableOrderingComposer,
          $$TimerPresetsTableAnnotationComposer,
          $$TimerPresetsTableCreateCompanionBuilder,
          $$TimerPresetsTableUpdateCompanionBuilder,
          (
            TimerPresetRow,
            BaseReferences<_$UserDatabase, $TimerPresetsTable, TimerPresetRow>,
          ),
          TimerPresetRow,
          PrefetchHooks Function()
        > {
  $$TimerPresetsTableTableManager(_$UserDatabase db, $TimerPresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<TimerMode> mode = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerPresetsCompanion(
                id: id,
                name: name,
                mode: mode,
                payload: payload,
                position: position,
                builtIn: builtIn,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required TimerMode mode,
                required String payload,
                Value<int> position = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TimerPresetsCompanion.insert(
                id: id,
                name: name,
                mode: mode,
                payload: payload,
                position: position,
                builtIn: builtIn,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerPresetsTable, TimerPresetRow>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $TimerPresetsTable,
                    TimerPresetRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimerPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $TimerPresetsTable,
      TimerPresetRow,
      $$TimerPresetsTableFilterComposer,
      $$TimerPresetsTableOrderingComposer,
      $$TimerPresetsTableAnnotationComposer,
      $$TimerPresetsTableCreateCompanionBuilder,
      $$TimerPresetsTableUpdateCompanionBuilder,
      (
        TimerPresetRow,
        BaseReferences<_$UserDatabase, $TimerPresetsTable, TimerPresetRow>,
      ),
      TimerPresetRow,
      PrefetchHooks Function()
    >;
typedef $$PlateInventoriesTableCreateCompanionBuilder =
    PlateInventoriesCompanion Function({
      Value<String> id,
      required String payload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PlateInventoriesTableUpdateCompanionBuilder =
    PlateInventoriesCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PlateInventoriesTableFilterComposer
    extends Composer<_$UserDatabase, $PlateInventoriesTable> {
  $$PlateInventoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlateInventoriesTableOrderingComposer
    extends Composer<_$UserDatabase, $PlateInventoriesTable> {
  $$PlateInventoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlateInventoriesTableAnnotationComposer
    extends Composer<_$UserDatabase, $PlateInventoriesTable> {
  $$PlateInventoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlateInventoriesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $PlateInventoriesTable,
          PlateInventoryRow,
          $$PlateInventoriesTableFilterComposer,
          $$PlateInventoriesTableOrderingComposer,
          $$PlateInventoriesTableAnnotationComposer,
          $$PlateInventoriesTableCreateCompanionBuilder,
          $$PlateInventoriesTableUpdateCompanionBuilder,
          (
            PlateInventoryRow,
            BaseReferences<
              _$UserDatabase,
              $PlateInventoriesTable,
              PlateInventoryRow
            >,
          ),
          PlateInventoryRow,
          PrefetchHooks Function()
        > {
  $$PlateInventoriesTableTableManager(
    _$UserDatabase db,
    $PlateInventoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlateInventoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlateInventoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlateInventoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlateInventoriesCompanion(
                id: id,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String payload,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlateInventoriesCompanion.insert(
                id: id,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlateInventoriesTable, PlateInventoryRow>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $PlateInventoriesTable,
                    PlateInventoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlateInventoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $PlateInventoriesTable,
      PlateInventoryRow,
      $$PlateInventoriesTableFilterComposer,
      $$PlateInventoriesTableOrderingComposer,
      $$PlateInventoriesTableAnnotationComposer,
      $$PlateInventoriesTableCreateCompanionBuilder,
      $$PlateInventoriesTableUpdateCompanionBuilder,
      (
        PlateInventoryRow,
        BaseReferences<
          _$UserDatabase,
          $PlateInventoriesTable,
          PlateInventoryRow
        >,
      ),
      PlateInventoryRow,
      PrefetchHooks Function()
    >;
typedef $$RuntimeStatesTableCreateCompanionBuilder =
    RuntimeStatesCompanion Function({
      required String key,
      required String payload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RuntimeStatesTableUpdateCompanionBuilder =
    RuntimeStatesCompanion Function({
      Value<String> key,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RuntimeStatesTableFilterComposer
    extends Composer<_$UserDatabase, $RuntimeStatesTable> {
  $$RuntimeStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RuntimeStatesTableOrderingComposer
    extends Composer<_$UserDatabase, $RuntimeStatesTable> {
  $$RuntimeStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RuntimeStatesTableAnnotationComposer
    extends Composer<_$UserDatabase, $RuntimeStatesTable> {
  $$RuntimeStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RuntimeStatesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $RuntimeStatesTable,
          RuntimeStateRow,
          $$RuntimeStatesTableFilterComposer,
          $$RuntimeStatesTableOrderingComposer,
          $$RuntimeStatesTableAnnotationComposer,
          $$RuntimeStatesTableCreateCompanionBuilder,
          $$RuntimeStatesTableUpdateCompanionBuilder,
          (
            RuntimeStateRow,
            BaseReferences<
              _$UserDatabase,
              $RuntimeStatesTable,
              RuntimeStateRow
            >,
          ),
          RuntimeStateRow,
          PrefetchHooks Function()
        > {
  $$RuntimeStatesTableTableManager(_$UserDatabase db, $RuntimeStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RuntimeStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RuntimeStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuntimeStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RuntimeStatesCompanion(
                key: key,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String payload,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RuntimeStatesCompanion.insert(
                key: key,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RuntimeStatesTable, RuntimeStateRow>(table),
                  BaseReferences<
                    _$UserDatabase,
                    $RuntimeStatesTable,
                    RuntimeStateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RuntimeStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $RuntimeStatesTable,
      RuntimeStateRow,
      $$RuntimeStatesTableFilterComposer,
      $$RuntimeStatesTableOrderingComposer,
      $$RuntimeStatesTableAnnotationComposer,
      $$RuntimeStatesTableCreateCompanionBuilder,
      $$RuntimeStatesTableUpdateCompanionBuilder,
      (
        RuntimeStateRow,
        BaseReferences<_$UserDatabase, $RuntimeStatesTable, RuntimeStateRow>,
      ),
      RuntimeStateRow,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$CustomExercisesTableTableManager get customExercises =>
      $$CustomExercisesTableTableManager(_db, _db.customExercises);
  $$ExerciseTombstonesTableTableManager get exerciseTombstones =>
      $$ExerciseTombstonesTableTableManager(_db, _db.exerciseTombstones);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineItemsTableTableManager get routineItems =>
      $$RoutineItemsTableTableManager(_db, _db.routineItems);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(_db, _db.sessionExercises);
  $$SetEntriesTableTableManager get setEntries =>
      $$SetEntriesTableTableManager(_db, _db.setEntries);
  $$MeasurementFieldsTableTableManager get measurementFields =>
      $$MeasurementFieldsTableTableManager(_db, _db.measurementFields);
  $$MeasurementEntriesTableTableManager get measurementEntries =>
      $$MeasurementEntriesTableTableManager(_db, _db.measurementEntries);
  $$MeasurementValuesTableTableManager get measurementValues =>
      $$MeasurementValuesTableTableManager(_db, _db.measurementValues);
  $$TimerPresetsTableTableManager get timerPresets =>
      $$TimerPresetsTableTableManager(_db, _db.timerPresets);
  $$PlateInventoriesTableTableManager get plateInventories =>
      $$PlateInventoriesTableTableManager(_db, _db.plateInventories);
  $$RuntimeStatesTableTableManager get runtimeStates =>
      $$RuntimeStatesTableTableManager(_db, _db.runtimeStates);
}
