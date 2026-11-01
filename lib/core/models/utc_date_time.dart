import 'package:freezed_annotation/freezed_annotation.dart';

// PURE DART.

/// Serialises an instant as UTC ISO-8601 with a `Z` and parses back to UTC, so
/// a backup restored in another time zone keeps every instant (and the
/// newer-wins comparison on `updatedAt` stays honest).
///
/// A string without an offset (written by an older build) is read as local
/// time, which is what that build meant by it.
class UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toUtc();

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}

/// [UtcDateTimeConverter] for a nullable field.
class NullableUtcDateTimeConverter
    implements JsonConverter<DateTime?, String?> {
  const NullableUtcDateTimeConverter();

  @override
  DateTime? fromJson(String? json) =>
      json == null ? null : DateTime.parse(json).toUtc();

  @override
  String? toJson(DateTime? object) => object?.toUtc().toIso8601String();
}
