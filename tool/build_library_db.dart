// Builds the bundled exercise library:
//
//   dart run tool/build_library_db.dart
//
// Reads specs/data/exercises.json (falls back to exercises.sample.json),
// flows.json and manifest.json, and writes assets/db/library.sqlite and
// assets/db/library.version with the very same Drift class the app opens.
//
// Deterministic: the same inputs give the same bytes (no clock is read;
// `builtAt` comes from the manifest). Verified by building twice and comparing
// SHA-256, see test/db/library_build_test.dart.
//
// Pure Dart, no Flutter.
import 'dart:convert';
import 'dart:io';

import 'package:sinew/core/db/library/library_builder.dart';

Future<void> main(List<String> args) async {
  final Directory root = Directory.current;
  final String dataDir = '${root.path}/specs/data';
  File exercisesFile = File('$dataDir/exercises.json');
  if (!exercisesFile.existsSync()) {
    exercisesFile = File('$dataDir/exercises.sample.json');
    stdout.writeln('exercises.json missing, using exercises.sample.json');
  }
  if (!exercisesFile.existsSync()) {
    stderr.writeln('No exercises file in $dataDir');
    exitCode = 2;
    return;
  }
  final File manifestFile = File('$dataDir/manifest.json');
  final File flowsFile = File('$dataDir/flows.json');
  File motionsFile = File('$dataDir/motions.json');
  if (!motionsFile.existsSync()) {
    motionsFile = File('$dataDir/motions.sample.json');
  }

  final List<int> exerciseBytes = exercisesFile.readAsBytesSync();
  final Object? exercises = jsonDecode(utf8.decode(exerciseBytes));
  if (exercises is! List<Object?>) {
    stderr.writeln('${exercisesFile.path} must be a JSON array');
    exitCode = 2;
    return;
  }
  final Object? flows = flowsFile.existsSync()
      ? jsonDecode(flowsFile.readAsStringSync())
      : <Object?>[];
  if (flows is! List<Object?>) {
    stderr.writeln('${flowsFile.path} must be a JSON array');
    exitCode = 2;
    return;
  }
  final Object? motions = motionsFile.existsSync()
      ? jsonDecode(motionsFile.readAsStringSync())
      : <Object?>[];
  if (motions is! List<Object?>) {
    stderr.writeln('${motionsFile.path} must be a JSON array');
    exitCode = 2;
    return;
  }
  final Map<String, Object?> manifest = manifestFile.existsSync()
      ? (jsonDecode(manifestFile.readAsStringSync()) as Map<String, Object?>)
      : <String, Object?>{};
  final String version = (manifest['libraryVersion'] as String?) ?? '0.0.0';
  final String builtAt =
      (manifest['builtAt'] as String?) ?? '1970-01-01T00:00:00Z';
  final String digest = sha256Hex(exerciseBytes);

  final File out = File('${root.path}/assets/db/library.sqlite');
  final LibraryBuildReport report;
  try {
    report = await const LibraryBuilder().build(
      output: out,
      exercises: exercises,
      flows: flows,
      motions: motions,
      libraryVersion: version,
      builtAt: builtAt,
      sha256: digest,
    );
  } on LibraryBuildError catch (e) {
    stderr.writeln(e);
    exitCode = 1;
    return;
  }
  File('${root.path}/assets/db/library.version').writeAsStringSync(version);

  final String? expected =
      ((manifest['sha256'] as Map<String, Object?>?)?['exercises.json'])
          as String?;
  if (exercisesFile.path.endsWith('/exercises.json') &&
      expected != null &&
      expected != digest) {
    stdout.writeln('WARNING: exercises.json hash differs from manifest.json');
  }
  stdout.writeln('library $version  sha256 ${digest.substring(0, 12)}');
  stdout.writeln(
    '${report.exerciseCount} exercises, ${report.flowCount} flows, ${report.motionCount} motions',
  );
  stdout.writeln(
    'average payload size: ${report.averagePayloadBytes.toStringAsFixed(1)} bytes',
  );
  final List<MapEntry<String, int>> cats = report.countsByCategory.entries
      .toList();
  for (final MapEntry<String, int> e in cats) {
    stdout.writeln('  ${e.key.padRight(14)} ${e.value}');
  }
  for (final String w in report.warnings) {
    stdout.writeln('WARNING: $w');
  }
  stdout.writeln('wrote ${out.path} (${out.lengthSync()} bytes)');
}

// SHA-256 (FIPS 180-4). The `crypto` package is only a transitive dependency
// here and none may be added, so the 40 lines live in the tool.
String sha256Hex(List<int> data) {
  const List<int> k = <int>[
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, //
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];
  final List<int> h = <int>[
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, //
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];
  const int mask = 0xffffffff;
  int rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & mask;

  final int bitLength = data.length * 8;
  final List<int> msg = <int>[...data, 0x80];
  while (msg.length % 64 != 56) {
    msg.add(0);
  }
  for (int i = 7; i >= 0; i--) {
    msg.add((bitLength >> (i * 8)) & 0xff);
  }
  final List<int> w = List<int>.filled(64, 0);
  for (int offset = 0; offset < msg.length; offset += 64) {
    for (int i = 0; i < 16; i++) {
      final int j = offset + i * 4;
      w[i] =
          (msg[j] << 24) | (msg[j + 1] << 16) | (msg[j + 2] << 8) | msg[j + 3];
    }
    for (int i = 16; i < 64; i++) {
      final int s0 =
          rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final int s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & mask;
    }
    int a = h[0], b = h[1], c = h[2], d = h[3];
    int e = h[4], f = h[5], g = h[6], hh = h[7];
    for (int i = 0; i < 64; i++) {
      final int s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
      final int ch = (e & f) ^ (~e & mask & g);
      final int t1 = (hh + s1 + ch + k[i] + w[i]) & mask;
      final int s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
      final int maj = (a & b) ^ (a & c) ^ (b & c);
      final int t2 = (s0 + maj) & mask;
      hh = g;
      g = f;
      f = e;
      e = (d + t1) & mask;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & mask;
    }
    h[0] = (h[0] + a) & mask;
    h[1] = (h[1] + b) & mask;
    h[2] = (h[2] + c) & mask;
    h[3] = (h[3] + d) & mask;
    h[4] = (h[4] + e) & mask;
    h[5] = (h[5] + f) & mask;
    h[6] = (h[6] + g) & mask;
    h[7] = (h[7] + hh) & mask;
  }
  return h.map((int x) => x.toRadixString(16).padLeft(8, '0')).join();
}
