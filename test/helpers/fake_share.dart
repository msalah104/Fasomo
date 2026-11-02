import 'dart:typed_data';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/share/share_service.dart';
import 'package:fasomo/core/share/widget_image_renderer.dart';
import 'package:flutter/widgets.dart';

/// One call to [FakeShareService.sharePng].
typedef SharedPng = ({
  Uint8List bytes,
  String fileName,
  String text,
  Rect? origin,
});

/// Records what was shared and answers with [result].
class FakeShareService implements ShareService {
  new({this.result = const Ok(ShareOutcome.shared)});

  final Result<ShareOutcome, ShareFailure> result;
  final List<SharedPng> shared = [];

  @override
  Future<Result<ShareOutcome, ShareFailure>> sharePng({
    required Uint8List bytes,
    required String fileName,
    required String text,
    Rect? origin,
  }) async {
    shared.add((bytes: bytes, fileName: fileName, text: text, origin: origin));
    return result;
  }
}

/// Returns fixed bytes, or a failure, without drawing anything.
class FakeWidgetImageRenderer implements WidgetImageRenderer {
  new({this.fails = false});

  final bool fails;
  final List<Widget> rendered = [];

  static final Uint8List bytes = Uint8List.fromList([137, 80, 78, 71]);

  @override
  Future<Result<Uint8List, ShareFailure>> renderPng(
    BuildContext context,
    Widget widget, {
    required double width,
    required double pixelRatio,
  }) async {
    rendered.add(widget);
    return fails ? const Err(ShareRenderFailed()) : Ok(bytes);
  }
}
