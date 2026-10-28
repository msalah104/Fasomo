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

  setUpAll(() => registerFallbackValue(<DateTime>{}));

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
    when(dataSource.getFastedDays).thenReturn({});
    when(
      () => dataSource.saveFastedDays(any()),
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
}
