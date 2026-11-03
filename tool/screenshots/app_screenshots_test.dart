// Renders the real app, with real fonts, to PNG files for design review.
//
// Not part of `flutter test` (it lives outside test/). Run it with:
//
//   flutter test tool/screenshots/app_screenshots_test.dart \
//     --dart-define=SHOT_DIR=build/screenshots
//
// Each case boots the app through the real composition root with fake OS
// notifications and push, opens one tab, and saves `<name>-<locale>-<theme>.png`.
// The `onboarding-*` cases boot a first run instead, and step through the
// first-run flow.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:clock/clock.dart';
import 'package:fasomo/app/app.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/di/injection_container.dart' as di;
import 'package:fasomo/core/location/location_repository_impl.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/presentation/numerals.dart';
import 'package:fasomo/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:fasomo/features/ramadan/data/repositories/ramadan_checklist_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test/helpers/fake_home_widget_gateway.dart';
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
  'suhoor-iftar': [
    Icons.notifications_outlined,
    ('Suhoor and iftar', 'السحور والإفطار'),
  ],
  'prayer-method': [
    Icons.settings_outlined,
    ('Calculation method', 'طريقة الحساب'),
  ],
  'progress': [('Your fasting', 'صيامك')],
  'duas': [Icons.info_outlined, ('Duas and intentions', 'الأدعية والنية')],
};

/// Screens at a moment other than now, each with its clock and what to tap
/// or scroll to. They are drawn for London, whose winter time is UTC like
/// the machine the harness runs on, so the times read as local ones.
final _datedScreens = <String, (DateTime, List<Object>)>{
  // Twelve days before 1 Ramadan 1448 (8 February 2027).
  'ramadan-countdown': (
    DateTime(2027, 1, 27, 10),
    [const _ScrollTo('Your fasting', 'صيامك')],
  ),
  // The afternoon of the 12th day.
  'ramadan': (
    DateTime(2027, 2, 19, 13, 40),
    [const _ScrollTo("Today's prayer times", 'مواقيت الصلاة اليوم')],
  ),
  'ramadan-times': (
    DateTime(2027, 2, 19, 13, 40),
    [
      ("Today's prayer times", 'مواقيت الصلاة اليوم'),
      const _ScrollTo('Isha', 'العشاء'),
    ],
  ),
};

/// Scrolls the English or Arabic label to the bottom of the screen without
/// tapping it.
final class _ScrollTo {
  const new(this.en, this.ar);

  final String en;
  final String ar;
}

/// Saved data for the dated screens: a picked city and a few checklist and
/// fasting-log entries in Ramadan.
final _datedPreferences = <String, Object>{
  LocationRepositoryImpl.storageKey: jsonEncode({
    'lat': 51.51,
    'lng': -0.13,
    'source': 'manual',
    'city': 'GB:London',
  }),
  RamadanChecklistRepositoryImpl.storageKey: jsonEncode({
    '2027-02-19': {'taraweeh': true, 'quranPages': 12},
  }),
  AppConstants.fastLogKey: ['2027-02-08', '2027-02-09', '2027-02-18'],
};

const _next = ('Next', 'التالي');

/// The first-run flow, one capture per step.
const _onboardingScreens = <String, List<Object>>{
  'onboarding-welcome': [],
  'onboarding-fasts': [_next],
  'onboarding-time': [_next, _next],
  'onboarding-location': [_next, _next, _next],
  'onboarding-notifications': [_next, _next, _next, ('Later', 'لاحقًا')],
};

Finder _finderFor(Object tap, String language) => switch (tap) {
  final IconData icon => find.byIcon(icon),
  (final String en, final String ar) => find.text(language == 'ar' ? ar : en),
  _ScrollTo(:final en, :final ar) => find.text(language == 'ar' ? ar : en),
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
  DateTime? now,
  bool onboarded = true,
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
    if (now != null) ..._datedPreferences,
    OnboardingLocalDataSourceImpl.completedKey: onboarded,
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
        homeWidget: FakeHomeWidgetGateway(),
      ),
    ),
  );
  if (now != null) {
    // Code that reads the clock from GetIt gets the same fixed time as code
    // reading the zone's `clock` (see withClock in main).
    di.sl
      ..allowReassignment = true
      ..registerLazySingleton<Clock>(() => Clock.fixed(now));
  }

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

Future<void> _visit(
  WidgetTester tester,
  List<Object> taps,
  String language,
) async {
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
    if (tap is _ScrollTo) {
      await Scrollable.ensureVisible(tester.element(target), alignment: 1);
      await tester.pump(const Duration(milliseconds: 300));
      continue;
    }
    await tester.ensureVisible(target);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(target);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

void main() {
  setUpAll(() async {
    pinWesternDigits();
    await _loadFonts();
  });

  for (final language in ['en', 'ar']) {
    for (final brightness in Brightness.values) {
      for (final (screens, onboarded) in [
        (_screens, true),
        (_onboardingScreens, false),
      ]) {
        for (final MapEntry(key: screen, value: taps) in screens.entries) {
          final name = '$screen-$language-${brightness.name}';
          testWidgets(name, (tester) async {
            await _bootApp(
              tester,
              language: language,
              brightness: brightness,
              onboarded: onboarded,
            );
            await _visit(tester, taps, language);
            await _capture(tester, name);
          });
        }
      }
      for (final MapEntry(key: screen, value: (now, taps))
          in _datedScreens.entries) {
        final name = '$screen-$language-${brightness.name}';
        testWidgets(
          name,
          (tester) => withClock(Clock.fixed(now), () async {
            await _bootApp(
              tester,
              language: language,
              brightness: brightness,
              now: now,
            );
            await _visit(tester, taps, language);
            await _capture(tester, name);
          }),
        );
      }
    }
  }
}
