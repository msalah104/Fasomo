import 'package:clock/clock.dart';
import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/backup/preferences_snapshot_store.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/backup/domain/usecases/export_backup.dart';
import 'package:fasomo/features/backup/domain/usecases/restore_backup.dart';
import 'package:fasomo/features/calendar/data/backup/calendar_backup_section.dart';
import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_backup_file_gateway.dart';

void main() {
  late SharedPreferences preferences;
  late FakeBackupFileGateway files;
  late BackupService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      CalendarLocalDataSourceImpl.showGregorianDaysKey: true,
    });
    preferences = await SharedPreferences.getInstance();
    files = FakeBackupFileGateway();
    service = BackupService(
      sections: <BackupSection>[
        CalendarBackupSection(
          CalendarLocalDataSourceImpl(sharedPreferences: preferences),
        ),
      ],
      snapshots: PreferencesSnapshotStore(preferences),
      clock: Clock.fixed(DateTime.utc(2026, 11, 2, 10, 15)),
      appVersion: '1.0.0',
    );
  });

  test('export shares the backup file', () async {
    final result = await ExportBackup(
      service: service,
      files: files,
    )(const NoParams());
    expect(result, isA<Ok<void, BackupFailure>>());
    expect(files.shared.single.fileName, 'fasomo-backup-2026-11-02-1015.json');
    expect(files.shared.single.contents, contains('"showGregorianDays": true'));
  });

  test('export passes on a dismissed share sheet', () async {
    files.shareResult = const Err(BackupCancelled());
    expect(
      await ExportBackup(service: service, files: files)(const NoParams()),
      isA<Err<void, BackupFailure>>(),
    );
  });

  test('restore reads the picked file', () async {
    final backup = (service.export() as Ok<BackupFile, BackupFailure>).value;
    await preferences.setBool(
      CalendarLocalDataSourceImpl.showGregorianDaysKey,
      false,
    );
    files.pickResult = Ok(backup.contents);

    final result = await RestoreBackup(
      service: service,
      files: files,
    )(const NoParams());

    expect(result, isA<Ok<RestoreReport, BackupFailure>>());
    expect(
      preferences.getBool(CalendarLocalDataSourceImpl.showGregorianDaysKey),
      isTrue,
    );
  });

  test('a closed picker restores nothing', () async {
    files.pickResult = const Err(BackupCancelled());
    final result = await RestoreBackup(
      service: service,
      files: files,
    )(const NoParams());
    expect(
      result,
      isA<Err<RestoreReport, BackupFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<BackupCancelled>(),
      ),
    );
  });
}
