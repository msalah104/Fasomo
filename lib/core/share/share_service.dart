import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';

/// How the person left the share sheet.
enum ShareOutcome {
  /// They picked an app or action.
  shared,

  /// They closed the sheet without sharing.
  dismissed,

  /// The platform does not report what they did.
  unknown,
}

/// The OS share sheet. The live implementation wraps the share plugin; tests
/// use a fake.
abstract interface class ShareService {
  /// Opens the share sheet with a PNG image named [fileName] and [text].
  ///
  /// [origin] is the global rectangle of the control that asked to share,
  /// which an iPad anchors its share popover to. A sheet that cannot be
  /// opened is a [SharePlatformFailed], never a throw.
  Future<Result<ShareOutcome, ShareFailure>> sharePng({
    required Uint8List bytes,
    required String fileName,
    required String text,
    Rect? origin,
  });
}
