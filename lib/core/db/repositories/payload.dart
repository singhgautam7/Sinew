// PURE DART.

/// Thrown when a stored JSON payload is from a newer build. Callers fall back
/// to a default rather than crash.
class UnsupportedPayloadVersion implements Exception {
  const UnsupportedPayloadVersion(this.what, this.found, this.supported);

  final String what;
  final int found;
  final int supported;

  @override
  String toString() =>
      'UnsupportedPayloadVersion($what): found $found, supports $supported';
}

/// Reads `schemaVersion` from a JSON payload (missing means 1).
int payloadVersion(Map<String, dynamic> json) =>
    (json['schemaVersion'] as num?)?.toInt() ?? 1;
