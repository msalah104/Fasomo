import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:fasomo/core/backup/backup_file_gateway.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// [BackupFileGateway] on the OS share sheet (`share_plus`) and document
/// picker (`file_picker`). The only place either plugin is used.
final class PlatformBackupFileGateway implements BackupFileGateway {
  const new();

  /// Far above any real backup: years of daily entries are well under 1 MB.
  static const int maxBytes = 5 * 1024 * 1024;

  /// A UTF-8 byte order mark, which some editors add when saving.
  static const String _byteOrderMark = '﻿';

  @override
  Future<Result<void, BackupFailure>> share(BackupFile file) async {
    final String path;
    try {
      path = await _writeAtomically(file);
    } on FileSystemException catch (e, st) {
      AppLog.error('backup.file.write', e, st);
      return const Err(BackupFileFailed('write'));
    } on MissingPlatformDirectoryException catch (e, st) {
      AppLog.error('backup.file.write', e, st);
      return const Err(BackupFileFailed('write'));
    }
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'application/json')],
          fileNameOverrides: [file.fileName],
          sharePositionOrigin: _screenCentre(),
        ),
      );
      return switch (result.status) {
        ShareResultStatus.dismissed => const Err(BackupCancelled()),
        ShareResultStatus.success ||
        ShareResultStatus.unavailable => const Ok(null),
      };
    } on PlatformException catch (e, st) {
      AppLog.error('backup.file.share', e, st);
      return const Err(BackupFileFailed('share'));
    }
  }

  @override
  Future<Result<String, BackupFailure>> pick() async {
    final PlatformFile? picked;
    try {
      // Any type: many file managers do not tag .json files as JSON.
      picked = await FilePicker.pickFile();
    } on PlatformException catch (e, st) {
      AppLog.error('backup.file.pick', e, st);
      return const Err(BackupFileFailed('pick'));
    }
    if (picked == null) return const Err(BackupCancelled());

    final List<int> bytes;
    try {
      final length = await picked.length();
      if (length != null && length > maxBytes) {
        return const Err(BackupMalformed());
      }
      bytes = await picked.readAsBytes();
    } on FileSystemException catch (e, st) {
      AppLog.error('backup.file.read', e, st);
      return const Err(BackupFileFailed('read'));
    } on PlatformException catch (e, st) {
      AppLog.error('backup.file.read', e, st);
      return const Err(BackupFileFailed('read'));
    }
    if (bytes.length > maxBytes) return const Err(BackupMalformed());

    try {
      final text = utf8.decode(bytes);
      return Ok(
        text.startsWith(_byteOrderMark)
            ? text.substring(_byteOrderMark.length)
            : text,
      );
    } on FormatException catch (e, st) {
      AppLog.error('backup.file.decode', e, st);
      return const Err(BackupMalformed());
    }
  }

  /// Writes [file] into a fresh `backups` folder in the app's temp
  /// directory and returns its path. The text goes to a `.part` file that is
  /// renamed only once flushed, so a half-written backup is never shared.
  /// The previous export's file is deleted first.
  static Future<String> _writeAtomically(BackupFile file) async {
    final temp = await getTemporaryDirectory();
    final folder = Directory('${temp.path}/backups');
    if (folder.existsSync()) await folder.delete(recursive: true);
    await folder.create(recursive: true);
    final partial = File('${folder.path}/${file.fileName}.part');
    try {
      await partial.writeAsString(file.contents, flush: true);
      final published = await partial.rename('${folder.path}/${file.fileName}');
      return published.path;
    } on FileSystemException {
      if (partial.existsSync()) await partial.delete();
      rethrow;
    }
  }

  /// Where an iPad anchors the share popover: the middle of the screen,
  /// since the gateway has no widget to point at. Ignored on phones.
  static Rect? _screenCentre() {
    final view = PlatformDispatcher.instance.views.firstOrNull;
    if (view == null) return null;
    final size = view.physicalSize / view.devicePixelRatio;
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: 1,
      height: 1,
    );
  }
}
