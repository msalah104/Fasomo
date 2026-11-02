import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_preferences_repository.dart';
import 'package:flutter/services.dart';

class CalendarPreferencesRepositoryImpl
    implements CalendarPreferencesRepository {
  const new({required this.localDataSource});

  static const String _key = CalendarLocalDataSourceImpl.showGregorianDaysKey;

  final CalendarLocalDataSource localDataSource;

  @override
  Result<bool, StorageFailure> getShowGregorianDays() {
    try {
      return Ok(localDataSource.getShowGregorianDays() ?? false);
    } on FormatException catch (e, st) {
      AppLog.error('calendar.show_gregorian.read', e, st);
      return const Err(StorageReadFailed(_key));
    }
  }

  @override
  Future<Result<void, StorageFailure>> saveShowGregorianDays({
    required bool show,
  }) async {
    try {
      await localDataSource.saveShowGregorianDays(show: show);
      return const Ok(null);
    } on StorageWriteException catch (e, st) {
      AppLog.error('calendar.show_gregorian.write', e, st);
      return const Err(StorageWriteFailed(_key));
    } on PlatformException catch (e, st) {
      AppLog.error('calendar.show_gregorian.write', e, st);
      return const Err(StorageWriteFailed(_key));
    }
  }
}
