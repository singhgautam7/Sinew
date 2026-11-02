import 'dart:io';

import 'package:sinew/core/db/library/library_builder.dart';
import 'package:sinew/core/db/library/library_db.dart';

/// A minimal source record, like one in specs/data/exercises.json.
Map<String, Object?> exerciseJson(
  String id,
  String name, {
  String category = 'strength',
  String trackingType = 'weightReps',
  List<String> primary = const <String>['chest'],
  List<String> secondary = const <String>[],
  List<String> equipment = const <String>['barbell'],
  List<String> aliases = const <String>[],
  String? difficulty = 'intermediate',
  String? sanskritName,
  bool unilateral = false,
}) => <String, Object?>{
  'id': id,
  'name': name,
  'aliases': aliases,
  'sanskritName': sanskritName,
  'category': category,
  'subcategory': null,
  'trackingType': trackingType,
  'primaryMuscles': primary,
  'secondaryMuscles': secondary,
  'equipment': equipment,
  'difficulty': difficulty,
  'unilateral': unilateral,
  'mechanic': null,
  'force': null,
  'steps': <String>[],
  'tips': <String>[],
  'commonMistakes': <String>[],
  'safetyNotes': <String>[],
  'contraindications': <String>[],
  'metValue': 4.0,
  'defaultRestSec': 60,
  'defaultHoldSec': null,
  'variationOf': null,
  'tags': <String>[],
  'source': 'curated',
  'license': 'own',
};

/// Builds a small library file with the real builder and returns it.
Future<File> buildTestLibrary(
  Directory dir, {
  String fileName = 'library.sqlite',
  String version = '1.0.0',
  required List<Map<String, Object?>> exercises,
  List<Object?> flows = const <Object?>[],
}) async {
  final File out = File('${dir.path}/$fileName');
  await const LibraryBuilder().build(
    output: out,
    exercises: exercises,
    flows: flows,
    libraryVersion: version,
    builtAt: '2026-01-01T00:00:00Z',
    sha256: 'test',
  );
  return out;
}

/// Opens a built file the way the app does.
LibraryDatabase openLibrary(File file) => LibraryDatabase.openReadOnly(file);
