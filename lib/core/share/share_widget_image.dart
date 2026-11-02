import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/share/share_service.dart';
import 'package:fasomo/core/share/widget_image_renderer.dart';
import 'package:flutter/widgets.dart';

/// Draws a widget into an image, then shares it with a short text.
class ShareWidgetImage {
  const new({required this.renderer, required this.shareService});

  /// Width of a shared image in logical pixels; with [pixelRatio] it is
  /// 1080 physical pixels, a size every social app takes without scaling.
  static const double width = 360;
  static const double pixelRatio = 3;

  final WidgetImageRenderer renderer;
  final ShareService shareService;

  /// Shares [image] as `fileName`. Nothing is shared when the image cannot
  /// be drawn. [context] is only read before the first await.
  Future<Result<ShareOutcome, ShareFailure>> call(
    BuildContext context, {
    required Widget image,
    required String fileName,
    required String text,
    Rect? origin,
  }) async {
    final rendered = await renderer.renderPng(
      context,
      image,
      width: width,
      pixelRatio: pixelRatio,
    );
    switch (rendered) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final bytes):
        return await shareService.sharePng(
          bytes: bytes,
          fileName: fileName,
          text: text,
          origin: origin,
        );
    }
  }
}
