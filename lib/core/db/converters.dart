import 'dart:convert';

import 'package:drift/drift.dart';

// PURE DART: shared by the user database and the library database (which the
// build tool runs outside Flutter).

/// A JSON list of strings in a TEXT column.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
