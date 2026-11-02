import 'dart:ui' as ui;

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/core/share/widget_image_renderer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// [WidgetImageRenderer] that paints the widget for one frame in the root
/// overlay, far outside the screen, inside a [RepaintBoundary], and reads
/// that boundary back as an image.
///
/// Painting it within the app keeps the app's localizations, fonts and
/// media query; it is hidden from hit testing and from screen readers, and
/// it is removed again straight after the capture.
class OverlayWidgetImageRenderer implements WidgetImageRenderer {
  const new();

  @override
  Future<Result<Uint8List, ShareFailure>> renderPng(
    BuildContext context,
    Widget widget, {
    required double width,
    required double pixelRatio,
  }) async {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return const Err(ShareRenderFailed());

    final boundaryKey = GlobalKey();
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        // Outside the screen in either text direction.
        left: -4 * width,
        top: 0,
        width: width,
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: RepaintBoundary(key: boundaryKey, child: widget),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    try {
      SchedulerBinding.instance.scheduleFrame();
      await SchedulerBinding.instance.endOfFrame;
      final boundary = boundaryKey.currentContext?.findRenderObject();
      // After a frame, an attached, laid-out boundary has also been painted.
      if (boundary is! RenderRepaintBoundary ||
          !boundary.attached ||
          !boundary.hasSize) {
        return const Err(ShareRenderFailed());
      }
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data == null
            ? const Err(ShareRenderFailed())
            : Ok(data.buffer.asUint8List());
      } finally {
        image.dispose();
      }
    } on Exception catch (error, stackTrace) {
      // The engine reports an image it cannot create as a plain Exception.
      AppLog.error('share.render_failed', error, stackTrace);
      return const Err(ShareRenderFailed());
    } finally {
      entry
        ..remove()
        ..dispose();
    }
  }
}
