import 'dart:io';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The bundled library asset is not in this build yet (before Phase 2), or
/// the bundle is broken.
class LibraryAssetMissing implements Exception {
  const LibraryAssetMissing(this.asset);

  final String asset;

  @override
  String toString() => 'LibraryAssetMissing($asset)';
}

/// Copies the prebuilt, read-only exercise library out of the bundle into
/// application support on first run, and again whenever the bundled version
/// is newer. A copy, never a parse-and-insert (Mull rule D2). The version
/// travels beside it as `library.version`, so deciding needs no database open.
class LibraryInstaller {
  LibraryInstaller({
    required this.prefs,
    required this.directory,
    AssetBundle? bundle,
  }) : bundle = bundle ?? rootBundle;

  final SharedPreferences prefs;

  /// Application support in the app; a temp directory in tests.
  final Directory directory;
  final AssetBundle bundle;

  static const String assetDb = 'assets/db/library.sqlite';
  static const String assetVersion = 'assets/db/library.version';
  static const String prefsKey = 'library.version';

  String get dbPath => p.join(directory.path, 'library.sqlite');

  static Future<LibraryInstaller> forApp(SharedPreferences prefs) async =>
      LibraryInstaller(
        prefs: prefs,
        directory: await getApplicationSupportDirectory(),
      );

  Future<String> bundledVersion() async {
    try {
      return (await bundle.loadString(assetVersion)).trim();
    } on FlutterError {
      throw const LibraryAssetMissing(assetVersion);
    }
  }

  /// The version installed on this device, or null before the first run.
  String? get installedVersion =>
      File(dbPath).existsSync() ? prefs.getString(prefsKey) : null;

  /// Installs if needed and returns the ready file. [beforeReplace] runs
  /// with the old file still in place when an older library is about to be
  /// replaced (Phase 2 snapshots tombstones there).
  Future<File> ensureInstalled({
    Future<void> Function(File oldLibrary, String newVersion)? beforeReplace,
  }) async {
    final String bundled = await bundledVersion();
    final String? installed = installedVersion;
    if (installed == bundled) return File(dbPath);
    if (installed != null && beforeReplace != null) {
      await beforeReplace(File(dbPath), bundled);
    }
    await _install(bundled);
    return File(dbPath);
  }

  Future<void> _install(String version) async {
    final ByteData data;
    try {
      data = await bundle.load(assetDb);
    } on FlutterError {
      throw const LibraryAssetMissing(assetDb);
    }
    await directory.create(recursive: true);
    // Written to a sibling and renamed, so a crash mid-way never leaves a
    // half-written library for the next launch to open.
    final File tmp = File(
      '$dbPath.${DateTime.now().microsecondsSinceEpoch}.part',
    );
    await tmp.writeAsBytes(
      Uint8List.sublistView(
        data.buffer.asUint8List(),
        data.offsetInBytes,
        data.offsetInBytes + data.lengthInBytes,
      ),
      flush: true,
    );
    await tmp.rename(dbPath);
    await prefs.setString(prefsKey, version);
  }
}
