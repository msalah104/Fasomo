import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/backup/backup_values.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/features/reminders/data/datasources/reminder_local_data_source.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:flutter/services.dart';

/// The reminders and their sound in a backup. Only the reminders the user
/// changed are stored (the rest are on by default), so only those are
/// written, in [FastingType] order:
///
/// ```json
/// "reminders": {
///   "notificationTone": "bell",
///   "reminders": [
///     {"fastingType": "monday", "isEnabled": false, "reminderTime": "custom",
///      "customDaysBefore": 1, "customHour": 21, "customMinute": 30,
///      "customMessage": "Suhoor!"}
///   ]
/// }
/// ```
///
/// Whether notification permission was already asked is per device, so it
/// is not part of the backup.
final class RemindersBackupSection implements BackupSection {
  const new(this.localDataSource);

  final ReminderLocalDataSource localDataSource;

  @override
  String get id => 'reminders';

  @override
  Set<String> get storageKeys => const {
    AppConstants.remindersKey,
    AppConstants.notificationToneKey,
  };

  @override
  Result<Map<String, Object?>, BackupFailure> export() {
    try {
      final reminders = [...localDataSource.getReminders()]
        ..sort((a, b) => a.fastingType.index.compareTo(b.fastingType.index));
      final tone =
          localDataSource.getNotificationTone() ??
          NotificationTone.systemDefault;
      return Ok({
        'notificationTone': tone.name,
        'reminders': [for (final reminder in reminders) reminder.toJson()],
      });
    } on FormatException catch (e, st) {
      AppLog.error('backup.reminders.export', e, st);
      return Err(BackupStorageFailed(id));
    }
  }

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) =>
      _parse(json) == null
      ? Err(BackupMalformed(sectionId: id))
      : const Ok(null);

  @override
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json) async {
    final parsed = _parse(json);
    if (parsed == null) return Err(BackupMalformed(sectionId: id));
    final (tone, reminders) = parsed;
    try {
      await localDataSource.saveReminders(reminders);
      await localDataSource.saveNotificationTone(tone);
      return const Ok(null);
    } on StorageWriteException catch (e, st) {
      AppLog.error('backup.reminders.restore', e, st);
      return Err(BackupStorageFailed(id));
    } on PlatformException catch (e, st) {
      AppLog.error('backup.reminders.restore', e, st);
      return Err(BackupStorageFailed(id));
    }
  }

  static (NotificationTone, List<Reminder>)? _parse(Map<String, Object?> json) {
    final tone = BackupValues.byName(
      NotificationTone.values,
      json['notificationTone'],
    );
    final list = json['reminders'];
    if (tone == null || list is! List<Object?>) return null;
    final reminders = <Reminder>[];
    for (final item in list) {
      if (!_isCanonical(item)) return null;
      final reminder = Reminder.tryFromJson(item);
      if (reminder == null) return null;
      // At most one reminder per kind of fasting day.
      if (reminders.any((r) => r.fastingType == reminder.fastingType)) {
        return null;
      }
      reminders.add(reminder);
    }
    return (tone, reminders);
  }

  /// Whether [json] is a reminder exactly as this app writes it. Stricter
  /// than [Reminder.tryFromJson], which accepts old formats and fills in
  /// defaults.
  static bool _isCanonical(Object? json) => switch (json) {
    {
      'fastingType': final String type,
      'isEnabled': bool _,
      'reminderTime': final String time,
      'customDaysBefore': final int days,
      'customHour': final int hour,
      'customMinute': final int minute,
      'customMessage': String? _,
    } =>
      BackupValues.byName(FastingType.values, type) != null &&
          BackupValues.byName(ReminderTime.values, time) != null &&
          days >= 0 &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59,
    _ => false,
  };
}
