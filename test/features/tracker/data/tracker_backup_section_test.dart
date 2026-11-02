import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/features/tracker/data/backup/tracker_backup_section.dart';
import 'package:fasomo/features/tracker/data/datasources/fast_log_local_data_source.dart';
import 'package:fasomo/features/tracker/data/datasources/qada_reminder_local_data_source.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFastLogLocalDataSource extends Mock implements FastLogLocalDataSource;

void main() {
  late FastLogLocalDataSourceImpl fastLog;
  late QadaReminderLocalDataSourceImpl qadaReminders;
  late TrackerBackupSection section;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    fastLog = FastLogLocalDataSourceImpl(sharedPreferences: preferences);
    qadaReminders = QadaReminderLocalDataSourceImpl(
      sharedPreferences: preferences,
    );
    section = TrackerBackupSection(
      fastLog: fastLog,
      qadaReminders: qadaReminders,
    );
  });

  Map<String, Object?> exported() => switch (section.export()) {
    Ok(:final value) => value,
    Err(:final failure) => fail(failure.code),
  };

  final log = FastLog(
    fastedDays: {DateTime(2026, 3, 5), DateTime(2024, 2, 29)},
    makeUpDays: {DateTime(2026, 3, 5)},
    missedRamadanDays: {DateTime(2026, 2, 20)},
    extraOwed: const {1446: 3, 1440: 12},
  );

  test('a fresh install exports an empty log and default reminders', () {
    expect(exported(), {
      'fastedDays': <String>[],
      'makeUpDays': <String>[],
      'missedRamadanDays': <String>[],
      'extraOwed': <Object>[],
      'qadaReminders': QadaReminderSettings.defaults.toJson(),
    });
  });

  test('exports sorted ISO dates and owed days by year', () async {
    await fastLog.saveLog(log);
    final json = exported();
    expect(json['fastedDays'], ['2024-02-29', '2026-03-05']);
    expect(json['makeUpDays'], ['2026-03-05']);
    expect(json['missedRamadanDays'], ['2026-02-20']);
    expect(json['extraOwed'], [
      {'hijriYear': 1440, 'days': 12},
      {'hijriYear': 1446, 'days': 3},
    ]);
  });

  test('cannot export an unreadable log', () async {
    SharedPreferences.setMockInitialValues({
      'fast_log': ['05/03/2026'],
    });
    final preferences = await SharedPreferences.getInstance();
    section = TrackerBackupSection(
      fastLog: FastLogLocalDataSourceImpl(sharedPreferences: preferences),
      qadaReminders: QadaReminderLocalDataSourceImpl(
        sharedPreferences: preferences,
      ),
    );
    expect(section.export(), isA<Err<Object?, BackupFailure>>());
  });

  test('restores the log and the make-up reminders', () async {
    const settings = QadaReminderSettings(
      weekdays: {DateTime.monday},
      paceEnabled: true,
    );
    await fastLog.saveLog(log);
    await qadaReminders.saveSettings(settings);
    final json = exported();

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final restored = TrackerBackupSection(
      fastLog: FastLogLocalDataSourceImpl(sharedPreferences: preferences),
      qadaReminders: QadaReminderLocalDataSourceImpl(
        sharedPreferences: preferences,
      ),
    );
    expect(restored.validate(json), isA<Ok<void, BackupFailure>>());
    expect(await restored.restore(json), isA<Ok<void, BackupFailure>>());
    expect(
      FastLogLocalDataSourceImpl(sharedPreferences: preferences).getLog(),
      log,
    );
    expect(
      QadaReminderLocalDataSourceImpl(
        sharedPreferences: preferences,
      ).getSettings(),
      settings,
    );
  });

  group('validate refuses', () {
    Map<String, Object?> valid() => {
      'fastedDays': ['2026-03-05'],
      'makeUpDays': <String>[],
      'missedRamadanDays': <String>[],
      'extraOwed': <Object>[],
      'qadaReminders': QadaReminderSettings.defaults.toJson(),
    };
    final cases = <String, Map<String, Object?> Function()>{
      'a day that does not exist': () =>
          valid()..['fastedDays'] = ['2026-02-30'],
      'a local date format': () => valid()..['fastedDays'] = ['05/03/2026'],
      'Arabic-Indic digits': () => valid()..['fastedDays'] = ['٢٠٢٦-٠٣-٠٥'],
      'a timestamp': () =>
          valid()..['makeUpDays'] = ['2026-03-05T00:00:00.000Z'],
      'days that are not a list': () =>
          valid()..['missedRamadanDays'] = '2026-03-05',
      'a missing list': () => valid()..remove('makeUpDays'),
      'a negative balance': () => valid()
        ..['extraOwed'] = [
          {'hijriYear': 1446, 'days': -1},
        ],
      'more than 999 days owed': () => valid()
        ..['extraOwed'] = [
          {'hijriYear': 1446, 'days': 1000},
        ],
      'a year that is not four digits': () => valid()
        ..['extraOwed'] = [
          {'hijriYear': 46, 'days': 1},
        ],
      'one year twice': () => valid()
        ..['extraOwed'] = [
          {'hijriYear': 1446, 'days': 1},
          {'hijriYear': 1446, 'days': 2},
        ],
      'owed days as a map': () => valid()..['extraOwed'] = {'1446': 3},
      'invalid make-up reminders': () => valid()
        ..['qadaReminders'] = {
          ...QadaReminderSettings.defaults.toJson(),
          'monthlyHijriDay': 31,
        },
      'missing make-up reminders': () => valid()..remove('qadaReminders'),
    };
    for (final MapEntry(key: name, value: json) in cases.entries) {
      test(name, () {
        expect(
          section.validate(json()),
          isA<Err<void, BackupFailure>>().having(
            (err) => err.failure,
            'failure',
            isA<BackupMalformed>().having((f) => f.sectionId, 'id', 'tracker'),
          ),
        );
      });
    }
  });

  test('a refused write is a storage failure', () async {
    final failing = MockFastLogLocalDataSource();
    registerFallbackValue(FastLog.empty);
    when(
      () => failing.saveLog(any()),
    ).thenThrow(const StorageWriteException('fast_log'));
    final result = await TrackerBackupSection(
      fastLog: failing,
      qadaReminders: qadaReminders,
    ).restore(exported());
    expect(
      result,
      isA<Err<void, BackupFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<BackupStorageFailed>(),
      ),
    );
  });
}
