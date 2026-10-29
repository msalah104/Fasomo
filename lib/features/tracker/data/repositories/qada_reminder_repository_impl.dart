import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/tracker/data/datasources/qada_reminder_local_data_source.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/domain/repositories/qada_reminder_repository.dart';
import 'package:flutter/services.dart';

class QadaReminderRepositoryImpl implements QadaReminderRepository {
  const new({required this.localDataSource});

  static const String _key = AppConstants.qadaRemindersKey;

  final QadaReminderLocalDataSource localDataSource;

  @override
  Result<QadaReminderSettings, StorageFailure> getSettings() {
    try {
      return Ok(localDataSource.getSettings() ?? QadaReminderSettings.defaults);
    } on FormatException catch (e, st) {
      AppLog.error('qada_reminders.read', e, st);
      return const Err(StorageReadFailed(_key));
    }
  }

  @override
  Future<Result<void, StorageFailure>> saveSettings(
    QadaReminderSettings settings,
  ) async {
    try {
      await localDataSource.saveSettings(settings);
      return const Ok(null);
    } on StorageWriteException catch (e, st) {
      AppLog.error('qada_reminders.write', e, st);
      return const Err(StorageWriteFailed(_key));
    } on PlatformException catch (e, st) {
      AppLog.error('qada_reminders.write', e, st);
      return const Err(StorageWriteFailed(_key));
    }
  }
}
