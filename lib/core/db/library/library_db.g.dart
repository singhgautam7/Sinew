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

class $FlowsTable extends Flows with TableInfo<$FlowsTable, LibraryFlowRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalDurationSecMeta = const VerificationMeta(
    'totalDurationSec',
  );
  @override
  late final GeneratedColumn<int> totalDurationSec = GeneratedColumn<int>(
    'total_duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($FlowsTable.$convertertags);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    difficulty,
    description,
    totalDurationSec,
    rounds,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flows';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryFlowRow> instance, {
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('total_duration_sec')) {
      context.handle(
        _totalDurationSecMeta,
        totalDurationSec.isAcceptableOrUnknown(
          data['total_duration_sec']!,
          _totalDurationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalDurationSecMeta);
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    } else if (isInserting) {
      context.missing(_roundsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryFlowRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryFlowRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      totalDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_sec'],
      )!,
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
      tags: $FlowsTable.$convertertags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        )!,
      ),
    );
  }

  @override
  $FlowsTable createAlias(String alias) {
    return $FlowsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const StringListConverter();
}

class LibraryFlowRow extends DataClass implements Insertable<LibraryFlowRow> {
  final String id;
  final String name;
  final String category;
  final String? difficulty;
  final String description;
  final int totalDurationSec;
  final int rounds;
  final List<String> tags;
  const LibraryFlowRow({
    required this.id,
    required this.name,
    required this.category,
    this.difficulty,
    required this.description,
    required this.totalDurationSec,
    required this.rounds,
    required this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    map['description'] = Variable<String>(description);
    map['total_duration_sec'] = Variable<int>(totalDurationSec);
    map['rounds'] = Variable<int>(rounds);
    {
      map['tags'] = Variable<String>($FlowsTable.$convertertags.toSql(tags));
    }
    return map;
  }

  FlowsCompanion toCompanion(bool nullToAbsent) {
    return FlowsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      description: Value(description),
      totalDurationSec: Value(totalDurationSec),
      rounds: Value(rounds),
      tags: Value(tags),
    );
  }

  factory LibraryFlowRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryFlowRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      description: serializer.fromJson<String>(json['description']),
      totalDurationSec: serializer.fromJson<int>(json['totalDurationSec']),
      rounds: serializer.fromJson<int>(json['rounds']),
      tags: serializer.fromJson<List<String>>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'difficulty': serializer.toJson<String?>(difficulty),
      'description': serializer.toJson<String>(description),
      'totalDurationSec': serializer.toJson<int>(totalDurationSec),
      'rounds': serializer.toJson<int>(rounds),
      'tags': serializer.toJson<List<String>>(tags),
    };
  }

  LibraryFlowRow copyWith({
    String? id,
    String? name,
    String? category,
    Value<String?> difficulty = const Value.absent(),
    String? description,
    int? totalDurationSec,
    int? rounds,
    List<String>? tags,
  }) => LibraryFlowRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    description: description ?? this.description,
    totalDurationSec: totalDurationSec ?? this.totalDurationSec,
    rounds: rounds ?? this.rounds,
    tags: tags ?? this.tags,
  );
  LibraryFlowRow copyWithCompanion(FlowsCompanion data) {
    return LibraryFlowRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      description: data.description.present
          ? data.description.value
          : this.description,
      totalDurationSec: data.totalDurationSec.present
          ? data.totalDurationSec.value
          : this.totalDurationSec,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryFlowRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('description: $description, ')
          ..write('totalDurationSec: $totalDurationSec, ')
          ..write('rounds: $rounds, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    difficulty,
    description,
    totalDurationSec,
    rounds,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryFlowRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.description == this.description &&
          other.totalDurationSec == this.totalDurationSec &&
          other.rounds == this.rounds &&
          other.tags == this.tags);
}

class FlowsCompanion extends UpdateCompanion<LibraryFlowRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> difficulty;
  final Value<String> description;
  final Value<int> totalDurationSec;
  final Value<int> rounds;
  final Value<List<String>> tags;
  final Value<int> rowid;
  const FlowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.description = const Value.absent(),
    this.totalDurationSec = const Value.absent(),
    this.rounds = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlowsCompanion.insert({
    required String id,
    required String name,
    required String category,
    this.difficulty = const Value.absent(),
    required String description,
    required int totalDurationSec,
    required int rounds,
    required List<String> tags,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       description = Value(description),
       totalDurationSec = Value(totalDurationSec),
       rounds = Value(rounds),
       tags = Value(tags);
  static Insertable<LibraryFlowRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? difficulty,
    Expression<String>? description,
    Expression<int>? totalDurationSec,
    Expression<int>? rounds,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (description != null) 'description': description,
      if (totalDurationSec != null) 'total_duration_sec': totalDurationSec,
      if (rounds != null) 'rounds': rounds,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String?>? difficulty,
    Value<String>? description,
    Value<int>? totalDurationSec,
    Value<int>? rounds,
    Value<List<String>>? tags,
    Value<int>? rowid,
  }) {
    return FlowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      totalDurationSec: totalDurationSec ?? this.totalDurationSec,
      rounds: rounds ?? this.rounds,
      tags: tags ?? this.tags,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (totalDurationSec.present) {
      map['total_duration_sec'] = Variable<int>(totalDurationSec.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $FlowsTable.$convertertags.toSql(tags.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('description: $description, ')
          ..write('totalDurationSec: $totalDurationSec, ')
          ..write('rounds: $rounds, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlowStepsTable extends FlowSteps
    with TableInfo<$FlowStepsTable, LibraryFlowStepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlowStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _flowIdMeta = const VerificationMeta('flowId');
  @override
  late final GeneratedColumn<String> flowId = GeneratedColumn<String>(
    'flow_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES flows (id)',
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _holdSecMeta = const VerificationMeta(
    'holdSec',
  );
  @override
  late final GeneratedColumn<int> holdSec = GeneratedColumn<int>(
    'hold_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transitionSecMeta = const VerificationMeta(
    'transitionSec',
  );
  @override
  late final GeneratedColumn<int> transitionSec = GeneratedColumn<int>(
    'transition_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cueMeta = const VerificationMeta('cue');
  @override
  late final GeneratedColumn<String> cue = GeneratedColumn<String>(
    'cue',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    flowId,
    position,
    exerciseId,
    label,
    holdSec,
    transitionSec,
    cue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flow_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryFlowStepRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('flow_id')) {
      context.handle(
        _flowIdMeta,
        flowId.isAcceptableOrUnknown(data['flow_id']!, _flowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_flowIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('hold_sec')) {
      context.handle(
        _holdSecMeta,
        holdSec.isAcceptableOrUnknown(data['hold_sec']!, _holdSecMeta),
      );
    } else if (isInserting) {
      context.missing(_holdSecMeta);
    }
    if (data.containsKey('transition_sec')) {
      context.handle(
        _transitionSecMeta,
        transitionSec.isAcceptableOrUnknown(
          data['transition_sec']!,
          _transitionSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transitionSecMeta);
    }
    if (data.containsKey('cue')) {
      context.handle(
        _cueMeta,
        cue.isAcceptableOrUnknown(data['cue']!, _cueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {flowId, position};
  @override
  LibraryFlowStepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryFlowStepRow(
      flowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flow_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      holdSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hold_sec'],
      )!,
      transitionSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transition_sec'],
      )!,
      cue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue'],
      ),
    );
  }

  @override
  $FlowStepsTable createAlias(String alias) {
    return $FlowStepsTable(attachedDatabase, alias);
  }
}

class LibraryFlowStepRow extends DataClass
    implements Insertable<LibraryFlowStepRow> {
  final String flowId;
  final int position;
  final String exerciseId;
  final String? label;
  final int holdSec;
  final int transitionSec;
  final String? cue;
  const LibraryFlowStepRow({
    required this.flowId,
    required this.position,
    required this.exerciseId,
    this.label,
    required this.holdSec,
    required this.transitionSec,
    this.cue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['flow_id'] = Variable<String>(flowId);
    map['position'] = Variable<int>(position);
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['hold_sec'] = Variable<int>(holdSec);
    map['transition_sec'] = Variable<int>(transitionSec);
    if (!nullToAbsent || cue != null) {
      map['cue'] = Variable<String>(cue);
    }
    return map;
  }

  FlowStepsCompanion toCompanion(bool nullToAbsent) {
    return FlowStepsCompanion(
      flowId: Value(flowId),
      position: Value(position),
      exerciseId: Value(exerciseId),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      holdSec: Value(holdSec),
      transitionSec: Value(transitionSec),
      cue: cue == null && nullToAbsent ? const Value.absent() : Value(cue),
    );
  }

  factory LibraryFlowStepRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryFlowStepRow(
      flowId: serializer.fromJson<String>(json['flowId']),
      position: serializer.fromJson<int>(json['position']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      label: serializer.fromJson<String?>(json['label']),
      holdSec: serializer.fromJson<int>(json['holdSec']),
      transitionSec: serializer.fromJson<int>(json['transitionSec']),
      cue: serializer.fromJson<String?>(json['cue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'flowId': serializer.toJson<String>(flowId),
      'position': serializer.toJson<int>(position),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'label': serializer.toJson<String?>(label),
      'holdSec': serializer.toJson<int>(holdSec),
      'transitionSec': serializer.toJson<int>(transitionSec),
      'cue': serializer.toJson<String?>(cue),
    };
  }

  LibraryFlowStepRow copyWith({
    String? flowId,
    int? position,
    String? exerciseId,
    Value<String?> label = const Value.absent(),
    int? holdSec,
    int? transitionSec,
    Value<String?> cue = const Value.absent(),
  }) => LibraryFlowStepRow(
    flowId: flowId ?? this.flowId,
    position: position ?? this.position,
    exerciseId: exerciseId ?? this.exerciseId,
    label: label.present ? label.value : this.label,
    holdSec: holdSec ?? this.holdSec,
    transitionSec: transitionSec ?? this.transitionSec,
    cue: cue.present ? cue.value : this.cue,
  );
  LibraryFlowStepRow copyWithCompanion(FlowStepsCompanion data) {
    return LibraryFlowStepRow(
      flowId: data.flowId.present ? data.flowId.value : this.flowId,
      position: data.position.present ? data.position.value : this.position,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      label: data.label.present ? data.label.value : this.label,
      holdSec: data.holdSec.present ? data.holdSec.value : this.holdSec,
      transitionSec: data.transitionSec.present
          ? data.transitionSec.value
          : this.transitionSec,
      cue: data.cue.present ? data.cue.value : this.cue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryFlowStepRow(')
          ..write('flowId: $flowId, ')
          ..write('position: $position, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('label: $label, ')
          ..write('holdSec: $holdSec, ')
          ..write('transitionSec: $transitionSec, ')
          ..write('cue: $cue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    flowId,
    position,
    exerciseId,
    label,
    holdSec,
    transitionSec,
    cue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryFlowStepRow &&
          other.flowId == this.flowId &&
          other.position == this.position &&
          other.exerciseId == this.exerciseId &&
          other.label == this.label &&
          other.holdSec == this.holdSec &&
          other.transitionSec == this.transitionSec &&
          other.cue == this.cue);
}

class FlowStepsCompanion extends UpdateCompanion<LibraryFlowStepRow> {
  final Value<String> flowId;
  final Value<int> position;
  final Value<String> exerciseId;
  final Value<String?> label;
  final Value<int> holdSec;
  final Value<int> transitionSec;
  final Value<String?> cue;
  final Value<int> rowid;
  const FlowStepsCompanion({
    this.flowId = const Value.absent(),
    this.position = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.label = const Value.absent(),
    this.holdSec = const Value.absent(),
    this.transitionSec = const Value.absent(),
    this.cue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlowStepsCompanion.insert({
    required String flowId,
    required int position,
    required String exerciseId,
    this.label = const Value.absent(),
    required int holdSec,
    required int transitionSec,
    this.cue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : flowId = Value(flowId),
       position = Value(position),
       exerciseId = Value(exerciseId),
       holdSec = Value(holdSec),
       transitionSec = Value(transitionSec);
  static Insertable<LibraryFlowStepRow> custom({
    Expression<String>? flowId,
    Expression<int>? position,
    Expression<String>? exerciseId,
    Expression<String>? label,
    Expression<int>? holdSec,
    Expression<int>? transitionSec,
    Expression<String>? cue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (flowId != null) 'flow_id': flowId,
      if (position != null) 'position': position,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (label != null) 'label': label,
      if (holdSec != null) 'hold_sec': holdSec,
      if (transitionSec != null) 'transition_sec': transitionSec,
      if (cue != null) 'cue': cue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlowStepsCompanion copyWith({
    Value<String>? flowId,
    Value<int>? position,
    Value<String>? exerciseId,
    Value<String?>? label,
    Value<int>? holdSec,
    Value<int>? transitionSec,
    Value<String?>? cue,
    Value<int>? rowid,
  }) {
    return FlowStepsCompanion(
      flowId: flowId ?? this.flowId,
      position: position ?? this.position,
      exerciseId: exerciseId ?? this.exerciseId,
      label: label ?? this.label,
      holdSec: holdSec ?? this.holdSec,
      transitionSec: transitionSec ?? this.transitionSec,
      cue: cue ?? this.cue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (flowId.present) {
      map['flow_id'] = Variable<String>(flowId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (holdSec.present) {
      map['hold_sec'] = Variable<int>(holdSec.value);
    }
    if (transitionSec.present) {
      map['transition_sec'] = Variable<int>(transitionSec.value);
    }
    if (cue.present) {
      map['cue'] = Variable<String>(cue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlowStepsCompanion(')
          ..write('flowId: $flowId, ')
          ..write('position: $position, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('label: $label, ')
          ..write('holdSec: $holdSec, ')
          ..write('transitionSec: $transitionSec, ')
          ..write('cue: $cue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMotionsTable extends ExerciseMotions
    with TableInfo<$ExerciseMotionsTable, ExerciseMotionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMotionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewMeta = const VerificationMeta('view');
  @override
  late final GeneratedColumn<String> view = GeneratedColumn<String>(
    'view',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loopMeta = const VerificationMeta('loop');
  @override
  late final GeneratedColumn<String> loop = GeneratedColumn<String>(
    'loop',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mirrorMeta = const VerificationMeta('mirror');
  @override
  late final GeneratedColumn<bool> mirror = GeneratedColumn<bool>(
    'mirror',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mirror" IN (0, 1))',
    ),
  );
  static const VerificationMeta _stepFramesMeta = const VerificationMeta(
    'stepFrames',
  );
  @override
  late final GeneratedColumn<String> stepFrames = GeneratedColumn<String>(
    'step_frames',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _highlightMeta = const VerificationMeta(
    'highlight',
  );
  @override
  late final GeneratedColumn<String> highlight = GeneratedColumn<String>(
    'highlight',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<Uint8List> payload = GeneratedColumn<Uint8List>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    tier,
    view,
    loop,
    mirror,
    stepFrames,
    highlight,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_motions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMotionRow> instance, {
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
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('view')) {
      context.handle(
        _viewMeta,
        view.isAcceptableOrUnknown(data['view']!, _viewMeta),
      );
    } else if (isInserting) {
      context.missing(_viewMeta);
    }
    if (data.containsKey('loop')) {
      context.handle(
        _loopMeta,
        loop.isAcceptableOrUnknown(data['loop']!, _loopMeta),
      );
    } else if (isInserting) {
      context.missing(_loopMeta);
    }
    if (data.containsKey('mirror')) {
      context.handle(
        _mirrorMeta,
        mirror.isAcceptableOrUnknown(data['mirror']!, _mirrorMeta),
      );
    } else if (isInserting) {
      context.missing(_mirrorMeta);
    }
    if (data.containsKey('step_frames')) {
      context.handle(
        _stepFramesMeta,
        stepFrames.isAcceptableOrUnknown(data['step_frames']!, _stepFramesMeta),
      );
    } else if (isInserting) {
      context.missing(_stepFramesMeta);
    }
    if (data.containsKey('highlight')) {
      context.handle(
        _highlightMeta,
        highlight.isAcceptableOrUnknown(data['highlight']!, _highlightMeta),
      );
    } else if (isInserting) {
      context.missing(_highlightMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseMotionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMotionRow(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      view: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view'],
      )!,
      loop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loop'],
      )!,
      mirror: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mirror'],
      )!,
      stepFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}step_frames'],
      )!,
      highlight: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}highlight'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ExerciseMotionsTable createAlias(String alias) {
    return $ExerciseMotionsTable(attachedDatabase, alias);
  }
}

class ExerciseMotionRow extends DataClass
    implements Insertable<ExerciseMotionRow> {
  final String exerciseId;
  final String tier;
  final String view;
  final String loop;
  final bool mirror;
  final String stepFrames;
  final String highlight;
  final Uint8List payload;
  const ExerciseMotionRow({
    required this.exerciseId,
    required this.tier,
    required this.view,
    required this.loop,
    required this.mirror,
    required this.stepFrames,
    required this.highlight,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['tier'] = Variable<String>(tier);
    map['view'] = Variable<String>(view);
    map['loop'] = Variable<String>(loop);
    map['mirror'] = Variable<bool>(mirror);
    map['step_frames'] = Variable<String>(stepFrames);
    map['highlight'] = Variable<String>(highlight);
    map['payload'] = Variable<Uint8List>(payload);
    return map;
  }

  ExerciseMotionsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMotionsCompanion(
      exerciseId: Value(exerciseId),
      tier: Value(tier),
      view: Value(view),
      loop: Value(loop),
      mirror: Value(mirror),
      stepFrames: Value(stepFrames),
      highlight: Value(highlight),
      payload: Value(payload),
    );
  }

  factory ExerciseMotionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMotionRow(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      tier: serializer.fromJson<String>(json['tier']),
      view: serializer.fromJson<String>(json['view']),
      loop: serializer.fromJson<String>(json['loop']),
      mirror: serializer.fromJson<bool>(json['mirror']),
      stepFrames: serializer.fromJson<String>(json['stepFrames']),
      highlight: serializer.fromJson<String>(json['highlight']),
      payload: serializer.fromJson<Uint8List>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'tier': serializer.toJson<String>(tier),
      'view': serializer.toJson<String>(view),
      'loop': serializer.toJson<String>(loop),
      'mirror': serializer.toJson<bool>(mirror),
      'stepFrames': serializer.toJson<String>(stepFrames),
      'highlight': serializer.toJson<String>(highlight),
      'payload': serializer.toJson<Uint8List>(payload),
    };
  }

  ExerciseMotionRow copyWith({
    String? exerciseId,
    String? tier,
    String? view,
    String? loop,
    bool? mirror,
    String? stepFrames,
    String? highlight,
    Uint8List? payload,
  }) => ExerciseMotionRow(
    exerciseId: exerciseId ?? this.exerciseId,
    tier: tier ?? this.tier,
    view: view ?? this.view,
    loop: loop ?? this.loop,
    mirror: mirror ?? this.mirror,
    stepFrames: stepFrames ?? this.stepFrames,
    highlight: highlight ?? this.highlight,
    payload: payload ?? this.payload,
  );
  ExerciseMotionRow copyWithCompanion(ExerciseMotionsCompanion data) {
    return ExerciseMotionRow(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      tier: data.tier.present ? data.tier.value : this.tier,
      view: data.view.present ? data.view.value : this.view,
      loop: data.loop.present ? data.loop.value : this.loop,
      mirror: data.mirror.present ? data.mirror.value : this.mirror,
      stepFrames: data.stepFrames.present
          ? data.stepFrames.value
          : this.stepFrames,
      highlight: data.highlight.present ? data.highlight.value : this.highlight,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMotionRow(')
          ..write('exerciseId: $exerciseId, ')
          ..write('tier: $tier, ')
          ..write('view: $view, ')
          ..write('loop: $loop, ')
          ..write('mirror: $mirror, ')
          ..write('stepFrames: $stepFrames, ')
          ..write('highlight: $highlight, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    exerciseId,
    tier,
    view,
    loop,
    mirror,
    stepFrames,
    highlight,
    $driftBlobEquality.hash(payload),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMotionRow &&
          other.exerciseId == this.exerciseId &&
          other.tier == this.tier &&
          other.view == this.view &&
          other.loop == this.loop &&
          other.mirror == this.mirror &&
          other.stepFrames == this.stepFrames &&
          other.highlight == this.highlight &&
          $driftBlobEquality.equals(other.payload, this.payload));
}

class ExerciseMotionsCompanion extends UpdateCompanion<ExerciseMotionRow> {
  final Value<String> exerciseId;
  final Value<String> tier;
  final Value<String> view;
  final Value<String> loop;
  final Value<bool> mirror;
  final Value<String> stepFrames;
  final Value<String> highlight;
  final Value<Uint8List> payload;
  final Value<int> rowid;
  const ExerciseMotionsCompanion({
    this.exerciseId = const Value.absent(),
    this.tier = const Value.absent(),
    this.view = const Value.absent(),
    this.loop = const Value.absent(),
    this.mirror = const Value.absent(),
    this.stepFrames = const Value.absent(),
    this.highlight = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMotionsCompanion.insert({
    required String exerciseId,
    required String tier,
    required String view,
    required String loop,
    required bool mirror,
    required String stepFrames,
    required String highlight,
    required Uint8List payload,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       tier = Value(tier),
       view = Value(view),
       loop = Value(loop),
       mirror = Value(mirror),
       stepFrames = Value(stepFrames),
       highlight = Value(highlight),
       payload = Value(payload);
  static Insertable<ExerciseMotionRow> custom({
    Expression<String>? exerciseId,
    Expression<String>? tier,
    Expression<String>? view,
    Expression<String>? loop,
    Expression<bool>? mirror,
    Expression<String>? stepFrames,
    Expression<String>? highlight,
    Expression<Uint8List>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (tier != null) 'tier': tier,
      if (view != null) 'view': view,
      if (loop != null) 'loop': loop,
      if (mirror != null) 'mirror': mirror,
      if (stepFrames != null) 'step_frames': stepFrames,
      if (highlight != null) 'highlight': highlight,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMotionsCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? tier,
    Value<String>? view,
    Value<String>? loop,
    Value<bool>? mirror,
    Value<String>? stepFrames,
    Value<String>? highlight,
    Value<Uint8List>? payload,
    Value<int>? rowid,
  }) {
    return ExerciseMotionsCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      tier: tier ?? this.tier,
      view: view ?? this.view,
      loop: loop ?? this.loop,
      mirror: mirror ?? this.mirror,
      stepFrames: stepFrames ?? this.stepFrames,
      highlight: highlight ?? this.highlight,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (view.present) {
      map['view'] = Variable<String>(view.value);
    }
    if (loop.present) {
      map['loop'] = Variable<String>(loop.value);
    }
    if (mirror.present) {
      map['mirror'] = Variable<bool>(mirror.value);
    }
    if (stepFrames.present) {
      map['step_frames'] = Variable<String>(stepFrames.value);
    }
    if (highlight.present) {
      map['highlight'] = Variable<String>(highlight.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMotionsCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('tier: $tier, ')
          ..write('view: $view, ')
          ..write('loop: $loop, ')
          ..write('mirror: $mirror, ')
          ..write('stepFrames: $stepFrames, ')
          ..write('highlight: $highlight, ')
          ..write('payload: $payload, ')
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
  late final $FlowsTable flows = $FlowsTable(this);
  late final $FlowStepsTable flowSteps = $FlowStepsTable(this);
  late final $ExerciseMotionsTable exerciseMotions = $ExerciseMotionsTable(
    this,
  );
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
    'CREATE INDEX exercises_name_norm ON exercises (name_norm, name)',
  );
  late final Index exerciseMusclesMuscle = Index(
    'exercise_muscles_muscle',
    'CREATE INDEX exercise_muscles_muscle ON exercise_muscles (muscle, role)',
  );
  late final Index exerciseEquipmentEquipment = Index(
    'exercise_equipment_equipment',
    'CREATE INDEX exercise_equipment_equipment ON exercise_equipment (equipment)',
  );
  late final Index flowsCategory = Index(
    'flows_category',
    'CREATE INDEX flows_category ON flows (category)',
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
    flows,
    flowSteps,
    exerciseMotions,
    exercisesCategory,
    exercisesTracking,
    exercisesDifficulty,
    exercisesNameNorm,
    exerciseMusclesMuscle,
    exerciseEquipmentEquipment,
    flowsCategory,
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
typedef $$FlowsTableCreateCompanionBuilder = FlowsCompanion Function({
  required String id,
  required String name,
  required String category,
  Value<String?> difficulty,
  required String description,
  required int totalDurationSec,
  required int rounds,
  required List<String> tags,
  Value<int> rowid,
});
typedef $$FlowsTableUpdateCompanionBuilder = FlowsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String?> difficulty,
  Value<String> description,
  Value<int> totalDurationSec,
  Value<int> rounds,
  Value<List<String>> tags,
  Value<int> rowid,
});

final class $$FlowsTableReferences
    extends BaseReferences<_$LibraryDatabase, $FlowsTable, LibraryFlowRow> {
  $$FlowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FlowStepsTable, List<LibraryFlowStepRow>>
  _flowStepsRefsTable(_$LibraryDatabase db) => MultiTypedResultKey.fromTable(
    db.flowSteps,
    aliasName: 'flows__id__flow_steps__flow_id',
  );

  $$FlowStepsTableProcessedTableManager get flowStepsRefs {
    final manager = $$FlowStepsTableTableManager(
      $_db,
      $_db.flowSteps,
    ).filter((f) => f.flowId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_flowStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FlowsTableFilterComposer
    extends Composer<_$LibraryDatabase, $FlowsTable> {
  $$FlowsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationSec => $composableBuilder(
    column: $table.totalDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> flowStepsRefs(
    Expression<bool> Function($$FlowStepsTableFilterComposer f) f,
  ) {
    final $$FlowStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flowSteps,
      getReferencedColumn: (t) => t.flowId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlowStepsTableFilterComposer(
            $db: $db,
            $table: $db.flowSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlowsTableOrderingComposer
    extends Composer<_$LibraryDatabase, $FlowsTable> {
  $$FlowsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationSec => $composableBuilder(
    column: $table.totalDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlowsTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $FlowsTable> {
  $$FlowsTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDurationSec => $composableBuilder(
    column: $table.totalDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> flowStepsRefs<T extends Object>(
    Expression<T> Function($$FlowStepsTableAnnotationComposer a) f,
  ) {
    final $$FlowStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flowSteps,
      getReferencedColumn: (t) => t.flowId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlowStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.flowSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FlowsTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $FlowsTable,
          LibraryFlowRow,
          $$FlowsTableFilterComposer,
          $$FlowsTableOrderingComposer,
          $$FlowsTableAnnotationComposer,
          $$FlowsTableCreateCompanionBuilder,
          $$FlowsTableUpdateCompanionBuilder,
          (LibraryFlowRow, $$FlowsTableReferences),
          LibraryFlowRow,
          PrefetchHooks Function({bool flowStepsRefs})
        > {
  $$FlowsTableTableManager(_$LibraryDatabase db, $FlowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> totalDurationSec = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<List<String>> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlowsCompanion(
                id: id,
                name: name,
                category: category,
                difficulty: difficulty,
                description: description,
                totalDurationSec: totalDurationSec,
                rounds: rounds,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                Value<String?> difficulty = const Value.absent(),
                required String description,
                required int totalDurationSec,
                required int rounds,
                required List<String> tags,
                Value<int> rowid = const Value.absent(),
              }) => FlowsCompanion.insert(
                id: id,
                name: name,
                category: category,
                difficulty: difficulty,
                description: description,
                totalDurationSec: totalDurationSec,
                rounds: rounds,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FlowsTable, LibraryFlowRow>(table),
                  $$FlowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flowStepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (flowStepsRefs) db.flowSteps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flowStepsRefs)
                    await $_getPrefetchedDataByColumns<
                      LibraryFlowRow,
                      $FlowsTable,
                      LibraryFlowStepRow,
                      $FlowStepsTable
                    >(
                      currentTable: table,
                      referencedTable: $$FlowsTableReferences
                          ._flowStepsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FlowsTableReferences(db, table, p0).flowStepsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'flow_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FlowsTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $FlowsTable,
      LibraryFlowRow,
      $$FlowsTableFilterComposer,
      $$FlowsTableOrderingComposer,
      $$FlowsTableAnnotationComposer,
      $$FlowsTableCreateCompanionBuilder,
      $$FlowsTableUpdateCompanionBuilder,
      (LibraryFlowRow, $$FlowsTableReferences),
      LibraryFlowRow,
      PrefetchHooks Function({bool flowStepsRefs})
    >;
typedef $$FlowStepsTableCreateCompanionBuilder = FlowStepsCompanion Function({
  required String flowId,
  required int position,
  required String exerciseId,
  Value<String?> label,
  required int holdSec,
  required int transitionSec,
  Value<String?> cue,
  Value<int> rowid,
});
typedef $$FlowStepsTableUpdateCompanionBuilder = FlowStepsCompanion Function({
  Value<String> flowId,
  Value<int> position,
  Value<String> exerciseId,
  Value<String?> label,
  Value<int> holdSec,
  Value<int> transitionSec,
  Value<String?> cue,
  Value<int> rowid,
});

final class $$FlowStepsTableReferences
    extends
        BaseReferences<_$LibraryDatabase, $FlowStepsTable, LibraryFlowStepRow> {
  $$FlowStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FlowsTable _flowIdTable(_$LibraryDatabase db) =>
      db.flows.createAlias('flow_steps__flow_id__flows__id');

  $$FlowsTableProcessedTableManager get flowId {
    final $_column = $_itemColumn<String>('flow_id')!;

    final manager = $$FlowsTableTableManager(
      $_db,
      $_db.flows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flowIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FlowStepsTableFilterComposer
    extends Composer<_$LibraryDatabase, $FlowStepsTable> {
  $$FlowStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get holdSec => $composableBuilder(
    column: $table.holdSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transitionSec => $composableBuilder(
    column: $table.transitionSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cue => $composableBuilder(
    column: $table.cue,
    builder: (column) => ColumnFilters(column),
  );

  $$FlowsTableFilterComposer get flowId {
    final $$FlowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flowId,
      referencedTable: $db.flows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlowsTableFilterComposer(
            $db: $db,
            $table: $db.flows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlowStepsTableOrderingComposer
    extends Composer<_$LibraryDatabase, $FlowStepsTable> {
  $$FlowStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get holdSec => $composableBuilder(
    column: $table.holdSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transitionSec => $composableBuilder(
    column: $table.transitionSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cue => $composableBuilder(
    column: $table.cue,
    builder: (column) => ColumnOrderings(column),
  );

  $$FlowsTableOrderingComposer get flowId {
    final $$FlowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flowId,
      referencedTable: $db.flows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlowsTableOrderingComposer(
            $db: $db,
            $table: $db.flows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlowStepsTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $FlowStepsTable> {
  $$FlowStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get holdSec =>
      $composableBuilder(column: $table.holdSec, builder: (column) => column);

  GeneratedColumn<int> get transitionSec => $composableBuilder(
    column: $table.transitionSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cue =>
      $composableBuilder(column: $table.cue, builder: (column) => column);

  $$FlowsTableAnnotationComposer get flowId {
    final $$FlowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flowId,
      referencedTable: $db.flows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlowsTableAnnotationComposer(
            $db: $db,
            $table: $db.flows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlowStepsTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $FlowStepsTable,
          LibraryFlowStepRow,
          $$FlowStepsTableFilterComposer,
          $$FlowStepsTableOrderingComposer,
          $$FlowStepsTableAnnotationComposer,
          $$FlowStepsTableCreateCompanionBuilder,
          $$FlowStepsTableUpdateCompanionBuilder,
          (LibraryFlowStepRow, $$FlowStepsTableReferences),
          LibraryFlowStepRow,
          PrefetchHooks Function({bool flowId})
        > {
  $$FlowStepsTableTableManager(_$LibraryDatabase db, $FlowStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlowStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlowStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlowStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> flowId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> holdSec = const Value.absent(),
                Value<int> transitionSec = const Value.absent(),
                Value<String?> cue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlowStepsCompanion(
                flowId: flowId,
                position: position,
                exerciseId: exerciseId,
                label: label,
                holdSec: holdSec,
                transitionSec: transitionSec,
                cue: cue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String flowId,
                required int position,
                required String exerciseId,
                Value<String?> label = const Value.absent(),
                required int holdSec,
                required int transitionSec,
                Value<String?> cue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlowStepsCompanion.insert(
                flowId: flowId,
                position: position,
                exerciseId: exerciseId,
                label: label,
                holdSec: holdSec,
                transitionSec: transitionSec,
                cue: cue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FlowStepsTable, LibraryFlowStepRow>(table),
                  $$FlowStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flowId = false}) {
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
                    if (flowId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.flowId,
                        referencedTable: $$FlowStepsTableReferences
                            ._flowIdTable(db),
                        referencedColumn: $$FlowStepsTableReferences
                            ._flowIdTable(db)
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

typedef $$FlowStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $FlowStepsTable,
      LibraryFlowStepRow,
      $$FlowStepsTableFilterComposer,
      $$FlowStepsTableOrderingComposer,
      $$FlowStepsTableAnnotationComposer,
      $$FlowStepsTableCreateCompanionBuilder,
      $$FlowStepsTableUpdateCompanionBuilder,
      (LibraryFlowStepRow, $$FlowStepsTableReferences),
      LibraryFlowStepRow,
      PrefetchHooks Function({bool flowId})
    >;
typedef $$ExerciseMotionsTableCreateCompanionBuilder =
    ExerciseMotionsCompanion Function({
      required String exerciseId,
      required String tier,
      required String view,
      required String loop,
      required bool mirror,
      required String stepFrames,
      required String highlight,
      required Uint8List payload,
      Value<int> rowid,
    });
typedef $$ExerciseMotionsTableUpdateCompanionBuilder =
    ExerciseMotionsCompanion Function({
      Value<String> exerciseId,
      Value<String> tier,
      Value<String> view,
      Value<String> loop,
      Value<bool> mirror,
      Value<String> stepFrames,
      Value<String> highlight,
      Value<Uint8List> payload,
      Value<int> rowid,
    });

class $$ExerciseMotionsTableFilterComposer
    extends Composer<_$LibraryDatabase, $ExerciseMotionsTable> {
  $$ExerciseMotionsTableFilterComposer({
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

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get view => $composableBuilder(
    column: $table.view,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loop => $composableBuilder(
    column: $table.loop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mirror => $composableBuilder(
    column: $table.mirror,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepFrames => $composableBuilder(
    column: $table.stepFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get highlight => $composableBuilder(
    column: $table.highlight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseMotionsTableOrderingComposer
    extends Composer<_$LibraryDatabase, $ExerciseMotionsTable> {
  $$ExerciseMotionsTableOrderingComposer({
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

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get view => $composableBuilder(
    column: $table.view,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loop => $composableBuilder(
    column: $table.loop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mirror => $composableBuilder(
    column: $table.mirror,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepFrames => $composableBuilder(
    column: $table.stepFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get highlight => $composableBuilder(
    column: $table.highlight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseMotionsTableAnnotationComposer
    extends Composer<_$LibraryDatabase, $ExerciseMotionsTable> {
  $$ExerciseMotionsTableAnnotationComposer({
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

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get view =>
      $composableBuilder(column: $table.view, builder: (column) => column);

  GeneratedColumn<String> get loop =>
      $composableBuilder(column: $table.loop, builder: (column) => column);

  GeneratedColumn<bool> get mirror =>
      $composableBuilder(column: $table.mirror, builder: (column) => column);

  GeneratedColumn<String> get stepFrames => $composableBuilder(
    column: $table.stepFrames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get highlight =>
      $composableBuilder(column: $table.highlight, builder: (column) => column);

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$ExerciseMotionsTableTableManager
    extends
        RootTableManager<
          _$LibraryDatabase,
          $ExerciseMotionsTable,
          ExerciseMotionRow,
          $$ExerciseMotionsTableFilterComposer,
          $$ExerciseMotionsTableOrderingComposer,
          $$ExerciseMotionsTableAnnotationComposer,
          $$ExerciseMotionsTableCreateCompanionBuilder,
          $$ExerciseMotionsTableUpdateCompanionBuilder,
          (
            ExerciseMotionRow,
            BaseReferences<
              _$LibraryDatabase,
              $ExerciseMotionsTable,
              ExerciseMotionRow
            >,
          ),
          ExerciseMotionRow,
          PrefetchHooks Function()
        > {
  $$ExerciseMotionsTableTableManager(
    _$LibraryDatabase db,
    $ExerciseMotionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMotionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMotionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseMotionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<String> view = const Value.absent(),
                Value<String> loop = const Value.absent(),
                Value<bool> mirror = const Value.absent(),
                Value<String> stepFrames = const Value.absent(),
                Value<String> highlight = const Value.absent(),
                Value<Uint8List> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMotionsCompanion(
                exerciseId: exerciseId,
                tier: tier,
                view: view,
                loop: loop,
                mirror: mirror,
                stepFrames: stepFrames,
                highlight: highlight,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String tier,
                required String view,
                required String loop,
                required bool mirror,
                required String stepFrames,
                required String highlight,
                required Uint8List payload,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMotionsCompanion.insert(
                exerciseId: exerciseId,
                tier: tier,
                view: view,
                loop: loop,
                mirror: mirror,
                stepFrames: stepFrames,
                highlight: highlight,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseMotionsTable, ExerciseMotionRow>(table),
                  BaseReferences<
                    _$LibraryDatabase,
                    $ExerciseMotionsTable,
                    ExerciseMotionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseMotionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LibraryDatabase,
      $ExerciseMotionsTable,
      ExerciseMotionRow,
      $$ExerciseMotionsTableFilterComposer,
      $$ExerciseMotionsTableOrderingComposer,
      $$ExerciseMotionsTableAnnotationComposer,
      $$ExerciseMotionsTableCreateCompanionBuilder,
      $$ExerciseMotionsTableUpdateCompanionBuilder,
      (
        ExerciseMotionRow,
        BaseReferences<
          _$LibraryDatabase,
          $ExerciseMotionsTable,
          ExerciseMotionRow
        >,
      ),
      ExerciseMotionRow,
      PrefetchHooks Function()
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
  $$FlowsTableTableManager get flows =>
      $$FlowsTableTableManager(_db, _db.flows);
  $$FlowStepsTableTableManager get flowSteps =>
      $$FlowStepsTableTableManager(_db, _db.flowSteps);
  $$ExerciseMotionsTableTableManager get exerciseMotions =>
      $$ExerciseMotionsTableTableManager(_db, _db.exerciseMotions);
}
