import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/pages/tracker_page.dart';
import 'package:fasomo/features/tracker/presentation/widgets/fasted_toggle.dart';
import 'package:fasomo/features/tracker/presentation/widgets/qada_section.dart';
import 'package:fasomo/features/tracker/presentation/widgets/tracker_day_actions.dart';
import 'package:fasomo/features/tracker/presentation/widgets/tracker_day_badge.dart';
import 'package:fasomo/features/tracker/presentation/widgets/tracker_summary_card.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTrackerBloc extends MockBloc<TrackerEvent, TrackerState>
    implements TrackerBloc;

void main() {
  // Wednesday 28 October 2026, 17 Jumada al-Ula 1448.
  final today = DateTime(2026, 10, 28);
  const todayHijri = HijriDate(1448, 5, 17);
  final summary = FastLogSummary(
    fastedDays: {DateTime(2026, 10, 26)},
    currentStreak: 4,
    longestStreak: 9,
    month: const PeriodTotals(
      fastedDays: 3,
      dueDays: 5,
      byType: [
        TypeTotal(type: FastingType.whiteDays, fasted: 3, due: 3),
        TypeTotal(type: FastingType.mondayThursday, fasted: 1, due: 3),
      ],
    ),
    year: PeriodTotals.empty,
  );

  late MockTrackerBloc bloc;

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    TrackerState? state,
    Locale locale = const Locale('en'),
  }) async {
    bloc = MockTrackerBloc();
    when(() => bloc.state).thenReturn(
      state ?? TrackerState(status: TrackerStatus.success, summary: summary),
    );
    when(() => bloc.canMakeUpOn(any())).thenReturn(true);
    await withClock(Clock.fixed(DateTime(2026, 10, 28, 10)), () async {
      await tester.pumpWidget(
        BlocProvider<TrackerBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: buildAppTheme(Brightness.light),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(body: child),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  }

  group('TrackerSummaryCard', () {
    testWidgets('shows the streaks and this month', (tester) async {
      await pump(tester, const TrackerSummaryCard());

      expect(find.text('Your fasting'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('This month: 3 of 5 fasting days'), findsOneWidget);
    });

    testWidgets('invites the first entry when the log is empty', (
      tester,
    ) async {
      await pump(
        tester,
        const TrackerSummaryCard(),
        state: const TrackerState(status: TrackerStatus.success),
      );

      expect(find.text('Mark the days you fast to start a streak.'), findsOne);
    });

    testWidgets('opens the progress page', (tester) async {
      await pump(tester, const TrackerSummaryCard());

      await tester.tap(find.byType(TrackerSummaryCard));
      await tester.pumpAndSettle();

      expect(find.byType(TrackerPage), findsOneWidget);
      expect(find.text('White Days'), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);
      // Qada leads the page; the streaks stay on the Home card.
      expect(find.text('Make-up fasts (Qada)'), findsOneWidget);
      expect(find.text('Current streak'), findsNothing);
    });

    testWidgets('lays out in Arabic without overflow', (tester) async {
      await pump(
        tester,
        const TrackerSummaryCard(),
        locale: const Locale('ar'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('صيامك'), findsOneWidget);
    });
  });

  group('FastedToggle', () {
    testWidgets('marks today', (tester) async {
      await pump(
        tester,
        FastedToggle(date: today, hijri: todayHijri),
        state: const TrackerState(status: TrackerStatus.success),
      );

      await tester.tap(find.text('I fasted today'));
      verify(() => bloc.add(ToggleDayFasted(today))).called(1);
    });

    testWidgets('shows a marked day as fasted', (tester) async {
      await pump(
        tester,
        FastedToggle(
          date: DateTime(2026, 10, 26),
          hijri: const HijriDate(1448, 5, 15),
        ),
      );

      expect(find.text('Fasted'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('draws nothing for a future day', (tester) async {
      await pump(
        tester,
        FastedToggle(
          date: DateTime(2026, 10, 29),
          hijri: const HijriDate(1448, 5, 18),
        ),
      );

      expect(find.byType(ButtonStyleButton), findsNothing);
    });
  });

  testWidgets('calendar badges have their own icon and label', (
    tester,
  ) async {
    final day = CalendarDay(
      hijriDate: const HijriDate(1448, 5, 15),
      gregorianDate: DateTime(2026, 10, 26),
      isToday: false,
      fastingTypes: const [FastingType.whiteDays],
    );
    await pump(
      tester,
      Row(
        children: [
          for (final mark in DayMark.values)
            SizedBox.square(
              dimension: 48,
              child: CalendarDayCell(
                day: day,
                onTap: () {},
                badge: TrackerDayBadge(mark: mark),
              ),
            ),
          SizedBox.square(
            dimension: 48,
            child: CalendarDayCell(day: day, onTap: () {}),
          ),
        ],
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Missed')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Made up')), findsOneWidget);
  });

  group('TrackerDayActions', () {
    // 10 Ramadan 1447, in the past.
    final ramadanDay = DateTime(2026, 2, 27);
    const ramadanHijri = HijriDate(1447, 9, 10);
    final tuesday = DateTime(2026, 10, 27);
    const tuesdayHijri = HijriDate(1448, 5, 16);
    final owing = summary.withQada(
      const QadaSummary(
        owed: 2,
        madeUp: 0,
        byYear: [QadaYear(hijriYear: 1447, owed: 2, madeUp: 0, extraOwed: 2)],
        latestOwableYear: 1447,
      ),
    );

    testWidgets('a Ramadan day offers fasted or missed', (tester) async {
      await pump(
        tester,
        TrackerDayActions(date: ramadanDay, hijri: ramadanHijri),
      );

      expect(find.byType(SegmentedButton<DayMark>), findsOneWidget);
      expect(find.text('Make-up fast'), findsNothing);
      await tester.tap(find.text('Missed'));
      verify(() => bloc.add(ToggleRamadanMissed(ramadanDay))).called(1);
    });

    testWidgets('another day offers a make-up fast while days are owed', (
      tester,
    ) async {
      await pump(
        tester,
        TrackerDayActions(date: tuesday, hijri: tuesdayHijri),
        state: TrackerState(status: TrackerStatus.success, summary: owing),
      );

      expect(find.text('Mark as fasted'), findsOneWidget);
      await tester.tap(find.text('Make-up fast'));
      verify(() => bloc.add(ToggleMakeUp(tuesday))).called(1);
    });

    testWidgets('hides the make-up switch when nothing is owed', (
      tester,
    ) async {
      await pump(tester, TrackerDayActions(date: tuesday, hijri: tuesdayHijri));

      expect(find.text('Mark as fasted'), findsOneWidget);
      expect(find.text('Make-up fast'), findsNothing);
    });
  });

  group('QadaSection', () {
    final owing = summary.withQada(
      const QadaSummary(
        owed: 6,
        madeUp: 2,
        byYear: [
          QadaYear(hijriYear: 1446, owed: 2, madeUp: 2, extraOwed: 2),
          QadaYear(hijriYear: 1447, owed: 4, madeUp: 0, extraOwed: 0),
        ],
        latestOwableYear: 1447,
        daysUntilRamadan: 103,
      ),
    );

    testWidgets('shows the balance, each Ramadan and the countdown', (
      tester,
    ) async {
      await pump(
        tester,
        SingleChildScrollView(child: QadaSection(summary: owing)),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.text('Days until Ramadan: 103'), findsOneWidget);
      expect(find.text('Ramadan 1446 AH'), findsOneWidget);
      expect(find.text('2 of 2 made up'), findsOneWidget);
      expect(find.text('0 of 4 made up'), findsOneWidget);
    });

    testWidgets('logs a make-up fast on a day picked here', (tester) async {
      await pump(
        tester,
        SingleChildScrollView(child: QadaSection(summary: owing)),
      );

      await withClock(Clock.fixed(DateTime(2026, 10, 28, 10)), () async {
        await tester.tap(find.text('Log a make-up fast'));
        await tester.pumpAndSettle();
      });
      expect(find.text('Day of the make-up fast'), findsOneWidget);
      await tester.tap(find.text('27'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(ToggleMakeUp(DateTime(2026, 10, 27)))).called(1);
    });

    testWidgets('explains when no day can be logged', (tester) async {
      await pump(
        tester,
        Scaffold(body: QadaSection(summary: owing)),
      );
      when(() => bloc.canMakeUpOn(any())).thenReturn(false);

      await withClock(Clock.fixed(DateTime(2026, 10, 28, 10)), () async {
        await tester.tap(find.text('Log a make-up fast'));
        await tester.pump();
      });

      expect(find.textContaining("There's no day to log yet"), findsOneWidget);
    });

    testWidgets('lists recent make-up fasts and removes one', (tester) async {
      final day = DateTime(2026, 10, 27);
      await pump(
        tester,
        SingleChildScrollView(
          child: QadaSection(
            summary: summary.withQada(
              QadaSummary(
                owed: 2,
                madeUp: 1,
                byYear: const [
                  QadaYear(hijriYear: 1447, owed: 2, madeUp: 1, extraOwed: 2),
                ],
                latestOwableYear: 1447,
                makeUps: [
                  LoggedDay(date: day, hijri: const HijriDate(1448, 5, 16)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Recent make-up fasts'), findsOneWidget);
      expect(find.text('16 Jumada al-Ula 1448 AH'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove this make-up fast'));
      verify(() => bloc.add(ToggleDayFasted(day))).called(1);
    });

    testWidgets('says nothing is owed when the balance is clear', (
      tester,
    ) async {
      await pump(
        tester,
        SingleChildScrollView(child: QadaSection(summary: summary)),
      );

      expect(find.text('No make-up fasts owed.'), findsOneWidget);
      expect(find.text('I made up a fast today'), findsNothing);
    });

    testWidgets('enters days owed for an earlier Ramadan', (tester) async {
      await pump(
        tester,
        SingleChildScrollView(child: QadaSection(summary: owing)),
      );

      await tester.tap(find.text('Add days owed'));
      await tester.pumpAndSettle();
      expect(find.text('Days owed from a Ramadan'), findsOneWidget);

      await tester.tap(find.text('Ramadan 1447 AH').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ramadan 1446 AH').last);
      await tester.pumpAndSettle();
      // Pre-filled with the 2 days already entered for 1446.
      expect(find.text('2'), findsWidgets);
      await tester.tap(find.byTooltip('Add a day'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(const SetExtraOwed(hijriYear: 1446, days: 3)),
      ).called(1);
    });

    testWidgets('lays out in Arabic without overflow', (tester) async {
      await pump(
        tester,
        SingleChildScrollView(child: QadaSection(summary: owing)),
        locale: const Locale('ar'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('صيام القضاء'), findsOneWidget);
    });
  });
}

extension on FastLogSummary {
  FastLogSummary withQada(QadaSummary qada) => FastLogSummary(
    fastedDays: fastedDays,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    month: month,
    year: year,
    qada: qada,
  );
}
