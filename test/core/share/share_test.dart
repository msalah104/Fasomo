import 'dart:ui' as ui;

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/services/share/overlay_widget_image_renderer.dart';
import 'package:fasomo/core/services/share/share_plus_share_service.dart';
import 'package:fasomo/core/share/share_service.dart';
import 'package:fasomo/core/share/share_widget_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

import '../../helpers/fake_share.dart';

void main() {
  group('ShareWidgetImage', () {
    testWidgets('draws the widget, then shares its bytes with the text', (
      tester,
    ) async {
      final renderer = FakeWidgetImageRenderer();
      final service = FakeShareService();
      await tester.pumpWidget(const SizedBox());
      final context = tester.element(find.byType(SizedBox));

      final result = await ShareWidgetImage(
        renderer: renderer,
        shareService: service,
      )(context, image: const Text('card'), fileName: 'a.png', text: 'hi');

      expect(result, isA<Ok<ShareOutcome, ShareFailure>>());
      expect(renderer.rendered, hasLength(1));
      expect(service.shared.single.bytes, FakeWidgetImageRenderer.bytes);
      expect(service.shared.single.fileName, 'a.png');
      expect(service.shared.single.text, 'hi');
    });

    testWidgets('shares nothing when the image cannot be drawn', (
      tester,
    ) async {
      final service = FakeShareService();
      await tester.pumpWidget(const SizedBox());

      final result =
          await ShareWidgetImage(
            renderer: FakeWidgetImageRenderer(fails: true),
            shareService: service,
          )(
            tester.element(find.byType(SizedBox)),
            image: const Text('card'),
            fileName: 'a.png',
            text: 'hi',
          );

      expect(result, isA<Err<ShareOutcome, ShareFailure>>());
      expect(service.shared, isEmpty);
    });
  });

  group('SharePlusShareService', () {
    final bytes = Uint8List.fromList([1, 2, 3]);

    test('sends a named PNG with the text and maps the result', () async {
      final calls = <ShareParams>[];
      final service = SharePlusShareService(
        share: (params) async {
          calls.add(params);
          return const ShareResult('', ShareResultStatus.dismissed);
        },
      );

      final result = await service.sharePng(
        bytes: bytes,
        fileName: 'fasomo.png',
        text: 'Fasting tomorrow',
        origin: const Rect.fromLTWH(1, 2, 3, 4),
      );

      expect(
        (result as Ok<ShareOutcome, ShareFailure>).value,
        ShareOutcome.dismissed,
      );
      final params = calls.single;
      expect(params.text, 'Fasting tomorrow');
      expect(params.fileNameOverrides, ['fasomo.png']);
      expect(params.files?.single.mimeType, 'image/png');
      expect(await params.files?.single.readAsBytes(), bytes);
      expect(params.sharePositionOrigin, const Rect.fromLTWH(1, 2, 3, 4));
    });

    test('a platform error is a typed failure, not a throw', () async {
      final service = SharePlusShareService(
        share: (_) async => throw PlatformException(code: 'busy'),
      );

      final result = await service.sharePng(
        bytes: bytes,
        fileName: 'fasomo.png',
        text: 'x',
      );

      expect(
        (result as Err<ShareOutcome, ShareFailure>).failure,
        isA<SharePlatformFailed>(),
      );
    });
  });

  testWidgets('OverlayWidgetImageRenderer draws an off-screen widget to PNG', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay(),
      ),
    );
    // An Overlay needs an initial entry to give a context below it.
    final overlay = tester.state<OverlayState>(find.byType(Overlay));
    final host = OverlayEntry(builder: (_) => const SizedBox.expand());
    overlay.insert(host);
    await tester.pump();
    final context = tester.element(find.byType(SizedBox));

    final pending = const OverlayWidgetImageRenderer().renderPng(
      context,
      const SizedBox(
        height: 20,
        child: ColoredBox(color: Color(0xFF112233)),
      ),
      width: 10,
      pixelRatio: 2,
    );
    await tester.pump();
    final result = await tester.runAsync(() => pending);

    final png = (result! as Ok<Uint8List, ShareFailure>).value;
    final image = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(png);
      return (await codec.getNextFrame()).image;
    });
    expect(image!.width, 20);
    expect(image.height, 40);
    // The temporary entry is gone again.
    await tester.pump();
    expect(find.byType(ColoredBox), findsNothing);
    host.remove();
  });
}
