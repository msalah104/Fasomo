import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/features/calendar/data/backup/calendar_backup_section.dart';
import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCalendarLocalDataSource extends Mock
    implements CalendarLocalDataSource;

void main() {
  Future<CalendarBackupSection> sectionWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return CalendarBackupSection(
      CalendarLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
    );
  }

  test('exports the saved choice, off when none was saved', () async {
    expect(
      (await sectionWith({})).export(),
      isA<Ok<Map<String, Object?>, BackupFailure>>().having(
        (ok) => ok.value,
        'value',
        {'showGregorianDays': false},
      ),
    );
    expect(
      (await sectionWith({'calendar_show_gregorian_days': true})).export(),
      isA<Ok<Map<String, Object?>, BackupFailure>>().having(
        (ok) => ok.value,
        'value',
        {'showGregorianDays': true},
      ),
    );
  });

  test('cannot export an unreadable stored value', () async {
    final section = await sectionWith({'calendar_show_gregorian_days': 'yes'});
    expect(section.export(), isA<Err<Object?, BackupFailure>>());
  });

  test('restores the choice', () async {
    final section = await sectionWith({});
    expect(
      await section.restore({'showGregorianDays': true}),
      isA<Ok<void, BackupFailure>>(),
    );
    expect(
      (await SharedPreferences.getInstance()).getBool(
        CalendarLocalDataSourceImpl.showGregorianDaysKey,
      ),
      isTrue,
    );
  });

  test('validate refuses anything but a bool', () async {
    final section = await sectionWith({});
    for (final json in [
      <String, Object?>{},
      {'showGregorianDays': 'true'},
      {'showGregorianDays': 1},
      {'showGregorianDays': null},
    ]) {
      expect(
        section.validate(json),
        isA<Err<void, BackupFailure>>().having(
          (err) => err.failure,
          'failure',
          isA<BackupMalformed>().having((f) => f.sectionId, 'id', 'calendar'),
        ),
        reason: '$json',
      );
    }
    expect(
      section.validate({'showGregorianDays': false}),
      isA<Ok<void, BackupFailure>>(),
    );
  });

  test('a refused write is a storage failure', () async {
    final dataSource = MockCalendarLocalDataSource();
    when(
      () => dataSource.saveShowGregorianDays(show: true),
    ).thenThrow(const StorageWriteException('calendar_show_gregorian_days'));
    expect(
      await CalendarBackupSection(
        dataSource,
      ).restore({'showGregorianDays': true}),
      isA<Err<void, BackupFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<BackupStorageFailed>(),
      ),
    );
  });
}
