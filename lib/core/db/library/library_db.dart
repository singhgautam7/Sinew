import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../converters.dart';

part 'library_db.g.dart';

// PURE DART: no Flutter imports in this file. `tool/build_library_db.dart`
// creates and fills the asset with this exact class, so the app and the build
// script can never disagree about the schema.

/// Build metadata: `libraryVersion`, `schemaVersion`, `builtAt`, `sha256`.
@DataClassName('LibraryMetaRow')
class LibraryMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

/// One row per exercise. [seq] is the integer rowid the FTS index points at;
/// [id] is the stable key user data references.
@DataClassName('LibraryExerciseRow')
@TableIndex(name: 'exercises_category', columns: <Symbol>{#category})
@TableIndex(name: 'exercises_tracking', columns: <Symbol>{#trackingType})
@TableIndex(name: 'exercises_difficulty', columns: <Symbol>{#difficulty})
@TableIndex(name: 'exercises_name_norm', columns: <Symbol>{#nameNorm})
class Exercises extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get id => text().unique()();
  TextColumn get name => text()();

  /// Lowercased, diacritics and punctuation stripped: exact and prefix lookup
  /// and the default sort.
  TextColumn get nameNorm => text()();
  TextColumn get aliases => text().map(const StringListConverter())();
  TextColumn get sanskritName => text().nullable()();
  TextColumn get category => text()();
  TextColumn get subcategory => text().nullable()();

  /// Stored by name and parsed with a fallback, so a newer library with a
  /// tracking type this build does not know still opens.
  TextColumn get trackingType => text()();
  TextColumn get primaryMuscles => text().map(const StringListConverter())();
  TextColumn get secondaryMuscles => text().map(const StringListConverter())();
  TextColumn get equipment => text().map(const StringListConverter())();
  TextColumn get difficulty => text().nullable()();
  BoolColumn get unilateral => boolean()();
  TextColumn get mechanic => text().nullable()();
  TextColumn get force => text().nullable()();
  TextColumn get steps => text().map(const StringListConverter())();
  TextColumn get tips => text().map(const StringListConverter())();
  TextColumn get commonMistakes => text().map(const StringListConverter())();
  TextColumn get safetyNotes => text().map(const StringListConverter())();
  TextColumn get contraindications => text().map(const StringListConverter())();
  RealColumn get metValue => real().nullable()();
  IntColumn get defaultRestSec => integer().nullable()();
  IntColumn get defaultHoldSec => integer().nullable()();
  TextColumn get variationOf => text().nullable()();
  TextColumn get tags => text().map(const StringListConverter())();
  TextColumn get source => text().nullable()();
  TextColumn get license => text().nullable()();
}

/// Muscle filter. role is `primary` or `secondary`.
@DataClassName('ExerciseMuscleRow')
@TableIndex(name: 'exercise_muscles_muscle', columns: <Symbol>{#muscle, #role})
class ExerciseMuscles extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get muscle => text()();
  TextColumn get role => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{exerciseId, muscle};
}

@DataClassName('ExerciseEquipmentRow')
@TableIndex(name: 'exercise_equipment_equipment', columns: <Symbol>{#equipment})
class ExerciseEquipment extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get equipment => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{exerciseId, equipment};
}

/// The bundled, read-only exercise library.
///
/// The app opens it with [LibraryDatabase.openReadOnly]; only the build tool
/// and tests create one ([LibraryDatabase.forBuild]). The FTS5 index
/// `exercises_fts(name, aliases, muscles)` is contentless and keyed by
/// `exercises.seq`; it is created here in [migration] and filled by the tool.
@DriftDatabase(
  tables: <Type>[LibraryMeta, Exercises, ExerciseMuscles, ExerciseEquipment],
)
class LibraryDatabase extends _$LibraryDatabase {
  LibraryDatabase._(super.executor, {required this.writable});

  /// Opens the installed asset read-only on a background isolate, so search
  /// never runs on the UI isolate. `query_only` makes any write throw.
  factory LibraryDatabase.openReadOnly(File file) => LibraryDatabase._(
    NativeDatabase.createInBackground(
      file,
      setup: (rawDb) => rawDb.execute('PRAGMA query_only = ON'),
    ),
    writable: false,
  );

  /// For `tool/build_library_db.dart` and tests: creates the schema.
  factory LibraryDatabase.forBuild(QueryExecutor executor) =>
      LibraryDatabase._(executor, writable: true);

  final bool writable;

  /// The library file format. Bumped when the tables above change; the asset
  /// is rebuilt, never migrated (it is replaced wholesale on app update).
  static const int currentSchemaVersion = 1;

  static const String ftsTable = 'exercises_fts';

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      if (!writable) {
        throw StateError('The exercise library is missing its schema.');
      }
      await m.createAll();
      await customStatement(
        'CREATE VIRTUAL TABLE $ftsTable USING fts5('
        'name, aliases, muscles, '
        "content='', "
        "tokenize='unicode61 remove_diacritics 2', prefix='2 3')",
      );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Never migrated in place: a mismatched asset is reinstalled by the
      // installer before this opens.
      throw LibrarySchemaMismatch(from, to);
    },
  );

  Future<String?> meta(String key) async {
    final LibraryMetaRow? row = await (select(
      libraryMeta,
    )..where(($LibraryMetaTable t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }
}

class LibrarySchemaMismatch implements Exception {
  const LibrarySchemaMismatch(this.found, this.expected);

  final int found;
  final int expected;

  @override
  String toString() =>
      'LibrarySchemaMismatch: asset is $found, this build reads $expected';
}
