import 'package:flutter/widgets.dart';

/// Opens the exercise picker (library search, filters, custom exercises) and
/// returns the chosen exercise ids in the order picked, or null if cancelled.
///
/// CONTRACT used by Train (routine editor, add exercise, swap) and Today.
/// Owned and implemented by the Library feature; the signature is fixed.
/// - [multiple]: false returns at most one id (swap an exercise).
/// - [exclude]: ids already in the routine/session, shown as added.
/// - [title]: sheet title, e.g. "Add exercises", "Swap exercise".
Future<List<String>?> pickExercises(
  BuildContext context, {
  bool multiple = true,
  Set<String> exclude = const <String>{},
  String? title,
}) async {
  // Placeholder until the Library feature lands.
  return null;
}
