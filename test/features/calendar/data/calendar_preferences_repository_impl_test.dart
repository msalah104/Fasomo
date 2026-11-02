import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_preferences_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const key = CalendarLocalDataSourceImpl.showGregorianDaysKey;

  Future<CalendarPreferencesRepositoryImpl> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return CalendarPreferencesRepositoryImpl(
      localDataSource: CalendarLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
    );
  }

  bool valueOf(Result<bool, StorageFailure> result) =>
      (result as Ok<bool, StorageFailure>).value;

  test('Gregorian day numbers are off until turned on', () async {
    final repository = await repositoryWith({});
    expect(valueOf(repository.getShowGregorianDays()), isFalse);
  });

  test('round-trips the choice', () async {
    final repository = await repositoryWith({});

    expect(
      await repository.saveShowGregorianDays(show: true),
      isA<Ok<void, StorageFailure>>(),
    );
    expect(valueOf(repository.getShowGregorianDays()), isTrue);

    await repository.saveShowGregorianDays(show: false);
    expect(valueOf(repository.getShowGregorianDays()), isFalse);
  });

  test('a stored value of the wrong type is a read failure', () async {
    final repository = await repositoryWith({key: 'yes'});
    expect(
      repository.getShowGregorianDays(),
      isA<Err<bool, StorageFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<StorageReadFailed>(),
      ),
    );
  });
}
