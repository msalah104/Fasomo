import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/home/data/services/suncalc_sky_calculator.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/entities/week_day.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/home/presentation/bloc/sky_bloc.dart';
import 'package:fasomo/features/home/presentation/pages/home_page.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc;

class MockSkyBloc extends MockBloc<SkyEvent, SkyState> implements SkyBloc;

const _calculator = SuncalcSkyCalculator();

/// The real sky over Makkah at [utc]; UTC so the test doesn't depend on the
/// machine's time zone.
SkyScene skyAt(DateTime utc) => SkyScene(
  now: utc,
  location: GeoPoint.makkah,
  sun: _calculator.sun(utc, GeoPoint.makkah),
  moon: _calculator.moon(utc, GeoPoint.makkah),
  moonPhase: _calculator.moonPhase(utc),
);

/// Noon in Makkah, and 22:00 two nights after the full moon.
final SkyScene noon = skyAt(DateTime.utc(2026, 10, 28, 9));
final SkyScene night = skyAt(DateTime.utc(2026, 10, 28, 19));

void main() {
  final week = [
    for (var i = 0; i < 7; i++)
      WeekDay(
        hijriDate: HijriDate(1448, 5, 17 + i),
        gregorianDate: DateTime(2026, 10, 28 + i),
        types: i == 1 || i == 5 ? const [FastingType.mondayThursday] : const [],
      ),
  ];
  final state = HomeState(
    status: HomeStatus.success,
    currentDate: HijriDateInfo(
      hijriDate: const HijriDate(1448, 5, 17),
      gregorianDate: DateTime(2026, 10, 28),
      daysInMonth: 30,
      week: week,
    ),
    selectedDate: DateTime(2026, 10, 28),
    upcomingFastingDays: [
      for (final offset in [1, 5, 8, 12, 15])
        FastingDay(
          hijriDate: HijriDate(1448, 5, 10 + offset),
          gregorianDate: DateTime(2026, 10, 28 + offset),
          types: const [FastingType.mondayThursday],
          daysUntil: offset,
        ),
    ],
  );

  late MockHomeBloc bloc;
  late MockSkyBloc sky;

  Future<void> pumpHome(
    WidgetTester tester, {
    required Brightness brightness,
    Locale locale = const Locale('en'),
    HomeState? homeState,
    SkyScene? scene,
    Stream<SkyState>? skyStates,
  }) async {
    bloc = MockHomeBloc();
    when(() => bloc.state).thenReturn(homeState ?? state);
    sky = MockSkyBloc();
    final initialSky = SkyState(scene: scene ?? night);
    when(() => sky.state).thenReturn(initialSky);
    if (skyStates != null) {
      whenListen(sky, skyStates, initialState: initialSky);
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<HomeBloc>.value(value: bloc),
              BlocProvider<SkyBloc>.value(value: sky),
            ],
            child: HomePage(
              isReminderOn: (_) => false,
              onToggleReminder: (_) {},
              headerActionBuilder: (color) =>
                  Icon(Icons.language, color: color),
              progressSection: const Text('PROGRESS'),
              todayActionBuilder: (date, hijri) =>
                  Text('TODAY ${date.day} ${hijri.day}'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    testWidgets('renders the sky header in ${brightness.name} theme', (
      tester,
    ) async {
      await withClock(Clock.fixed(DateTime(2026, 10, 28, 21, 40)), () async {
        await pumpHome(tester, brightness: brightness);
      });

      expect(tester.takeException(), isNull);
      expect(find.text('17 Jumada al-Ula 1448 AH'), findsOneWidget);
      expect(find.bySemanticsLabel('This week'), findsOneWidget);
      expect(find.text('Day 17 of 30'), findsOneWidget);
      expect(find.text('Upcoming Fasting Days'), findsOneWidget);
    });
  }

  testWidgets('lays out right-to-left in Arabic without overflow', (
    tester,
  ) async {
    await withClock(Clock.fixed(DateTime(2026, 10, 28, 10)), () async {
      await pumpHome(
        tester,
        brightness: Brightness.light,
        locale: const Locale('ar'),
      );
    });

    expect(tester.takeException(), isNull);
    expect(find.text('اليوم 17 من 30'), findsOneWidget);
  });

  testWidgets('tapping a day in the week strip selects it', (tester) async {
    await withClock(Clock.fixed(DateTime(2026, 10, 28, 10)), () async {
      await pumpHome(tester, brightness: Brightness.light);
    });

    await tester.tap(find.text('22'));
    verify(() => bloc.add(DaySelected(DateTime(2026, 11, 2)))).called(1);
  });

  testWidgets('the week strip stays pinned when the sky scrolls away', (
    tester,
  ) async {
    await withClock(Clock.fixed(DateTime(2026, 10, 28, 10)), () async {
      await pumpHome(tester, brightness: Brightness.light);
    });

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    // The sky (and its date) has scrolled above the viewport.
    final date = find.text('17 Jumada al-Ula 1448 AH', skipOffstage: false);
    expect(tester.getBottomLeft(date).dy, lessThan(0));
    expect(find.bySemanticsLabel('This week'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Thu')).dy, lessThan(120));
  });

  testWidgets('shows the progress section and acts only on today', (
    tester,
  ) async {
    final withToday = state.copyWith(
      upcomingFastingDays: [
        FastingDay(
          hijriDate: const HijriDate(1448, 5, 17),
          gregorianDate: DateTime(2026, 10, 28),
          types: const [FastingType.mondayThursday],
          daysUntil: 0,
        ),
        ...state.upcomingFastingDays,
      ],
    );
    await withClock(Clock.fixed(DateTime(2026, 10, 28, 10)), () async {
      await pumpHome(
        tester,
        brightness: Brightness.light,
        homeState: withToday,
      );
    });

    expect(find.text('PROGRESS'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('TODAY 28 17'), 200);
    expect(find.text('TODAY 28 17'), findsOneWidget);
    expect(find.textContaining('TODAY', skipOffstage: false), findsOneWidget);
  });

  testWidgets('describes the day sky with its sun times', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpHome(tester, brightness: Brightness.light, scene: noon);

    expect(noon.sun.isUp, isTrue);
    expect(
      find.bySemanticsLabel(RegExp(r'^Daytime\. Sunrise .* · Sunset ')),
      findsOneWidget,
    );
    expect(find.textContaining('Sunrise'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('describes the night sky with the moon', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpHome(tester, brightness: Brightness.dark, scene: night);

    expect(night.moon.isUp, isTrue);
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Night\..*Waning gibbous moon, \d+% lit\. Shown for Makkah$'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('the night sky lays out in Arabic without overflow', (
    tester,
  ) async {
    await pumpHome(
      tester,
      brightness: Brightness.dark,
      locale: const Locale('ar'),
      scene: night,
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('الشروق'), findsOneWidget);
  });

  testWidgets('offers to use the device location while showing Makkah', (
    tester,
  ) async {
    await pumpHome(tester, brightness: Brightness.light, scene: noon);

    expect(find.text('Use my location'), findsOneWidget);
    await tester.tap(find.text('Use my location'));
    verify(() => sky.add(const SkyLocationRequested())).called(1);
  });

  testWidgets('a permanently refused location offers Settings', (
    tester,
  ) async {
    await pumpHome(
      tester,
      brightness: Brightness.light,
      scene: noon,
      skyStates: Stream.value(
        SkyState(
          scene: noon,
          failure: const LocationPermissionDenied(permanently: true),
        ),
      ),
    );

    expect(find.textContaining('Location is off for Fasomo'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    verify(
      () => sky.add(
        const SkySettingsRequested(LocationPermissionDenied(permanently: true)),
      ),
    ).called(1);
  });
}
