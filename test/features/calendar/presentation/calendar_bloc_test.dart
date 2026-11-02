import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_current_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_year.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_show_gregorian_days.dart';
import 'package:fasomo/features/calendar/domain/usecases/save_show_gregorian_days.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentHijriMonth extends Mock implements GetCurrentHijriMonth;

class MockGetHijriMonth extends Mock implements GetHijriMonth;

class MockGetHijriYear extends Mock implements GetHijriYear;

class MockGetShowGregorianDays extends Mock implements GetShowGregorianDays;

class MockSaveShowGregorianDays extends Mock implements SaveShowGregorianDays;

List<CalendarDay> daysOf(HijriMonth month) => [
  CalendarDay(
    hijriDate: HijriDate(month.year, month.month, 1),
    gregorianDate: DateTime(2026, month.month),
    isToday: false,
    fastingTypes: const [],
  ),
];

List<CalendarMonth> monthsOf(int year) => [
  for (var month = 1; month <= 12; month++)
    CalendarMonth(
      month: HijriMonth(year, month),
      days: daysOf(HijriMonth(year, month)),
    ),
];

void main() {
  late MockGetCurrentHijriMonth getCurrentHijriMonth;
  late MockGetHijriMonth getHijriMonth;
  late MockGetHijriYear getHijriYear;
  late MockGetShowGregorianDays getShowGregorianDays;
  late MockSaveShowGregorianDays saveShowGregorianDays;

  const current = HijriMonth(1448, 12);
  const outOfRange = CalendarOutOfRange(minHijriYear: 1356, maxHijriYear: 1500);
  const writeFailed = StorageWriteFailed('calendar_show_gregorian_days');

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(current);
  });

  setUp(() {
    getCurrentHijriMonth = MockGetCurrentHijriMonth();
    getHijriMonth = MockGetHijriMonth();
    getHijriYear = MockGetHijriYear();
    getShowGregorianDays = MockGetShowGregorianDays();
    saveShowGregorianDays = MockSaveShowGregorianDays();
    when(() => getCurrentHijriMonth(any())).thenReturn(const Ok(current));
    when(() => getHijriMonth(any())).thenAnswer(
      (invocation) =>
          Ok(daysOf(invocation.positionalArguments.first as HijriMonth)),
    );
    when(() => getHijriYear(any())).thenAnswer(
      (invocation) => Ok(monthsOf(invocation.positionalArguments.first as int)),
    );
    when(() => getShowGregorianDays(any())).thenReturn(const Ok(false));
    when(
      () => saveShowGregorianDays(any()),
    ).thenAnswer((_) async => const Ok(null));
  });

  CalendarBloc build() => CalendarBloc(
    getCurrentHijriMonth: getCurrentHijriMonth,
    getHijriMonth: getHijriMonth,
    getHijriYear: getHijriYear,
    getShowGregorianDays: getShowGregorianDays,
    saveShowGregorianDays: saveShowGregorianDays,
  );

  CalendarState shown(
    HijriMonth month, {
    HijriMonth? currentMonth,
    bool showGregorianDays = false,
  }) => CalendarState(
    status: CalendarStatus.success,
    days: daysOf(month),
    previousDays: daysOf(month.previous),
    nextDays: daysOf(month.next),
    month: month,
    currentMonth: currentMonth,
    showGregorianDays: showGregorianDays,
  );

  group('opening', () {
    test('starts with the saved Gregorian choice', () {
      when(() => getShowGregorianDays(any())).thenReturn(const Ok(true));
      expect(build().state.showGregorianDays, isTrue);
    });

    test('an unreadable Gregorian choice falls back to off', () {
      when(
        () => getShowGregorianDays(any()),
      ).thenReturn(
        const Err(StorageReadFailed('calendar_show_gregorian_days')),
      );
      expect(build().state.showGregorianDays, isFalse);
    });

    blocTest<CalendarBloc, CalendarState>(
      'LoadCalendar opens the current month with its neighbours',
      build: build,
      act: (bloc) => bloc.add(const LoadCalendar()),
      expect: () => [
        const CalendarState(status: CalendarStatus.loading),
        shown(current, currentMonth: current),
      ],
      verify: (bloc) => expect(bloc.state.isShowingCurrentMonth, isTrue),
    );

    blocTest<CalendarBloc, CalendarState>(
      'LoadCalendar reads the Gregorian choice again, e.g. after a restore',
      build: build,
      act: (bloc) {
        when(() => getShowGregorianDays(any())).thenReturn(const Ok(true));
        bloc.add(const LoadCalendar());
      },
      verify: (bloc) => expect(bloc.state.showGregorianDays, isTrue),
    );

    blocTest<CalendarBloc, CalendarState>(
      'a failure resolving today is an error state',
      setUp: () => when(
        () => getCurrentHijriMonth(any()),
      ).thenReturn(const Err(outOfRange)),
      build: build,
      act: (bloc) => bloc.add(const LoadCalendar()),
      expect: () => [
        const CalendarState(status: CalendarStatus.loading),
        const CalendarState(status: CalendarStatus.error, failure: outOfRange),
      ],
    );
  });

  group('month navigation', () {
    blocTest<CalendarBloc, CalendarState>(
      'NextMonth wraps into the next Hijri year',
      build: build,
      seed: () => shown(current, currentMonth: current),
      act: (bloc) => bloc.add(const NextMonth()),
      expect: () => [shown(const HijriMonth(1449, 1), currentMonth: current)],
      verify: (bloc) => expect(bloc.state.isShowingCurrentMonth, isFalse),
    );

    blocTest<CalendarBloc, CalendarState>(
      'PreviousMonth goes back one month',
      build: build,
      seed: () => shown(current),
      act: (bloc) => bloc.add(const PreviousMonth()),
      expect: () => [shown(const HijriMonth(1448, 11))],
    );

    blocTest<CalendarBloc, CalendarState>(
      'ChangeMonth jumps to any month',
      build: build,
      act: (bloc) => bloc.add(const ChangeMonth(HijriMonth(1447, 9))),
      expect: () => [shown(const HijriMonth(1447, 9))],
    );

    blocTest<CalendarBloc, CalendarState>(
      'navigating before the first load does nothing',
      build: build,
      act: (bloc) => bloc
        ..add(const NextMonth())
        ..add(const PreviousMonth()),
      expect: () => <CalendarState>[],
    );

    blocTest<CalendarBloc, CalendarState>(
      'an unsupported month keeps the last good month and reports the failure',
      setUp: () => when(
        () => getHijriMonth(const HijriMonth(1501, 1)),
      ).thenReturn(const Err(outOfRange)),
      build: build,
      seed: () => shown(const HijriMonth(1500, 12)),
      act: (bloc) => bloc.add(const NextMonth()),
      expect: () => [
        shown(
          const HijriMonth(1500, 12),
        ).copyWith(status: CalendarStatus.error, failure: outOfRange),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'a neighbour outside the supported range has no days to preview',
      setUp: () => when(
        () => getHijriMonth(const HijriMonth(1501, 1)),
      ).thenReturn(const Err(outOfRange)),
      build: build,
      act: (bloc) => bloc.add(const ChangeMonth(HijriMonth(1500, 12))),
      expect: () => [
        CalendarState(
          status: CalendarStatus.success,
          days: daysOf(const HijriMonth(1500, 12)),
          previousDays: daysOf(const HijriMonth(1500, 11)),
          month: const HijriMonth(1500, 12),
        ),
      ],
    );
  });

  group('GoToToday', () {
    blocTest<CalendarBloc, CalendarState>(
      'returns to the current month without a loading flash',
      build: build,
      seed: () => shown(const HijriMonth(1447, 3), currentMonth: current),
      act: (bloc) => bloc.add(const GoToToday()),
      expect: () => [shown(current, currentMonth: current)],
    );

    blocTest<CalendarBloc, CalendarState>(
      'resolves today afresh, so it follows a month that has rolled over',
      setUp: () => when(
        () => getCurrentHijriMonth(any()),
      ).thenReturn(const Ok(HijriMonth(1449, 1))),
      build: build,
      seed: () => shown(const HijriMonth(1447, 3), currentMonth: current),
      act: (bloc) => bloc.add(const GoToToday()),
      expect: () => [
        shown(
          const HijriMonth(1449, 1),
          currentMonth: const HijriMonth(1449, 1),
        ),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'keeps the shown month when today cannot be resolved',
      setUp: () => when(
        () => getCurrentHijriMonth(any()),
      ).thenReturn(const Err(outOfRange)),
      build: build,
      seed: () => shown(const HijriMonth(1447, 3), currentMonth: current),
      act: (bloc) => bloc.add(const GoToToday()),
      expect: () => [
        shown(
          const HijriMonth(1447, 3),
          currentMonth: current,
        ).copyWith(status: CalendarStatus.error, failure: outOfRange),
      ],
    );
  });

  group('ToggleGregorianDays', () {
    blocTest<CalendarBloc, CalendarState>(
      'saves the new choice, then shows it',
      build: build,
      seed: () => shown(current),
      act: (bloc) => bloc.add(const ToggleGregorianDays()),
      expect: () => [shown(current, showGregorianDays: true)],
      verify: (_) => verify(() => saveShowGregorianDays(true)).called(1),
    );

    blocTest<CalendarBloc, CalendarState>(
      'two quick taps turn it on and off again',
      build: build,
      seed: () => shown(current),
      act: (bloc) => bloc
        ..add(const ToggleGregorianDays())
        ..add(const ToggleGregorianDays()),
      expect: () => [
        shown(current, showGregorianDays: true),
        shown(current),
      ],
      verify: (_) {
        verify(() => saveShowGregorianDays(true)).called(1);
        verify(() => saveShowGregorianDays(false)).called(1);
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'a failed save keeps the old choice and reports the failure once',
      setUp: () => when(
        () => saveShowGregorianDays(any()),
      ).thenAnswer((_) async => const Err(writeFailed)),
      build: build,
      seed: () => shown(current),
      act: (bloc) => bloc.add(const ToggleGregorianDays()),
      expect: () => [
        shown(current).copyWith(preferenceFailure: writeFailed),
      ],
      verify: (bloc) => expect(bloc.state.showGregorianDays, isFalse),
    );

    test('the failure is cleared by the next change', () {
      final failed = shown(current).copyWith(preferenceFailure: writeFailed);
      expect(failed.copyWith(month: current).preferenceFailure, isNull);
    });
  });

  group('year view', () {
    CalendarState yearOf(int year, {HijriMonth month = current}) => shown(
      month,
      currentMonth: current,
    ).copyWith(view: CalendarView.year, year: year, yearMonths: monthsOf(year));

    blocTest<CalendarBloc, CalendarState>(
      'ShowYearView opens the year of the shown month',
      build: build,
      seed: () => shown(const HijriMonth(1447, 3), currentMonth: current),
      act: (bloc) => bloc.add(const ShowYearView()),
      expect: () => [yearOf(1447, month: const HijriMonth(1447, 3))],
      verify: (bloc) => expect(bloc.state.isShowingCurrentMonth, isFalse),
    );

    blocTest<CalendarBloc, CalendarState>(
      'ShowYearView before the first load does nothing',
      build: build,
      act: (bloc) => bloc.add(const ShowYearView()),
      expect: () => <CalendarState>[],
    );

    blocTest<CalendarBloc, CalendarState>(
      'NextYear and PreviousYear move a year at a time',
      build: build,
      seed: () => yearOf(1448),
      act: (bloc) => bloc
        ..add(const NextYear())
        ..add(const PreviousYear())
        ..add(const PreviousYear()),
      expect: () => [yearOf(1449), yearOf(1448), yearOf(1447)],
    );

    blocTest<CalendarBloc, CalendarState>(
      'an unsupported year keeps the last good year and reports the failure',
      setUp: () =>
          when(() => getHijriYear(1501)).thenReturn(const Err(outOfRange)),
      build: build,
      seed: () => yearOf(1500),
      act: (bloc) => bloc.add(const NextYear()),
      expect: () => [
        yearOf(
          1500,
        ).copyWith(status: CalendarStatus.error, failure: outOfRange),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'tapping a month opens it in the month view',
      build: build,
      seed: () => yearOf(1449),
      act: (bloc) => bloc.add(const ChangeMonth(HijriMonth(1449, 9))),
      expect: () => [
        shown(
          const HijriMonth(1449, 9),
          currentMonth: current,
        ).copyWith(year: 1449, yearMonths: monthsOf(1449)),
      ],
      verify: (bloc) => expect(bloc.state.view, CalendarView.month),
    );

    blocTest<CalendarBloc, CalendarState>(
      'ShowMonthView returns to the month and clears a year failure',
      build: build,
      seed: () => yearOf(
        1500,
      ).copyWith(status: CalendarStatus.error, failure: outOfRange),
      act: (bloc) => bloc.add(const ShowMonthView()),
      expect: () => [
        shown(
          current,
          currentMonth: current,
        ).copyWith(year: 1500, yearMonths: monthsOf(1500)),
      ],
      verify: (bloc) => expect(bloc.state.isShowingCurrentMonth, isTrue),
    );

    blocTest<CalendarBloc, CalendarState>(
      'GoToToday leaves the year view for the current month',
      build: build,
      seed: () => yearOf(1450, month: const HijriMonth(1450, 2)),
      act: (bloc) => bloc.add(const GoToToday()),
      expect: () => [
        shown(
          current,
          currentMonth: current,
        ).copyWith(year: 1450, yearMonths: monthsOf(1450)),
      ],
    );
  });
}
