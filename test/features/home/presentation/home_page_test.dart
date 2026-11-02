import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/entities/week_day.dart';
import 'package:fasomo/features/home/domain/sky_scene_builder.dart';
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

  /// Evening in Makkah: the sun has set and a waning gibbous moon is up.
  final night = SkyState(
    scene: buildSkyScene(DateTime.utc(2026, 10, 28, 18, 40), GeoPoint.makkah),
  );

  /// Mid-morning in Cairo, picked from the list.
  final day = SkyState(
    scene: buildSkyScene(
      DateTime.utc(2026, 10, 28, 7),
      GeoPoint.fromCity(CityCatalog.byId('EG:Cairo')!),
    ),
  );

  late MockHomeBloc bloc;
  late MockSkyBloc sky;

  Future<void> pumpHome(
    WidgetTester tester, {
    required Brightness brightness,
    Locale locale = const Locale('en'),
    HomeState? homeState,
    SkyState? skyState,
    Stream<SkyState>? laterSkyStates,
    bool inView = true,
  }) async {
    bloc = MockHomeBloc();
    sky = MockSkyBloc();
    when(() => bloc.state).thenReturn(homeState ?? state);
    if (laterSkyStates != null) {
      whenListen(sky, laterSkyStates, initialState: skyState ?? night);
    } else {
      when(() => sky.state).thenReturn(skyState ?? night);
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: TickerMode(
            enabled: inView,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<HomeBloc>.value(value: bloc),
                BlocProvider<SkyBloc>.value(value: sky),
              ],
              child: HomePage(
                isReminderOn: (_) => false,
                onToggleReminder: (_) {},
                headerActionBuilder: (color) =>
                    Icon(Icons.language, color: color),
                spotlightSection: const Text('SPOTLIGHT'),
                progressSection: const Text('PROGRESS'),
                todayActionBuilder: (date, hijri) =>
                    Text('TODAY ${date.day} ${hijri.day}'),
                dayActionBuilder: (day) => Text('DAY ${day.daysUntil}'),
              ),
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
      await pumpHome(tester, brightness: brightness);

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
    await pumpHome(
      tester,
      brightness: Brightness.light,
      locale: const Locale('ar'),
      skyState: day,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('اليوم 17 من 30'), findsOneWidget);
    expect(find.text('القاهرة'), findsOneWidget);
    expect(find.textContaining('الشروق'), findsOneWidget);
  });

  testWidgets('tapping a day in the week strip selects it', (tester) async {
    await pumpHome(tester, brightness: Brightness.light);

    await tester.tap(find.text('22'));
    verify(() => bloc.add(DaySelected(DateTime(2026, 11, 2)))).called(1);
  });

  testWidgets('the week strip stays pinned when the sky scrolls away', (
    tester,
  ) async {
    await pumpHome(tester, brightness: Brightness.light);

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
    await pumpHome(tester, brightness: Brightness.light, homeState: withToday);

    expect(find.text('PROGRESS'), findsOneWidget);
    // The spotlight (the Ramadan card) comes first.
    expect(
      tester.getTopLeft(find.text('SPOTLIGHT')).dy,
      lessThan(tester.getTopLeft(find.text('PROGRESS')).dy),
    );
    await tester.scrollUntilVisible(find.text('TODAY 28 17'), 200);
    expect(find.text('TODAY 28 17'), findsOneWidget);
    expect(find.textContaining('TODAY', skipOffstage: false), findsOneWidget);
  });

  testWidgets('every fasting-day card shows the day action', (tester) async {
    await withClock(Clock.fixed(DateTime(2026, 10, 28, 10)), () async {
      await pumpHome(tester, brightness: Brightness.light);
    });

    for (final offset in [1, 5, 8, 12, 15]) {
      await tester.scrollUntilVisible(find.text('DAY $offset'), 200);
      expect(find.text('DAY $offset'), findsOneWidget);
    }
  });

  group('the live sky', () {
    testWidgets('describes the scene for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpHome(tester, brightness: Brightness.dark);

      expect(
        find.bySemanticsLabel(
          RegExp(
            r'^Night\. Sky over Makkah, an approximate location\. '
            r'The moon is up: waning gibbous, 91% lit\.$',
          ),
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('shows sunrise and sunset by day', (tester) async {
      await pumpHome(tester, brightness: Brightness.light, skyState: day);

      expect(find.textContaining('Sunrise '), findsOneWidget);
      expect(find.textContaining('Sunset '), findsOneWidget);
      expect(find.text('Cairo'), findsOneWidget);
    });

    testWidgets('shows the moonrise and the next sunrise at night', (
      tester,
    ) async {
      await pumpHome(tester, brightness: Brightness.light);

      expect(find.textContaining('Moonrise '), findsOneWidget);
      expect(find.textContaining('Sunrise '), findsOneWidget);
      expect(find.text('Approximate · Set location'), findsOneWidget);
    });

    testWidgets('the chip offers the device location', (tester) async {
      await pumpHome(tester, brightness: Brightness.light);

      await tester.tap(find.text('Approximate · Set location'));
      await tester.pumpAndSettle();
      expect(find.text('Set your location'), findsOneWidget);

      await tester.tap(find.text('Use my location'));
      await tester.pumpAndSettle();
      verify(() => sky.add(const SkyDeviceLocationRequested())).called(1);
    });

    testWidgets('the chip offers the city list', (tester) async {
      await pumpHome(tester, brightness: Brightness.light);

      await tester.tap(find.text('Approximate · Set location'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a city'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'istanbul');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Istanbul'));
      await tester.pumpAndSettle();

      verify(
        () => sky.add(SkyCityChosen(CityCatalog.byId('TR:Istanbul')!)),
      ).called(1);
    });

    testWidgets('a permanent denial offers the system settings', (
      tester,
    ) async {
      await pumpHome(
        tester,
        brightness: Brightness.light,
        laterSkyStates: Stream.value(
          night.copyWith(
            locationFailure: const LocationPermissionDenied(permanently: true),
          ),
        ),
      );

      expect(find.textContaining('Location is blocked'), findsOneWidget);
      await tester.tap(find.text('Settings'));
      verify(() => sky.add(const SkyLocationSettingsRequested())).called(1);
    });

    testWidgets('pauses the ticks while the tab is out of view', (
      tester,
    ) async {
      await pumpHome(tester, brightness: Brightness.light, inView: false);
      verify(() => sky.add(const SkyPaused())).called(1);
    });
  });
}
