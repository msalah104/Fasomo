import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/features/tracker/data/datasources/fast_log_local_data_source.dart';
import 'package:fasomo/features/tracker/data/repositories/fast_log_repository_impl.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFastLogLocalDataSource extends Mock implements FastLogLocalDataSource;

void main() {
  const calendar = FastingCalendar(UmmAlQuraHijriConverter());
  // Wednesday 28 October 2026, 17 Jumada al-Ula 1448.
  final clock = Clock.fixed(DateTime(2026, 10, 28, 14));

  Future<FastLogRepositoryImpl> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    return FastLogRepositoryImpl(
      localDataSource: FastLogLocalDataSourceImpl(sharedPreferences: prefs),
      calendar: calendar,
      clock: clock,
    );
  }

  FastLogSummary summary(FastLogRepositoryImpl repository) =>
      switch (repository.getSummary()) {
        Ok(:final value) => value,
        Err() => fail('expected a summary'),
      };

  setUpAll(() => registerFallbackValue(FastLog.empty));

  test('starts empty', () async {
    final empty = summary(await repositoryWith({}));
    expect(empty.isEmpty, isTrue);
    expect(empty.currentStreak, 0);
  });

  test('marks and clears a day, stored as yyyy-MM-dd', () async {
    final repository = await repositoryWith({});

    final marked = await repository.setFasted(
      DateTime(2026, 10, 26, 9),
      fasted: true,
    );
    expect(marked, isA<Ok<void, Failure>>());
    expect(summary(repository).fastedDays, {DateTime(2026, 10, 26)});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(AppConstants.fastLogKey), ['2026-10-26']);

    await repository.setFasted(DateTime(2026, 10, 26), fasted: false);
    expect(summary(repository).isEmpty, isTrue);
  });

  test('derives streaks from the stored days', () async {
    final repository = await repositoryWith({
      AppConstants.fastLogKey: ['2026-10-24', '2026-10-25', '2026-10-26'],
    });

    expect(summary(repository).currentStreak, 3);
  });

  test('rejects a future day', () async {
    final repository = await repositoryWith({});

    final result = await repository.setFasted(
      DateTime(2026, 10, 29),
      fasted: true,
    );

    expect(result, isA<Err<void, Failure>>());
    expect((result as Err).failure, isA<FutureDayNotLoggable>());
    expect(summary(repository).isEmpty, isTrue);
  });

  test('rejects a forbidden day', () async {
    final repository = await repositoryWith({});

    // 1 Shawwal 1447, Eid al-Fitr.
    final eid = calendar.converter.toGregorian(const HijriDate(1447, 10, 1));
    final result = await repository.setFasted(eid, fasted: true);

    expect((result as Err).failure, isA<ForbiddenDayNotLoggable>());
  });

  test('malformed data is a read failure', () async {
    for (final bad in ['2026-10', 'yesterday', '2026-02-31']) {
      final repository = await repositoryWith({
        AppConstants.fastLogKey: [bad],
      });
      expect(
        repository.getSummary(),
        isA<Err<FastLogSummary, StorageFailure>>().having(
          (e) => e.failure,
          'failure',
          isA<StorageReadFailed>(),
        ),
      );
    }
  });

  test('a refused write is a write failure', () async {
    final dataSource = MockFastLogLocalDataSource();
    when(dataSource.getLog).thenReturn(FastLog.empty);
    when(
      () => dataSource.saveLog(any()),
    ).thenThrow(const StorageWriteException(AppConstants.fastLogKey));
    final repository = FastLogRepositoryImpl(
      localDataSource: dataSource,
      calendar: calendar,
      clock: clock,
    );

    final result = await repository.setFasted(
      DateTime(2026, 10, 26),
      fasted: true,
    );

    expect((result as Err).failure, isA<StorageWriteFailed>());
  });

  group('make-up (Qada)', () {
    DateTime ramadan1447(int day) =>
        calendar.converter.toGregorian(HijriDate(1447, 9, day));

    test('a missed Ramadan day and fasting it clear each other', () async {
      final repository = await repositoryWith({});
      final day = ramadan1447(3);

      await repository.setFasted(day, fasted: true);
      await repository.setMissedRamadan(day, missed: true);
      expect(summary(repository).markFor(day), DayMark.missed);
      expect(summary(repository).isFasted(day), isFalse);
      expect(summary(repository).qada.owed, 1);

      await repository.setFasted(day, fasted: true);
      expect(summary(repository).markFor(day), DayMark.fasted);
      expect(summary(repository).qada.owed, 0);
    });

    test('a make-up fast is also fasted; un-fasting clears it', () async {
      final repository = await repositoryWith({});
      final day = DateTime(2026, 10, 27);

      await repository.setMakeUp(day, makeUp: true);
      expect(summary(repository).isFasted(day), isTrue);
      expect(summary(repository).isMakeUp(day), isTrue);

      await repository.setMakeUp(day, makeUp: false);
      expect(summary(repository).markFor(day), DayMark.fasted);

      await repository.setMakeUp(day, makeUp: true);
      await repository.setFasted(day, fasted: false);
      expect(summary(repository).markFor(day), isNull);
    });

    test('stores every part of the log under its own key', () async {
      final repository = await repositoryWith({});
      await repository.setMissedRamadan(ramadan1447(3), missed: true);
      await repository.setMakeUp(DateTime(2026, 10, 27), makeUp: true);
      await repository.setExtraOwed(1446, days: 4);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(AppConstants.fastLogKey), ['2026-10-27']);
      expect(prefs.getStringList(AppConstants.makeUpDaysKey), ['2026-10-27']);
      expect(prefs.getStringList(AppConstants.missedRamadanKey), hasLength(1));
      expect(prefs.getStringList(AppConstants.extraOwedKey), ['1446:4']);
      expect(summary(repository).qada.owed, 5);
      expect(summary(repository).qada.remaining, 4);
    });

    test('setting zero days owed removes the entry', () async {
      final repository = await repositoryWith({
        AppConstants.extraOwedKey: ['1445:2', '1446:4'],
      });

      await repository.setExtraOwed(1446, days: 0);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(AppConstants.extraOwedKey), ['1445:2']);
    });

    test('rejects a make-up fast in Ramadan', () async {
      final repository = await repositoryWith({});

      final result = await repository.setMakeUp(ramadan1447(5), makeUp: true);

      expect((result as Err).failure, isA<RamadanDayNotMakeUp>());
    });

    test('rejects marking an ordinary day as missed', () async {
      final repository = await repositoryWith({});

      final result = await repository.setMissedRamadan(
        DateTime(2026, 10, 27),
        missed: true,
      );

      expect((result as Err).failure, isA<NotARamadanDay>());
    });

    test('malformed days owed are a read failure', () async {
      final repository = await repositoryWith({
        AppConstants.extraOwedKey: ['1446-4'],
      });

      expect(
        repository.getSummary(),
        isA<Err<FastLogSummary, StorageFailure>>(),
      );
    });
  });
}
