import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/entities/week_day.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/home/presentation/pages/home_page.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc;

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

  Future<void> pumpHome(
    WidgetTester tester, {
    required Brightness brightness,
    Locale locale = const Locale('en'),
    HomeState? homeState,
  }) async {
    bloc = MockHomeBloc();
    when(() => bloc.state).thenReturn(homeState ?? state);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: BlocProvider<HomeBloc>.value(
            value: bloc,
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
}
