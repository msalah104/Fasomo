import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_current_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentHijriMonth extends Mock implements GetCurrentHijriMonth;

class MockGetHijriMonth extends Mock implements GetHijriMonth;

List<CalendarDay> daysOf(HijriMonth month) => [
  CalendarDay(
    hijriDate: HijriDate(month.year, month.month, 1),
    gregorianDate: DateTime(2026, month.month),
    isToday: false,
    fastingTypes: const [],
  ),
];

void main() {
  late MockGetCurrentHijriMonth getCurrentHijriMonth;
  late MockGetHijriMonth getHijriMonth;

  const current = HijriMonth(1448, 12);
  const outOfRange = CalendarOutOfRange(minHijriYear: 1356, maxHijriYear: 1500);

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(current);
  });

  setUp(() {
    getCurrentHijriMonth = MockGetCurrentHijriMonth();
    getHijriMonth = MockGetHijriMonth();
    when(() => getCurrentHijriMonth(any())).thenReturn(const Ok(current));
    when(() => getHijriMonth(any())).thenAnswer(
      (invocation) =>
          Ok(daysOf(invocation.positionalArguments.first as HijriMonth)),
    );
  });

  CalendarBloc build() => CalendarBloc(
    getCurrentHijriMonth: getCurrentHijriMonth,
    getHijriMonth: getHijriMonth,
  );

  CalendarState shown(HijriMonth month) => CalendarState(
    status: CalendarStatus.success,
    days: daysOf(month),
    month: month,
  );

  blocTest<CalendarBloc, CalendarState>(
    'LoadCalendar opens the current month',
    build: build,
    act: (bloc) => bloc.add(const LoadCalendar()),
    expect: () => [
      const CalendarState(status: CalendarStatus.loading),
      shown(current),
    ],
  );

  blocTest<CalendarBloc, CalendarState>(
    'NextMonth wraps into the next Hijri year',
    build: build,
    seed: () => shown(current),
    act: (bloc) => bloc.add(const NextMonth()),
    expect: () => [shown(const HijriMonth(1449, 1))],
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
      CalendarState(
        status: CalendarStatus.error,
        days: daysOf(const HijriMonth(1500, 12)),
        month: const HijriMonth(1500, 12),
        failure: outOfRange,
      ),
    ],
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
}
