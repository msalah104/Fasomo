import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:flutter/services.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  const new({required this.localDataSource});

  static const String _key = AppConstants.remindersKey;

  final ReminderLocalDataSource localDataSource;

  @override
  Result<List<Reminder>, StorageFailure> getReminders() {
    try {
      final stored = {
        for (final reminder in localDataSource.getReminders())
          reminder.fastingType: reminder,
      };
      // Every reminder is on until the user changes it.
      return Ok([
        for (final type in FastingType.values)
          stored[type] ?? Reminder(fastingType: type, isEnabled: true),
      ]);
    } on FormatException catch (e, st) {
      AppLog.error('reminders.read', e, st);
      return const Err(StorageReadFailed(_key));
    }
  }

  @override
  Future<Result<void, StorageFailure>> saveReminder(Reminder reminder) =>
      _update(
        (reminders) => [
          for (final r in reminders)
            if (r.id != reminder.id) r,
          reminder,
        ],
      );

  @override
  bool wasPermissionAsked() => localDataSource.getPermissionAsked();

  @override
  Future<Result<void, StorageFailure>> markPermissionAsked() async {
    try {
      await localDataSource.setPermissionAsked();
      return const Ok(null);
    } on StorageWriteException catch (e, st) {
      AppLog.error('reminders.permission_asked', e, st);
      return const Err(StorageWriteFailed(AppConstants.permissionAskedKey));
    } on PlatformException catch (e, st) {
      AppLog.error('reminders.permission_asked', e, st);
      return const Err(StorageWriteFailed(AppConstants.permissionAskedKey));
    }
  }

  Future<Result<void, StorageFailure>> _update(
    List<Reminder> Function(List<Reminder> current) change,
  ) async {
    switch (getReminders()) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: final current):
        try {
          await localDataSource.saveReminders(change(current));
          return const Ok(null);
        } on StorageWriteException catch (e, st) {
          AppLog.error('reminders.write', e, st);
          return const Err(StorageWriteFailed(_key));
        } on PlatformException catch (e, st) {
          AppLog.error('reminders.write', e, st);
          return const Err(StorageWriteFailed(_key));
        }
    }
  }
}
