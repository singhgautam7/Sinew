import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// A file the person chose, read into memory as text.
class PickedTextFile {
  const PickedTextFile({required this.name, required this.text, this.size});

  final String name;
  final String text;
  final int? size;
}

/// Where backups and exports go in and out of the app: the system file
/// picker and the share sheet. A seam so tests can stand in for the phone;
/// the real one never opens a network connection (the files are the
/// person's, handed to an app they choose).
abstract class BackupFileIo {
  /// Lets the person pick a file. Null when they cancel.
  Future<PickedTextFile?> pickText();

  /// Saves [bytes] where the person chooses. True when it was saved.
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
    String mimeType = 'application/octet-stream',
  });

  /// Offers [files] to the share sheet. Each is `(name, bytes, mimeType)`.
  Future<void> share(
    List<({String name, Uint8List bytes, String mimeType})> files,
  );
}

class PlatformBackupFileIo implements BackupFileIo {
  const PlatformBackupFileIo();

  @override
  Future<PickedTextFile?> pickText() async {
    // Any type: some phones label a .json file with no useful MIME type, so
    // filtering by type would hide valid backups. The content is validated.
    final List<PlatformFile> picked = await FilePicker.pickFiles();
    if (picked.isEmpty) return null;
    final PlatformFile f = picked.first;
    final Uint8List bytes = await f.readAsBytes();
    return PickedTextFile(
      name: f.name,
      text: utf8.decode(bytes, allowMalformed: true),
      size: bytes.length,
    );
  }

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
    String mimeType = 'application/octet-stream',
  }) async {
    final Uri? where = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
    );
    return where != null;
  }

  @override
  Future<void> share(
    List<({String name, Uint8List bytes, String mimeType})> files,
  ) async {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          for (final ({String name, Uint8List bytes, String mimeType}) f
              in files)
            XFile.fromData(f.bytes, name: f.name, mimeType: f.mimeType),
        ],
      ),
    );
  }
}

final Provider<BackupFileIo> backupFileIoProvider = Provider<BackupFileIo>(
  (Ref ref) => const PlatformBackupFileIo(),
);
