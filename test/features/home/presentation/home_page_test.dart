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
    upcomingFastingDays: [
      FastingDay(
        hijriDate: const HijriDate(1448, 5, 18),
        gregorianDate: DateTime(2026, 10, 29),
        types: const [FastingType.mondayThursday],
        daysUntil: 1,
      ),
    ],
  );

  Future<void> pumpHome(
    WidgetTester tester, {
    required Brightness brightness,
    Locale locale = const Locale('en'),
  }) async {
    final bloc = MockHomeBloc();
    when(() => bloc.state).thenReturn(state);
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
}
