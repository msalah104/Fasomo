import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
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
      return Ok(localDataSource.getReminders());
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
  Future<Result<void, StorageFailure>> deleteReminder(String id) => _update(
    (reminders) => [
      for (final r in reminders)
        if (r.id != id) r,
    ],
  );

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
