// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_db.dart';

// ignore_for_file: type=lint
class $LibraryMetaTable extends LibraryMeta
    with TableInfo<$LibraryMetaTable, LibraryMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryMetaRow> instance, {
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LibraryMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LibraryMetaTable createAlias(String alias) {
    return $LibraryMetaTable(attachedDatabase, alias);
  }
}

class LibraryMetaRow extends DataClass implements Insertable<LibraryMetaRow> {
  final String key;
  final String value;
  const LibraryMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LibraryMetaCompanion toCompanion(bool nullToAbsent) {
    return LibraryMetaCompanion(key: Value(key), value: Value(value));
  }

  factory LibraryMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LibraryMetaRow copyWith({String? key, String? value}) =>
      LibraryMetaRow(key: key ?? this.key, value: value ?? this.value);
  LibraryMetaRow copyWithCompanion(LibraryMetaCompanion data) {
    return LibraryMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class LibraryMetaCompanion extends UpdateCompanion<LibraryMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LibraryMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LibraryMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LibraryMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, LibraryExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  @override
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
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
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ExercisesTable.$converteraliases);
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
  static const VerificationMeta _trackingTypeMeta = const VerificationMeta(
    'trackingType',
  );
  @override
  late final GeneratedColumn<String> trackingType = GeneratedColumn<String>(
    'tracking_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$converterprimaryMuscles);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$convertersecondaryMuscles);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> equipment =
      GeneratedColumn<String>(
        'equipment',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ExercisesTable.$converterequipment);
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unilateralMeta = const VerificationMeta(
    'unilateral',
  );
  @override
  late final GeneratedColumn<bool> unilateral = GeneratedColumn<bool>(
    'unilateral',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("unilateral" IN (0, 1))',
    ),
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
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ExercisesTable.$convertersteps);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tips =
      GeneratedColumn<String>(
        'tips',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ExercisesTable.$convertertips);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  commonMistakes = GeneratedColumn<String>(
    'common_mistakes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$convertercommonMistakes);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  safetyNotes = GeneratedColumn<String>(
    'safety_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$convertersafetyNotes);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  contraindications = GeneratedColumn<String>(
    'contraindications',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$convertercontraindications);
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
        requiredDuringInsert: true,
      ).withConverter<List<String>>($ExercisesTable.$convertertags);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    id,
    name,
    nameNorm,
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
    source,
    license,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
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
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
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
    if (data.containsKey('tracking_type')) {
      context.handle(
        _trackingTypeMeta,
        trackingType.isAcceptableOrUnknown(
          data['tracking_type']!,
          _trackingTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackingTypeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('unilateral')) {
      context.handle(
        _unilateralMeta,
        unilateral.isAcceptableOrUnknown(data['unilateral']!, _unilateralMeta),
      );
    } else if (isInserting) {
      context.missing(_unilateralMeta);
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
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  LibraryExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryExerciseRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
      aliases: $ExercisesTable.$converteraliases.fromSql(
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
      trackingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_type'],
      )!,
      primaryMuscles: $ExercisesTable.$converterprimaryMuscles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}primary_muscles'],
        )!,
      ),
      secondaryMuscles: $ExercisesTable.$convertersecondaryMuscles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}secondary_muscles'],
        )!,
      ),
      equipment: $ExercisesTable.$converterequipment.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}equipment'],
        )!,
      ),
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
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
      steps: $ExercisesTable.$convertersteps.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}steps'],
        )!,
      ),
      tips: $ExercisesTable.$convertertips.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tips'],
        )!,
      ),
      commonMistakes: $ExercisesTable.$convertercommonMistakes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}common_mistakes'],
        )!,
      ),
      safetyNotes: $ExercisesTable.$convertersafetyNotes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}safety_notes'],
        )!,
      ),
      contraindications: $ExercisesTable.$convertercontraindications.fromSql(
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
      tags: $ExercisesTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      ),
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converteraliases =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterprimaryMuscles =
      const StringListConverter();
  static TypeConverter<List<String>, String> $convertersecondaryMuscles =
      const StringListConverter();
  static TypeConverter<List<String>, String> $converterequipment =
      const StringListConverter();
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

class LibraryExerciseRow extends DataClass
    implements Insertable<LibraryExerciseRow> {
  final int seq;
  final String id;
  final String name;

  /// Lowercased, diacritics and punctuation stripped: exact and prefix lookup
  /// and the default sort.
  final String nameNorm;
  final List<String> aliases;
  final String? sanskritName;
  final String category;
  final String? subcategory;

  /// Stored by name and parsed with a fallback, so a newer library with a
  /// tracking type this build does not know still opens.
  final String trackingType;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> equipment;
  final String? difficulty;
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
  final String? source;
  final String? license;
  const LibraryExerciseRow({
    required this.seq,
    required this.id,
    required this.name,
    required this.nameNorm,
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
    this.source,
    this.license,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['name_norm'] = Variable<String>(nameNorm);
    {
      map['aliases'] = Variable<String>(
        $ExercisesTable.$converteraliases.toSql(aliases),
      );
    }
    if (!nullToAbsent || sanskritName != null) {
      map['sanskrit_name'] = Variable<String>(sanskritName);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    map['tracking_type'] = Variable<String>(trackingType);
    {
      map['primary_muscles'] = Variable<String>(
        $ExercisesTable.$converterprimaryMuscles.toSql(primaryMuscles),
      );
    }
    {
      map['secondary_muscles'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscles.toSql(secondaryMuscles),
      );
    }
    {
      map['equipment'] = Variable<String>(
        $ExercisesTable.$converterequipment.toSql(equipment),
      );
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
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
        $ExercisesTable.$convertersteps.toSql(steps),
      );
    }
    {
      map['tips'] = Variable<String>(
        $ExercisesTable.$convertertips.toSql(tips),
      );
    }
    {
      map['common_mistakes'] = Variable<String>(
        $ExercisesTable.$convertercommonMistakes.toSql(commonMistakes),
      );
    }
    {
      map['safety_notes'] = Variable<String>(
        $ExercisesTable.$convertersafetyNotes.toSql(safetyNotes),
      );
    }
    {
      map['contraindications'] = Variable<String>(
        $ExercisesTable.$convertercontraindications.toSql(contraindications),
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
        $ExercisesTable.$convertertags.toSql(tags),
      );
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || license != null) {
      map['license'] = Variable<String>(license);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      seq: Value(seq),
      id: Value(id),
      name: Value(name),
      nameNorm: Value(nameNorm),
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
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      license: license == null && nullToAbsent
          ? const Value.absent()
          : Value(license),
    );
  }

  factory LibraryExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryExerciseRow(
      seq: serializer.fromJson<int>(json['seq']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNorm: serializer.fromJson<String>(json['nameNorm']),
      aliases: serializer.fromJson<List<String>>(json['aliases']),
      sanskritName: serializer.fromJson<String?>(json['sanskritName']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      trackingType: serializer.fromJson<String>(json['trackingType']),
      primaryMuscles: serializer.fromJson<List<String>>(json['primaryMuscles']),
      secondaryMuscles: serializer.fromJson<List<String>>(
        json['secondaryMuscles'],
      ),
      equipment: serializer.fromJson<List<String>>(json['equipment']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
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
      source: serializer.fromJson<String?>(json['source']),
      license: serializer.fromJson<String?>(json['license']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nameNorm': serializer.toJson<String>(nameNorm),
      'aliases': serializer.toJson<List<String>>(aliases),
      'sanskritName': serializer.toJson<String?>(sanskritName),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'trackingType': serializer.toJson<String>(trackingType),
      'primaryMuscles': serializer.toJson<List<String>>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<List<String>>(secondaryMuscles),
      'equipment': serializer.toJson<List<String>>(equipment),
      'difficulty': serializer.toJson<String?>(difficulty),
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
      'source': serializer.toJson<String?>(source),
      'license': serializer.toJson<String?>(license),
    };
  }

  LibraryExerciseRow copyWith({
    int? seq,
    String? id,
    String? name,
    String? nameNorm,
    List<String>? aliases,
    Value<String?> sanskritName = const Value.absent(),
    String? category,
    Value<String?> subcategory = const Value.absent(),
    String? trackingType,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    List<String>? equipment,
    Value<String?> difficulty = const Value.absent(),
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
    Value<String?> source = const Value.absent(),
    Value<String?> license = const Value.absent(),
  }) => LibraryExerciseRow(
    seq: seq ?? this.seq,
    id: id ?? this.id,
    name: name ?? this.name,
    nameNorm: nameNorm ?? this.nameNorm,
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
    source: source.present ? source.value : this.source,
    license: license.present ? license.value : this.license,
  );
  LibraryExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return LibraryExerciseRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
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
      source: data.source.present ? data.source.value : this.source,
      license: data.license.present ? data.license.value : this.license,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryExerciseRow(')
          ..write('seq: $seq, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm, ')
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
          ..write('source: $source, ')
          ..write('license: $license')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    seq,
    id,
    name,
    nameNorm,
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
    source,
    license,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryExerciseRow &&
          other.seq == this.seq &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNorm == this.nameNorm &&
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
          other.source == this.source &&
          other.license == this.license);
}

class ExercisesCompanion extends UpdateCompanion<LibraryExerciseRow> {
  final Value<int> seq;
  final Value<String> id;
  final Value<String> name;
  final Value<String> nameNorm;
  final Value<List<String>> aliases;
  final Value<String?> sanskritName;
  final Value<String> category;
  final Value<String?> subcategory;
  final Value<String> trackingType;
  final Value<List<String>> primaryMuscles;
  final Value<List<String>> secondaryMuscles;
  final Value<List<String>> equipment;
  final Value<String?> difficulty;
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
  final Value<String?> source;
  final Value<String?> license;
  const ExercisesCompanion({
    this.seq = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNorm = const Value.absent(),
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
    this.source = const Value.absent(),
    this.license = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.seq = const Value.absent(),
    required String id,
    required String name,
    required String nameNorm,
    required List<String> aliases,
    this.sanskritName = const Value.absent(),
    required String category,
    this.subcategory = const Value.absent(),
    required String trackingType,
    required List<String> primaryMuscles,
    required List<String> secondaryMuscles,
    required List<String> equipment,
    this.difficulty = const Value.absent(),
    required bool unilateral,
    this.mechanic = const Value.absent(),
    this.force = const Value.absent(),
    required List<String> steps,
    required List<String> tips,
    required List<String> commonMistakes,
    required List<String> safetyNotes,
    required List<String> contraindications,
    this.metValue = const Value.absent(),
    this.defaultRestSec = const Value.absent(),
    this.defaultHoldSec = const Value.absent(),
    this.variationOf = const Value.absent(),
    required List<String> tags,
    this.source = const Value.absent(),
    this.license = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       nameNorm = Value(nameNorm),
       aliases = Value(aliases),
       category = Value(category),
       trackingType = Value(trackingType),
       primaryMuscles = Value(primaryMuscles),
       secondaryMuscles = Value(secondaryMuscles),
       equipment = Value(equipment),
       unilateral = Value(unilateral),
       steps = Value(steps),
       tips = Value(tips),
       commonMistakes = Value(commonMistakes),
       safetyNotes = Value(safetyNotes),
       contraindications = Value(contraindications),
       tags = Value(tags);
  static Insertable<LibraryExerciseRow> custom({
    Expression<int>? seq,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nameNorm,
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
    Expression<String>? source,
    Expression<String>? license,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNorm != null) 'name_norm': nameNorm,
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
      if (source != null) 'source': source,
      if (license != null) 'license': license,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? seq,
    Value<String>? id,
    Value<String>? name,
    Value<String>? nameNorm,
    Value<List<String>>? aliases,
    Value<String?>? sanskritName,
    Value<String>? category,
    Value<String?>? subcategory,
    Value<String>? trackingType,
    Value<List<String>>? primaryMuscles,
    Value<List<String>>? secondaryMuscles,
    Value<List<String>>? equipment,
    Value<String?>? difficulty,
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
    Value<String?>? source,
    Value<String?>? license,
  }) {
    return ExercisesCompanion(
      seq: seq ?? this.seq,
      id: id ?? this.id,
      name: name ?? this.name,
      nameNorm: nameNorm ?? this.nameNorm,
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
      source: source ?? this.source,
      license: license ?? this.license,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(
        $ExercisesTable.$converteraliases.toSql(aliases.value),
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
      map['tracking_type'] = Variable<String>(trackingType.value);
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(
        $ExercisesTable.$converterprimaryMuscles.toSql(primaryMuscles.value),
      );
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscles.toSql(
          secondaryMuscles.value,
        ),
      );
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
        $ExercisesTable.$converterequipment.toSql(equipment.value),
      );
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
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
        $ExercisesTable.$convertersteps.toSql(steps.value),
      );
    }
    if (tips.present) {
      map['tips'] = Variable<String>(
        $ExercisesTable.$convertertips.toSql(tips.value),
      );
    }
    if (commonMistakes.present) {
      map['common_mistakes'] = Variable<String>(
        $ExercisesTable.$convertercommonMistakes.toSql(commonMistakes.value),
      );
    }
    if (safetyNotes.present) {
      map['safety_notes'] = Variable<String>(
        $ExercisesTable.$convertersafetyNotes.toSql(safetyNotes.value),
      );
    }
    if (contraindications.present) {
      map['contraindications'] = Variable<String>(
        $ExercisesTable.$convertercontraindications.toSql(
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
        $ExercisesTable.$convertertags.toSql(tags.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('seq: $seq, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm, ')
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
          ..write('source: $source, ')
          ..write('license: $license')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMusclesTable extends ExerciseMuscles
    with TableInfo<$ExerciseMusclesTable, ExerciseMuscleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMusclesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _muscleMeta = const VerificationMeta('muscle');
  @override
  late final GeneratedColumn<String> muscle = GeneratedColumn<String>(
    'muscle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscle, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_muscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMuscleRow> instance, {
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
    if (data.containsKey('muscle')) {
      context.handle(
        _muscleMeta,
        muscle.isAcceptableOrUnknown(data['muscle']!, _muscleMeta),
      );
    } else if (isInserting) {
      context.missing(_muscleMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscle};
  @override
  ExerciseMuscleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscleRow(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      muscle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $ExerciseMusclesTable createAlias(String alias) {
    return $ExerciseMusclesTable(attachedDatabase, alias);
  }
}

class ExerciseMuscleRow extends DataClass
    implements Insertable<ExerciseMuscleRow> {
  final String exerciseId;
  final String muscle;
  final String role;
  const ExerciseMuscleRow({
    required this.exerciseId,
    required this.muscle,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['muscle'] = Variable<String>(muscle);
    map['role'] = Variable<String>(role);
    return map;
  }

  ExerciseMusclesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMusclesCompanion(
      exerciseId: Value(exerciseId),
      muscle: Value(muscle),
      role: Value(role),
    );
  }

  factory ExerciseMuscleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscleRow(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      muscle: serializer.fromJson<String>(json['muscle']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'muscle': serializer.toJson<String>(muscle),
      'role': serializer.toJson<String>(role),
    };
  }

  ExerciseMuscleRow copyWith({
    String? exerciseId,
    String? muscle,
    String? role,
  }) => ExerciseMuscleRow(
    exerciseId: exerciseId ?? this.exerciseId,
    muscle: muscle ?? this.muscle,
    role: role ?? this.role,
  );
  ExerciseMuscleRow copyWithCompanion(ExerciseMusclesCompanion data) {
    return ExerciseMuscleRow(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      muscle: data.muscle.present ? data.muscle.value : this.muscle,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscleRow(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscle: $muscle, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscle, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMuscleRow &&
          other.exerciseId == this.exerciseId &&
          other.muscle == this.muscle &&
          other.role == this.role);
}

class ExerciseMusclesCompanion extends UpdateCompanion<ExerciseMuscleRow> {
  final Value<String> exerciseId;
  final Value<String> muscle;
  final Value<String> role;
  final Value<int> rowid;
  const ExerciseMusclesCompanion({
    this.exerciseId = const Value.absent(),
    this.muscle = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMusclesCompanion.insert({
    required String exerciseId,
    required String muscle,
    required String role,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       muscle = Value(muscle),
       role = Value(role);
  static Insertable<ExerciseMuscleRow> custom({
    Expression<String>? exerciseId,
    Expression<String>? muscle,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscle != null) 'muscle': muscle,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMusclesCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? muscle,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return ExerciseMusclesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscle: muscle ?? this.muscle,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (muscle.present) {
      map['muscle'] = Variable<String>(muscle.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMusclesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscle: $muscle, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseEquipmentTable extends ExerciseEquipment
    with TableInfo<$ExerciseEquipmentTable, ExerciseEquipmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseEquipmentTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, equipment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseEquipmentRow> instance, {
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
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, equipment};
  @override
  ExerciseEquipmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseEquipmentRow(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
    );
  }

  @override
  $ExerciseEquipmentTable createAlias(String alias) {
    return $ExerciseEquipmentTable(attachedDatabase, alias);
  }
}

class ExerciseEquipmentRow extends DataClass
    implements Insertable<ExerciseEquipmentRow> {
  final String exerciseId;
  final String equipment;
  const ExerciseEquipmentRow({
    required this.exerciseId,
    required this.equipment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['equipment'] = Variable<String>(equipment);
    return map;
  }

  ExerciseEquipmentCompanion toCompanion(bool nullToAbsent) {
    return ExerciseEquipmentCompanion(
      exerciseId: Value(exerciseId),
      equipment: Value(equipment),
    );
  }

  factory ExerciseEquipmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseEquipmentRow(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      equipment: serializer.fromJson<String>(json['equipment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'equipment': serializer.toJson<String>(equipment),
    };
  }

  ExerciseEquipmentRow copyWith({String? exerciseId, String? equipment}) =>
      ExerciseEquipmentRow(
        exerciseId: exerciseId ?? this.exerciseId,
        equipment: equipment ?? this.equipment,
      );
  ExerciseEquipmentRow copyWithCompanion(ExerciseEquipmentCompanion data) {
    return ExerciseEquipmentRow(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEquipmentRow(')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipment: $equipment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, equipment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseEquipmentRow &&
          other.exerciseId == this.exerciseId &&
          other.equipment == this.equipment);
}

class ExerciseEquipmentCompanion extends UpdateCompanion<ExerciseEquipmentRow> {
  final Value<String> exerciseId;
  final Value<String> equipment;
  final Value<int> rowid;
  const ExerciseEquipmentCompanion({
    this.exerciseId = const Value.absent(),
    this.equipment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseEquipmentCompanion.insert({
    required String exerciseId,
    required String equipment,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       equipment = Value(equipment);
  static Insertable<ExerciseEquipmentRow> custom({
    Expression<String>? exerciseId,
    Expression<String>? equipment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (equipment != null) 'equipment': equipment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseEquipmentCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? equipment,
    Value<int>? rowid,
  }) {
    return ExerciseEquipmentCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      equipment: equipment ?? this.equipment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEquipmentCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipment: $equipment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LibraryDatabase extends GeneratedDatabase {
  _$LibraryDatabase(QueryExecutor e) : super(e);
  $LibraryDatabaseManager get managers => $LibraryDatabaseManager(this);
  late final $LibraryMetaTable libraryMeta = $LibraryMetaTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseMusclesTable exerciseMuscles = $ExerciseMusclesTable(
    this,
  );
  late final $ExerciseEquipmentTable exerciseEquipment =
      $ExerciseEquipmentTable(this);
  late final Index exercisesCategory = Index(
    'exercises_category',
    'CREATE INDEX exercises_category ON exercises (category)',
  );
  late final Index exercisesTracking = Index(
    'exercises_tracking',
    'CREATE INDEX exercises_tracking ON exercises (tracking_type)',
  );
  late final Index exercisesDifficulty = Index(
    'exercises_difficulty',
    'CREATE INDEX exercises_difficulty ON exercises (difficulty)',
  );
  late final Index exercisesNameNorm = Index(
    'exercises_name_norm',
    'CREATE INDEX exercises_name_norm ON exercises (name_norm)',
  );
  late final Index exerciseMusclesMuscle = Index(
    'exercise_muscles_muscle',
    'CREATE INDEX exercise_muscles_muscle ON exercise_muscles (muscle, role)',
  );
  late final Index exerciseEquipmentEquipment = Index(
    'exercise_equipment_equipment',
    'CREATE INDEX exercise_equipment_equipment ON exercise_equipment (equipment)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryMeta,
    exercises,
    exerciseMuscles,
    exerciseEquipment,
    exercisesCategory,
    exercisesTracking,
    exercisesDifficulty,
    exercisesNameNorm,
    exerciseMusclesMuscle,
    exerciseEquipmentEquipment,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$LibraryMetaTableCreateCompanionBuilder =
    LibraryMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$LibraryMetaTableUpdateCompanionBuilder =
    LibraryMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$LibraryMetaTableFilterComposer
    extends Composer<_$LibraryDatabase, $LibraryMetaTable> {
  $$LibraryMetaTableFilterComposer({
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

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryMetaTableOrderingComposer
    extends Composer<_$LibraryDatabase, $LibraryMetaTable> {
  $$LibraryMetaTableOrderingComposer({
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

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryMetaTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $LibraryMetaTable> {
  $$LibraryMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LibraryMetaTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $LibraryMetaTable,
          LibraryMetaRow,
          $$LibraryMetaTableFilterComposer,
          $$LibraryMetaTableOrderingComposer,
          $$LibraryMetaTableAnnotationComposer,
          $$LibraryMetaTableCreateCompanionBuilder,
          $$LibraryMetaTableUpdateCompanionBuilder,
          (
            LibraryMetaRow,
            BaseReferences<
              _$LibraryDatabase,
              $LibraryMetaTable,
              LibraryMetaRow
            >,
          ),
          LibraryMetaRow,
          PrefetchHooks Function()
        > {
  $$LibraryMetaTableTableManager(_$LibraryDatabase db, $LibraryMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LibraryMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => LibraryMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LibraryMetaTable, LibraryMetaRow>(table),
                  BaseReferences<
                    _$LibraryDatabase,
                    $LibraryMetaTable,
                    LibraryMetaRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $LibraryMetaTable,
      LibraryMetaRow,
      $$LibraryMetaTableFilterComposer,
      $$LibraryMetaTableOrderingComposer,
      $$LibraryMetaTableAnnotationComposer,
      $$LibraryMetaTableCreateCompanionBuilder,
      $$LibraryMetaTableUpdateCompanionBuilder,
      (
        LibraryMetaRow,
        BaseReferences<_$LibraryDatabase, $LibraryMetaTable, LibraryMetaRow>,
      ),
      LibraryMetaRow,
      PrefetchHooks Function()
    >;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<int> seq,
  required String id,
  required String name,
  required String nameNorm,
  required List<String> aliases,
  Value<String?> sanskritName,
  required String category,
  Value<String?> subcategory,
  required String trackingType,
  required List<String> primaryMuscles,
  required List<String> secondaryMuscles,
  required List<String> equipment,
  Value<String?> difficulty,
  required bool unilateral,
  Value<String?> mechanic,
  Value<String?> force,
  required List<String> steps,
  required List<String> tips,
  required List<String> commonMistakes,
  required List<String> safetyNotes,
  required List<String> contraindications,
  Value<double?> metValue,
  Value<int?> defaultRestSec,
  Value<int?> defaultHoldSec,
  Value<String?> variationOf,
  required List<String> tags,
  Value<String?> source,
  Value<String?> license,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> seq,
  Value<String> id,
  Value<String> name,
  Value<String> nameNorm,
  Value<List<String>> aliases,
  Value<String?> sanskritName,
  Value<String> category,
  Value<String?> subcategory,
  Value<String> trackingType,
  Value<List<String>> primaryMuscles,
  Value<List<String>> secondaryMuscles,
  Value<List<String>> equipment,
  Value<String?> difficulty,
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
  Value<String?> source,
  Value<String?> license,
});

final class $$ExercisesTableReferences
    extends
        BaseReferences<_$LibraryDatabase, $ExercisesTable, LibraryExerciseRow> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMusclesTable, List<ExerciseMuscleRow>>
  _exerciseMusclesRefsTable(_$LibraryDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseMuscles,
        aliasName: 'exercises__id__exercise_muscles__exercise_id',
      );

  $$ExerciseMusclesTableProcessedTableManager get exerciseMusclesRefs {
    final manager = $$ExerciseMusclesTableTableManager(
      $_db,
      $_db.exerciseMuscles,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMusclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseEquipmentTable,
    List<ExerciseEquipmentRow>
  >
  _exerciseEquipmentRefsTable(_$LibraryDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseEquipment,
        aliasName: 'exercises__id__exercise_equipment__exercise_id',
      );

  $$ExerciseEquipmentTableProcessedTableManager get exerciseEquipmentRefs {
    final manager = $$ExerciseEquipmentTableTableManager(
      $_db,
      $_db.exerciseEquipment,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseEquipmentRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$LibraryDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
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

  ColumnFilters<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnFilters(column),
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

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
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

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMusclesRefs(
    Expression<bool> Function($$ExerciseMusclesTableFilterComposer f) f,
  ) {
    final $$ExerciseMusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseEquipmentRefs(
    Expression<bool> Function($$ExerciseEquipmentTableFilterComposer f) f,
  ) {
    final $$ExerciseEquipmentTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipment,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentTableFilterComposer(
            $db: $db,
            $table: $db.exerciseEquipment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$LibraryDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
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

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);

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

  GeneratedColumn<String> get trackingType => $composableBuilder(
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

  GeneratedColumn<String> get difficulty => $composableBuilder(
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

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  Expression<T> exerciseMusclesRefs<T extends Object>(
    Expression<T> Function($$ExerciseMusclesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseEquipmentRefs<T extends Object>(
    Expression<T> Function($$ExerciseEquipmentTableAnnotationComposer a) f,
  ) {
    final $$ExerciseEquipmentTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseEquipment,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseEquipmentTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseEquipment,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $ExercisesTable,
          LibraryExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (LibraryExerciseRow, $$ExercisesTableReferences),
          LibraryExerciseRow,
          PrefetchHooks Function({
            bool exerciseMusclesRefs,
            bool exerciseEquipmentRefs,
          })
        > {
  $$ExercisesTableTableManager(_$LibraryDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameNorm = const Value.absent(),
                Value<List<String>> aliases = const Value.absent(),
                Value<String?> sanskritName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String> trackingType = const Value.absent(),
                Value<List<String>> primaryMuscles = const Value.absent(),
                Value<List<String>> secondaryMuscles = const Value.absent(),
                Value<List<String>> equipment = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
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
                Value<String?> source = const Value.absent(),
                Value<String?> license = const Value.absent(),
              }) => ExercisesCompanion(
                seq: seq,
                id: id,
                name: name,
                nameNorm: nameNorm,
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
                source: source,
                license: license,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String id,
                required String name,
                required String nameNorm,
                required List<String> aliases,
                Value<String?> sanskritName = const Value.absent(),
                required String category,
                Value<String?> subcategory = const Value.absent(),
                required String trackingType,
                required List<String> primaryMuscles,
                required List<String> secondaryMuscles,
                required List<String> equipment,
                Value<String?> difficulty = const Value.absent(),
                required bool unilateral,
                Value<String?> mechanic = const Value.absent(),
                Value<String?> force = const Value.absent(),
                required List<String> steps,
                required List<String> tips,
                required List<String> commonMistakes,
                required List<String> safetyNotes,
                required List<String> contraindications,
                Value<double?> metValue = const Value.absent(),
                Value<int?> defaultRestSec = const Value.absent(),
                Value<int?> defaultHoldSec = const Value.absent(),
                Value<String?> variationOf = const Value.absent(),
                required List<String> tags,
                Value<String?> source = const Value.absent(),
                Value<String?> license = const Value.absent(),
              }) => ExercisesCompanion.insert(
                seq: seq,
                id: id,
                name: name,
                nameNorm: nameNorm,
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
                source: source,
                license: license,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, LibraryExerciseRow>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exerciseMusclesRefs = false, exerciseEquipmentRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseMusclesRefs) db.exerciseMuscles,
                    if (exerciseEquipmentRefs) db.exerciseEquipment,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseMusclesRefs)
                        await $_getPrefetchedDataByColumns<
                          LibraryExerciseRow,
                          $ExercisesTable,
                          ExerciseMuscleRow,
                          $ExerciseMusclesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseMusclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseMusclesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (exerciseEquipmentRefs)
                        await $_getPrefetchedDataByColumns<
                          LibraryExerciseRow,
                          $ExercisesTable,
                          ExerciseEquipmentRow,
                          $ExerciseEquipmentTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseEquipmentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseEquipmentRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $ExercisesTable,
      LibraryExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (LibraryExerciseRow, $$ExercisesTableReferences),
      LibraryExerciseRow,
      PrefetchHooks Function({
        bool exerciseMusclesRefs,
        bool exerciseEquipmentRefs,
      })
    >;
typedef $$ExerciseMusclesTableCreateCompanionBuilder =
    ExerciseMusclesCompanion Function({
      required String exerciseId,
      required String muscle,
      required String role,
      Value<int> rowid,
    });
typedef $$ExerciseMusclesTableUpdateCompanionBuilder =
    ExerciseMusclesCompanion Function({
      Value<String> exerciseId,
      Value<String> muscle,
      Value<String> role,
      Value<int> rowid,
    });

final class $$ExerciseMusclesTableReferences
    extends
        BaseReferences<
          _$LibraryDatabase,
          $ExerciseMusclesTable,
          ExerciseMuscleRow
        > {
  $$ExerciseMusclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$LibraryDatabase db) =>
      db.exercises.createAlias('exercise_muscles__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseMusclesTableFilterComposer
    extends Composer<_$LibraryDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get muscle => $composableBuilder(
    column: $table.muscle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableOrderingComposer
    extends Composer<_$LibraryDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get muscle => $composableBuilder(
    column: $table.muscle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get muscle =>
      $composableBuilder(column: $table.muscle, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $ExerciseMusclesTable,
          ExerciseMuscleRow,
          $$ExerciseMusclesTableFilterComposer,
          $$ExerciseMusclesTableOrderingComposer,
          $$ExerciseMusclesTableAnnotationComposer,
          $$ExerciseMusclesTableCreateCompanionBuilder,
          $$ExerciseMusclesTableUpdateCompanionBuilder,
          (ExerciseMuscleRow, $$ExerciseMusclesTableReferences),
          ExerciseMuscleRow,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseMusclesTableTableManager(
    _$LibraryDatabase db,
    $ExerciseMusclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMusclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMusclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseMusclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> muscle = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion(
                exerciseId: exerciseId,
                muscle: muscle,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String muscle,
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion.insert(
                exerciseId: exerciseId,
                muscle: muscle,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseMusclesTable, ExerciseMuscleRow>(table),
                  $$ExerciseMusclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
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
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ExerciseMusclesTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$ExerciseMusclesTableReferences
                            ._exerciseIdTable(db)
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

typedef $$ExerciseMusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $ExerciseMusclesTable,
      ExerciseMuscleRow,
      $$ExerciseMusclesTableFilterComposer,
      $$ExerciseMusclesTableOrderingComposer,
      $$ExerciseMusclesTableAnnotationComposer,
      $$ExerciseMusclesTableCreateCompanionBuilder,
      $$ExerciseMusclesTableUpdateCompanionBuilder,
      (ExerciseMuscleRow, $$ExerciseMusclesTableReferences),
      ExerciseMuscleRow,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$ExerciseEquipmentTableCreateCompanionBuilder =
    ExerciseEquipmentCompanion Function({
      required String exerciseId,
      required String equipment,
      Value<int> rowid,
    });
typedef $$ExerciseEquipmentTableUpdateCompanionBuilder =
    ExerciseEquipmentCompanion Function({
      Value<String> exerciseId,
      Value<String> equipment,
      Value<int> rowid,
    });

final class $$ExerciseEquipmentTableReferences
    extends
        BaseReferences<
          _$LibraryDatabase,
          $ExerciseEquipmentTable,
          ExerciseEquipmentRow
        > {
  $$ExerciseEquipmentTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$LibraryDatabase db) => db.exercises
      .createAlias('exercise_equipment__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseEquipmentTableFilterComposer
    extends Composer<_$LibraryDatabase, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentTableOrderingComposer
    extends Composer<_$LibraryDatabase, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $ExerciseEquipmentTable> {
  $$ExerciseEquipmentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $ExerciseEquipmentTable,
          ExerciseEquipmentRow,
          $$ExerciseEquipmentTableFilterComposer,
          $$ExerciseEquipmentTableOrderingComposer,
          $$ExerciseEquipmentTableAnnotationComposer,
          $$ExerciseEquipmentTableCreateCompanionBuilder,
          $$ExerciseEquipmentTableUpdateCompanionBuilder,
          (ExerciseEquipmentRow, $$ExerciseEquipmentTableReferences),
          ExerciseEquipmentRow,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseEquipmentTableTableManager(
    _$LibraryDatabase db,
    $ExerciseEquipmentTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseEquipmentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseEquipmentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseEquipmentTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEquipmentCompanion(
                exerciseId: exerciseId,
                equipment: equipment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String equipment,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEquipmentCompanion.insert(
                exerciseId: exerciseId,
                equipment: equipment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseEquipmentTable, ExerciseEquipmentRow>(
                    table,
                  ),
                  $$ExerciseEquipmentTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
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
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ExerciseEquipmentTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$ExerciseEquipmentTableReferences
                            ._exerciseIdTable(db)
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

typedef $$ExerciseEquipmentTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $ExerciseEquipmentTable,
      ExerciseEquipmentRow,
      $$ExerciseEquipmentTableFilterComposer,
      $$ExerciseEquipmentTableOrderingComposer,
      $$ExerciseEquipmentTableAnnotationComposer,
      $$ExerciseEquipmentTableCreateCompanionBuilder,
      $$ExerciseEquipmentTableUpdateCompanionBuilder,
      (ExerciseEquipmentRow, $$ExerciseEquipmentTableReferences),
      ExerciseEquipmentRow,
      PrefetchHooks Function({bool exerciseId})
    >;

class $LibraryDatabaseManager {
  final _$LibraryDatabase _db;
  $LibraryDatabaseManager(this._db);
  $$LibraryMetaTableTableManager get libraryMeta =>
      $$LibraryMetaTableTableManager(_db, _db.libraryMeta);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseMusclesTableTableManager get exerciseMuscles =>
      $$ExerciseMusclesTableTableManager(_db, _db.exerciseMuscles);
  $$ExerciseEquipmentTableTableManager get exerciseEquipment =>
      $$ExerciseEquipmentTableTableManager(_db, _db.exerciseEquipment);
}
