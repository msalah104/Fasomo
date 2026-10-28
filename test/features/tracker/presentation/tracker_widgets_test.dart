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

  testWidgets('a fasted calendar day shows a check badge', (tester) async {
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
          SizedBox.square(
            dimension: 48,
            child: CalendarDayCell(day: day, onTap: () {}, isFasted: true),
          ),
          SizedBox.square(
            dimension: 48,
            child: CalendarDayCell(day: day, onTap: () {}),
          ),
        ],
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
