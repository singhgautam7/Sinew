import 'dart:math';

// PURE DART.

final Random _random = Random.secure();

/// A random RFC 4122 version 4 id. Text ids let a backup merge by id across
/// devices without collisions; no package needed for 16 random bytes.
String newId() {
  final List<int> b = List<int>.generate(16, (_) => _random.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String hex(int from, int to) => b
      .sublist(from, to)
      .map((int x) => x.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

/// The time source repositories stamp `updatedAt` with. Injected so tests
/// can control it. Always UTC.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now().toUtc();
