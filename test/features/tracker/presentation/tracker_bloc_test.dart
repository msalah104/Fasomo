import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/usecases/get_fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_day_fasted.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFastLogSummary extends Mock implements GetFastLogSummary;

class MockSetDayFasted extends Mock implements SetDayFasted;

void main() {
  late MockGetFastLogSummary getSummary;
  late MockSetDayFasted setDayFasted;

  final monday = DateTime(2026, 10, 26);
  final withMonday = FastLogSummary(
    fastedDays: {monday},
    currentStreak: 1,
    longestStreak: 1,
    month: PeriodTotals.empty,
    year: PeriodTotals.empty,
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(SetDayFastedParams(date: monday, fasted: true));
  });

  setUp(() {
    getSummary = MockGetFastLogSummary();
    setDayFasted = MockSetDayFasted();
    when(() => getSummary(any())).thenReturn(const Ok(FastLogSummary.empty));
    when(() => setDayFasted(any())).thenAnswer((_) async => const Ok(null));
  });

  TrackerBloc build() =>
      TrackerBloc(getSummary: getSummary, setDayFasted: setDayFasted);

  test('starts in the initial state', () {
    expect(build().state, const TrackerState());
  });

  blocTest<TrackerBloc, TrackerState>(
    'loads the summary',
    build: build,
    act: (bloc) => bloc.add(const LoadTracker()),
    expect: () => const [
      TrackerState(status: TrackerStatus.loading),
      TrackerState(status: TrackerStatus.success),
    ],
  );

  blocTest<TrackerBloc, TrackerState>(
    'a read failure is an error state',
    setUp: () => when(() => getSummary(any())).thenReturn(
      const Err(StorageReadFailed(AppConstants.fastLogKey)),
    ),
    build: build,
    act: (bloc) => bloc.add(const LoadTracker()),
    expect: () => const [
      TrackerState(status: TrackerStatus.loading),
      TrackerState(
        status: TrackerStatus.error,
        failure: StorageReadFailed(AppConstants.fastLogKey),
      ),
    ],
  );

  blocTest<TrackerBloc, TrackerState>(
    'toggling an unmarked day marks it and reloads',
    setUp: () => when(() => getSummary(any())).thenReturn(Ok(withMonday)),
    build: build,
    seed: () => const TrackerState(status: TrackerStatus.success),
    act: (bloc) => bloc.add(ToggleDayFasted(monday)),
    expect: () => [
      TrackerState(status: TrackerStatus.success, summary: withMonday),
    ],
    verify: (_) => verify(
      () => setDayFasted(SetDayFastedParams(date: monday, fasted: true)),
    ).called(1),
  );

  blocTest<TrackerBloc, TrackerState>(
    'toggling a marked day clears it',
    build: build,
    seed: () =>
        TrackerState(status: TrackerStatus.success, summary: withMonday),
    act: (bloc) => bloc.add(ToggleDayFasted(monday)),
    expect: () => const [TrackerState(status: TrackerStatus.success)],
    verify: (_) => verify(
      () => setDayFasted(SetDayFastedParams(date: monday, fasted: false)),
    ).called(1),
  );

  blocTest<TrackerBloc, TrackerState>(
    'a rejected toggle keeps the summary and reports the failure',
    setUp: () => when(
      () => setDayFasted(any()),
    ).thenAnswer((_) async => const Err(FutureDayNotLoggable())),
    build: build,
    seed: () => const TrackerState(status: TrackerStatus.success),
    act: (bloc) => bloc.add(ToggleDayFasted(DateTime(2026, 11, 2))),
    expect: () => const [
      TrackerState(
        status: TrackerStatus.success,
        failure: FutureDayNotLoggable(),
      ),
    ],
  );
}
