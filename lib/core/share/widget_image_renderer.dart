import 'dart:typed_data';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:flutter/widgets.dart';

/// Draws a widget that is never shown on screen into a PNG.
abstract interface class WidgetImageRenderer {
  /// Lays [widget] out [width] logical pixels wide, at its natural height,
  /// and encodes it at [pixelRatio] physical pixels per logical pixel.
  ///
  /// [context] is used only synchronously, before the first frame is
  /// awaited, so the widget inherits the app's localizations. A drawing
  /// that fails is a [ShareRenderFailed], never a throw.
  Future<Result<Uint8List, ShareFailure>> renderPng(
    BuildContext context,
    Widget widget, {
    required double width,
    required double pixelRatio,
  });
}
