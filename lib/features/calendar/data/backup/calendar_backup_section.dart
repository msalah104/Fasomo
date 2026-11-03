import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter/services.dart';

/// The calendar's display preferences in a backup:
///
/// ```json
/// "calendar": {"showGregorianDays": true}
/// ```
final class CalendarBackupSection implements BackupSection {
  const new(this.localDataSource);

  final CalendarLocalDataSource localDataSource;

  @override
  String get id => 'calendar';

  @override
  Set<String> get storageKeys => const {
    CalendarLocalDataSourceImpl.showGregorianDaysKey,
  };

  @override
  Result<Map<String, Object?>, BackupFailure> export() {
    try {
      return Ok({
        'showGregorianDays': localDataSource.getShowGregorianDays() ?? false,
      });
    } on FormatException catch (e, st) {
      AppLog.error('backup.calendar.export', e, st);
      return Err(BackupStorageFailed(id));
    }
  }

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) =>
      json['showGregorianDays'] is bool
      ? const Ok(null)
      : Err(BackupMalformed(sectionId: id));

  @override
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json) async {
    final show = json['showGregorianDays'];
    if (show is! bool) return Err(BackupMalformed(sectionId: id));
    try {
      await localDataSource.saveShowGregorianDays(show: show);
      return const Ok(null);
    } on StorageWriteException catch (e, st) {
      AppLog.error('backup.calendar.restore', e, st);
      return Err(BackupStorageFailed(id));
    } on PlatformException catch (e, st) {
      AppLog.error('backup.calendar.restore', e, st);
      return Err(BackupStorageFailed(id));
    }
  }
}
