// Renders the real app, with real fonts, to PNG files for design review.
//
// Not part of `flutter test` (it lives outside test/). Run it with:
//
//   flutter test tool/screenshots/app_screenshots_test.dart \
//     --dart-define=SHOT_DIR=build/screenshots
//
// Each case boots the app through the real composition root with fake OS
// notifications and push, opens one tab, and saves `<name>-<locale>-<theme>.png`.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:fasomo/app/app.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/di/injection_container.dart' as di;
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/helpers/fake_notification_gateway.dart';
import '../../test/helpers/fake_push_messaging.dart';

const _outDir = String.fromEnvironment(
  'SHOT_DIR',
  defaultValue: 'build/screenshots',
);

/// A phone-sized logical screen, rendered at 2x.
const _screen = Size(390, 844);
const _pixelRatio = 2.0;

/// Each screen to capture, and what to tap in order to reach it: an icon, or
/// the English or Arabic label of a control.
const _screens = <String, List<Object>>{
  'home': [],
  'calendar': [Icons.calendar_today_outlined],
  'reminders': [Icons.notifications_outlined],
  'about': [Icons.info_outlined],
  'settings': [Icons.settings_outlined],
  'calendar_year': [Icons.calendar_today_outlined, ('Year', 'سنة')],
  'tone-picker': [Icons.settings_outlined, Icons.music_note_outlined],
  'prayer-method': [
    Icons.settings_outlined,
    ('Calculation method', 'طريقة الحساب'),
  ],
  'progress': [('Your fasting', 'صيامك')],
  'duas': [Icons.info_outlined, ('Duas and intentions', 'الأدعية والنية')],
};

Finder _finderFor(Object tap, String language) => switch (tap) {
  final IconData icon => find.byIcon(icon),
  (final String en, final String ar) => find.text(language == 'ar' ? ar : en),
  _ => throw ArgumentError.value(tap, 'tap'),
};

class _GrantedPermission implements NotificationPermission {
  @override
  Future<bool> request() async => true;
}

Future<void> _loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/root/flutter';
  final material = '$flutterRoot/bin/cache/artifacts/material_fonts';
  final families = <String, List<String>>{
    'MaterialIcons': ['$material/MaterialIcons-Regular.otf'],
    'Roboto': [
      '$material/Roboto-Regular.ttf',
      '$material/Roboto-Medium.ttf',
      '$material/Roboto-Bold.ttf',
    ],
  };
  // The app's bundled fonts, straight from the font manifest.
  final manifest = jsonDecode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<Object?>;
  for (final entry in manifest.whereType<Map<String, Object?>>()) {
    final family = entry['family'];
    final fonts = entry['fonts'];
    if (family is! String || fonts is! List<Object?>) continue;
    final loader = FontLoader(family);
    for (final font in fonts.whereType<Map<String, Object?>>()) {
      final asset = font['asset'];
      if (asset is String) loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = File(file).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

Future<void> _capture(WidgetTester tester, String name) async {
  // Decode every image on screen before capturing, or they render blank.
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final widget = element.widget as Image;
      await precacheImage(widget.image, element);
    }
  });
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('screenshot-root')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_outDir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _bootApp(
  WidgetTester tester, {
  required String language,
  required Brightness brightness,
}) async {
  tester.view
    ..physicalSize = _screen * _pixelRatio
    ..devicePixelRatio = _pixelRatio;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  // This file is a test harness that lives outside test/ only so that a plain
  // `flutter test` skips it.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({
    AppConstants.languageKey: language == 'ar' ? 'arabic' : 'english',
    // A little history, so streaks, totals and the make-up pace show.
    AppConstants.fastLogKey: ['2026-10-22', '2026-10-26', '2026-10-29'],
    AppConstants.extraOwedKey: ['1447:6'],
  });
  await di.sl.reset();
  final notifications = FakeNotificationGateway();
  await tester.runAsync(
    () => di.init(
      platform: di.PlatformServices(
        notifications: notifications,
        notificationPermission: _GrantedPermission(),
        tonePreview: notifications,
        push: FakePushMessaging(),
      ),
    ),
  );

  await tester.pumpWidget(
    const RepaintBoundary(
      key: ValueKey('screenshot-root'),
      child: FasomoApp(),
    ),
  );
  // Skip the splash.
  await tester.pump(const Duration(seconds: 1));
  await tester.tapAt(_screen.center(Offset.zero));
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final language in ['en', 'ar']) {
    for (final brightness in Brightness.values) {
      for (final MapEntry(key: screen, value: taps) in _screens.entries) {
        final name = '$screen-$language-${brightness.name}';
        testWidgets(name, (tester) async {
          await _bootApp(tester, language: language, brightness: brightness);
          for (final tap in taps) {
            final matches = _finderFor(tap, language);
            final target = matches.first;
            if (matches.evaluate().isEmpty) {
              // Lazy lists build only what is on screen: scroll to it.
              await tester.dragUntilVisible(
                matches,
                find.byType(Scrollable).hitTestable().first,
                const Offset(0, -300),
              );
            }
            await tester.ensureVisible(target);
            await tester.pump(const Duration(milliseconds: 300));
            await tester.tap(target);
            for (var i = 0; i < 10; i++) {
              await tester.pump(const Duration(milliseconds: 100));
            }
          }
          await _capture(tester, name);
        });
      }
    }
  }
}
