import 'dart:io' show FileSystemException;

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/core/share/share_service.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// [ShareService] over the share_plus plugin. The plugin writes the bytes to
/// a temporary file itself before handing it to the OS.
class SharePlusShareService implements ShareService {
  /// [share] stands in for the plugin in tests.
  new({Future<ShareResult> Function(ShareParams params)? share})
    : _share = share ?? SharePlus.instance.share;

  final Future<ShareResult> Function(ShareParams params) _share;

  @override
  Future<Result<ShareOutcome, ShareFailure>> sharePng({
    required Uint8List bytes,
    required String fileName,
    required String text,
    Rect? origin,
  }) async {
    try {
      final result = await _share(
        ShareParams(
          text: text,
          files: [XFile.fromData(bytes, mimeType: 'image/png')],
          // XFile.fromData ignores its own name on every platform but web.
          fileNameOverrides: [fileName],
          sharePositionOrigin: origin,
        ),
      );
      return Ok(switch (result.status) {
        ShareResultStatus.success => ShareOutcome.shared,
        ShareResultStatus.dismissed => ShareOutcome.dismissed,
        ShareResultStatus.unavailable => ShareOutcome.unknown,
      });
    } on PlatformException catch (error, stackTrace) {
      return _failed(error, stackTrace);
    } on MissingPluginException catch (error, stackTrace) {
      return _failed(error, stackTrace);
    } on FileSystemException catch (error, stackTrace) {
      return _failed(error, stackTrace);
    }
  }

  static Result<ShareOutcome, ShareFailure> _failed(
    Object error,
    StackTrace stackTrace,
  ) {
    AppLog.error('share.platform_failed', error, stackTrace);
    return const Err(SharePlatformFailed());
  }
}
