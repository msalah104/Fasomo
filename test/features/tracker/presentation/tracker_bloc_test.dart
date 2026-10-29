import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/usecases/can_make_up_on.dart';
import 'package:fasomo/features/tracker/domain/usecases/get_fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_day_fasted.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_extra_qada_owed.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_make_up_fast.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_ramadan_day_missed.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFastLogSummary extends Mock implements GetFastLogSummary;

class MockSetDayFasted extends Mock implements SetDayFasted;

class MockSetRamadanDayMissed extends Mock implements SetRamadanDayMissed;

class MockSetMakeUpFast extends Mock implements SetMakeUpFast;

class MockSetExtraQadaOwed extends Mock implements SetExtraQadaOwed;

class MockCanMakeUpOn extends Mock implements CanMakeUpOn;

void main() {
  late MockGetFastLogSummary getSummary;
  late MockSetDayFasted setDayFasted;
  late MockSetRamadanDayMissed setRamadanDayMissed;
  late MockSetMakeUpFast setMakeUpFast;
  late MockSetExtraQadaOwed setExtraQadaOwed;
  late MockCanMakeUpOn canMakeUpOn;

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
    registerFallbackValue(
      SetRamadanDayMissedParams(date: monday, missed: true),
    );
    registerFallbackValue(SetMakeUpFastParams(date: monday, makeUp: true));
    registerFallbackValue(
      const SetExtraQadaOwedParams(hijriYear: 1446, days: 1),
    );
  });

  setUp(() {
    getSummary = MockGetFastLogSummary();
    setDayFasted = MockSetDayFasted();
    when(() => getSummary(any())).thenReturn(const Ok(FastLogSummary.empty));
    setRamadanDayMissed = MockSetRamadanDayMissed();
    setMakeUpFast = MockSetMakeUpFast();
    setExtraQadaOwed = MockSetExtraQadaOwed();
    canMakeUpOn = MockCanMakeUpOn();
    when(() => setDayFasted(any())).thenAnswer((_) async => const Ok(null));
    when(
      () => setRamadanDayMissed(any()),
    ).thenAnswer((_) async => const Ok(null));
    when(() => setMakeUpFast(any())).thenAnswer((_) async => const Ok(null));
    when(() => setExtraQadaOwed(any())).thenAnswer((_) async => const Ok(null));
  });

  TrackerBloc build() => TrackerBloc(
    getSummary: getSummary,
    setDayFasted: setDayFasted,
    setRamadanDayMissed: setRamadanDayMissed,
    setMakeUpFast: setMakeUpFast,
    setExtraQadaOwed: setExtraQadaOwed,
    canMakeUpOnDay: canMakeUpOn,
  );

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

  blocTest<TrackerBloc, TrackerState>(
    'toggling a Ramadan day missed marks it, then clears it',
    build: build,
    seed: () => const TrackerState(status: TrackerStatus.success),
    act: (bloc) => bloc.add(ToggleRamadanMissed(monday)),
    verify: (_) => verify(
      () => setRamadanDayMissed(
        SetRamadanDayMissedParams(date: monday, missed: true),
      ),
    ).called(1),
  );

  blocTest<TrackerBloc, TrackerState>(
    'toggling a make-up fast on a day that is one clears it',
    build: build,
    seed: () => TrackerState(
      status: TrackerStatus.success,
      summary: FastLogSummary(
        fastedDays: {monday},
        makeUpDays: {monday},
        currentStreak: 1,
        longestStreak: 1,
        month: PeriodTotals.empty,
        year: PeriodTotals.empty,
      ),
    ),
    act: (bloc) => bloc.add(ToggleMakeUp(monday)),
    expect: () => const [TrackerState(status: TrackerStatus.success)],
    verify: (_) => verify(
      () => setMakeUpFast(SetMakeUpFastParams(date: monday, makeUp: false)),
    ).called(1),
  );

  blocTest<TrackerBloc, TrackerState>(
    'sets the days owed for a year',
    build: build,
    seed: () => const TrackerState(status: TrackerStatus.success),
    act: (bloc) => bloc.add(const SetExtraOwed(hijriYear: 1446, days: 3)),
    verify: (_) => verify(
      () => setExtraQadaOwed(
        const SetExtraQadaOwedParams(hijriYear: 1446, days: 3),
      ),
    ).called(1),
  );

  blocTest<TrackerBloc, TrackerState>(
    'a rejected make-up fast reports the failure',
    setUp: () => when(
      () => setMakeUpFast(any()),
    ).thenAnswer((_) async => const Err(RamadanDayNotMakeUp())),
    build: build,
    seed: () => const TrackerState(status: TrackerStatus.success),
    act: (bloc) => bloc.add(ToggleMakeUp(monday)),
    expect: () => const [
      TrackerState(
        status: TrackerStatus.success,
        failure: RamadanDayNotMakeUp(),
      ),
    ],
  );

  test('answers whether a day can be a make-up fast', () {
    when(() => canMakeUpOn(monday)).thenReturn(true);
    when(() => canMakeUpOn(DateTime(2026, 3))).thenReturn(false);

    final bloc = build();

    expect(bloc.canMakeUpOn(monday), isTrue);
    expect(bloc.canMakeUpOn(DateTime(2026, 3)), isFalse);
  });
}
