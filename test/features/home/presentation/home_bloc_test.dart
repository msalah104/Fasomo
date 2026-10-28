import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/usecases/get_current_hijri_date.dart';
import 'package:fasomo/features/home/domain/usecases/get_upcoming_fasting_days.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentHijriDate extends Mock implements GetCurrentHijriDate;

class MockGetUpcomingFastingDays extends Mock implements GetUpcomingFastingDays;

void main() {
  late MockGetCurrentHijriDate getCurrentHijriDate;
  late MockGetUpcomingFastingDays getUpcomingFastingDays;

  final today = HijriDateInfo(
    hijriDate: const HijriDate(1448, 5, 17),
    gregorianDate: DateTime(2026, 10, 28),
  );
  final upcoming = [
    FastingDay(
      hijriDate: const HijriDate(1448, 5, 18),
      gregorianDate: DateTime(2026, 10, 29),
      types: const [FastingType.mondayThursday],
      daysUntil: 1,
    ),
  ];
  const outOfRange = CalendarOutOfRange(minHijriYear: 1356, maxHijriYear: 1500);

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getCurrentHijriDate = MockGetCurrentHijriDate();
    getUpcomingFastingDays = MockGetUpcomingFastingDays();
    when(() => getCurrentHijriDate(any())).thenReturn(Ok(today));
    when(() => getUpcomingFastingDays(any())).thenReturn(Ok(upcoming));
  });

  HomeBloc build() => HomeBloc(
    getCurrentHijriDate: getCurrentHijriDate,
    getUpcomingFastingDays: getUpcomingFastingDays,
  );

  test('starts in the initial state', () {
    expect(build().state, const HomeState());
  });

  blocTest<HomeBloc, HomeState>(
    'LoadHomeData emits loading, then today and the upcoming days',
    build: build,
    act: (bloc) => bloc.add(const LoadHomeData()),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      HomeState(
        status: HomeStatus.success,
        currentDate: today,
        upcomingFastingDays: upcoming,
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'RefreshHomeData reloads without a loading state',
    build: build,
    act: (bloc) => bloc.add(const RefreshHomeData()),
    expect: () => [
      HomeState(
        status: HomeStatus.success,
        currentDate: today,
        upcomingFastingDays: upcoming,
      ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'a calendar failure becomes an error state carrying the failure',
    setUp: () => when(
      () => getUpcomingFastingDays(any()),
    ).thenReturn(const Err(outOfRange)),
    build: build,
    act: (bloc) => bloc.add(const LoadHomeData()),
    expect: () => [
      const HomeState(status: HomeStatus.loading),
      const HomeState(status: HomeStatus.error, failure: outOfRange),
    ],
  );
}
