import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_month.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/calendar/presentation/pages/calendar_page.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_mini_month.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_year_view.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCalendarBloc extends MockBloc<CalendarEvent, CalendarState>
    implements CalendarBloc;

void main() {
  // Wednesday 28 October 2026 is 17 Jumada al-Ula 1448.
  const current = HijriMonth(1448, 5);
  final repository = CalendarRepositoryImpl(
    calendar: const FastingCalendar(UmmAlQuraHijriConverter()),
    clock: Clock.fixed(DateTime(2026, 10, 28, 10)),
  );

  List<CalendarDay> daysOf(HijriMonth month) => (repository.getMonth(
    month,
  ) as Ok<List<CalendarDay>, CalendarFailure>).value;
  List<CalendarMonth> monthsOf(int year) => (repository.getYear(
    year,
  ) as Ok<List<CalendarMonth>, CalendarFailure>).value;

  final monthState = CalendarState(
    status: CalendarStatus.success,
    days: daysOf(current),
    previousDays: daysOf(current.previous),
    nextDays: daysOf(current.next),
    month: current,
    currentMonth: current,
  );
  final yearState = monthState.copyWith(
    view: CalendarView.year,
    year: 1448,
    yearMonths: monthsOf(1448),
  );

  late MockCalendarBloc bloc;

  setUpAll(() => registerFallbackValue(const LoadCalendar()));

  Future<void> pumpPage(
    WidgetTester tester,
    CalendarState state, {
    Size size = const Size(400, 800),
    Locale locale = const Locale('en'),
    Stream<CalendarState>? updates,
  }) async {
    tester.view
      ..physicalSize = size * 2
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    bloc = MockCalendarBloc();
    if (updates != null) {
      whenListen(bloc, updates, initialState: state);
    } else {
      when(() => bloc.state).thenReturn(state);
    }
    await tester.pumpWidget(
      BlocProvider<CalendarBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: CalendarPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Offset topLeftOfMonth(WidgetTester tester, int index) =>
      tester.getTopLeft(find.byType(CalendarMiniMonth).at(index));

  testWidgets('the view switch asks for the year view', (tester) async {
    await pumpPage(tester, monthState);

    await tester.tap(find.text('Year'));

    verify(() => bloc.add(const ShowYearView())).called(1);
  });

  testWidgets('shows the year with its months and no Gregorian toggle', (
    tester,
  ) async {
    await pumpPage(tester, yearState);

    expect(find.text('1448 AH'), findsOneWidget);
    expect(find.text('Muharram'), findsOneWidget);
    expect(find.byType(FilterChip), findsNothing);
    // Not on the current month's page, so Today offers the way back.
    expect(find.text('Today'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Dhul Hijjah'), 200);
    expect(find.byType(CalendarMiniMonth), findsWidgets);
  });

  testWidgets('tapping a month opens it in the month view', (tester) async {
    await pumpPage(tester, yearState);

    await tester.scrollUntilVisible(find.text('Rajab'), 200);
    await tester.tap(find.text('Rajab'));

    verify(() => bloc.add(const ChangeMonth(HijriMonth(1448, 7)))).called(1);
  });

  testWidgets('each month is one button named with its fasting days', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester, yearState);

    final jumada = yearState.yearMonths[4];
    final label = 'Jumada al-Ula, ${jumada.fastingDayCount} fasting days';
    expect(find.bySemanticsLabel(label), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel(label)),
      matchesSemantics(
        label: label,
        value: 'Current month',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the year arrows and the view switch send their events', (
    tester,
  ) async {
    await pumpPage(tester, yearState);

    await tester.tap(find.byTooltip('Next year'));
    await tester.tap(find.byTooltip('Previous year'));
    await tester.tap(find.text('Month'));

    verify(() => bloc.add(const NextYear())).called(1);
    verify(() => bloc.add(const PreviousYear())).called(1);
    verify(() => bloc.add(const ShowMonthView())).called(1);
  });

  testWidgets('an unsupported year shows a snackbar', (tester) async {
    await pumpPage(
      tester,
      yearState,
      updates: Stream.value(
        yearState.copyWith(
          status: CalendarStatus.error,
          failure: const CalendarOutOfRange(
            minHijriYear: 1356,
            maxHijriYear: 1500,
          ),
        ),
      ),
    );

    expect(
      find.text('This year is outside the supported calendar range'),
      findsOneWidget,
    );
  });

  group('columns follow the available width', () {
    test('two compact, three medium, four expanded', () {
      expect(CalendarYearView.columnsFor(360), 2);
      expect(CalendarYearView.columnsFor(599), 2);
      expect(CalendarYearView.columnsFor(600), 3);
      expect(CalendarYearView.columnsFor(839), 3);
      expect(CalendarYearView.columnsFor(840), 4);
    });

    for (final (width, columns) in [(400.0, 2), (700.0, 3), (1000.0, 4)]) {
      testWidgets('$columns columns at $width wide', (tester) async {
        await pumpPage(tester, yearState, size: Size(width, 900));

        final first = topLeftOfMonth(tester, 0);
        expect(topLeftOfMonth(tester, columns - 1).dy, first.dy);
        expect(topLeftOfMonth(tester, columns).dy, greaterThan(first.dy));
      });
    }
  });

  testWidgets('in Arabic the year reads from the right', (tester) async {
    await pumpPage(tester, yearState, locale: const Locale('ar'));

    expect(
      topLeftOfMonth(tester, 0).dx,
      greaterThan(topLeftOfMonth(tester, 1).dx),
    );
    expect(tester.takeException(), isNull);
  });
}
