import 'dart:convert';

import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes reminders as JSON strings in shared preferences.
///
/// Throws [FormatException] for undecodable data and [StorageWriteException]
/// when the platform refuses a write; the repository converts both into
/// typed failures.
abstract interface class ReminderLocalDataSource {
  /// The reminders the user has changed; types never touched are absent.
  List<Reminder> getReminders();
  Future<void> saveReminders(List<Reminder> reminders);

  bool getPermissionAsked();
  Future<void> setPermissionAsked();
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  const new({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  List<Reminder> getReminders() {
    final encoded =
        sharedPreferences.getStringList(AppConstants.remindersKey) ?? const [];
    return [
      for (final json in encoded)
        if (Reminder.tryFromJson(jsonDecode(json)) case final reminder?)
          reminder
        else
          throw FormatException('Malformed reminder', json),
    ];
  }

  @override
  Future<void> saveReminders(List<Reminder> reminders) async {
    final saved = await sharedPreferences.setStringList(
      AppConstants.remindersKey,
      [for (final reminder in reminders) jsonEncode(reminder.toJson())],
    );
    if (!saved) throw const StorageWriteException(AppConstants.remindersKey);
  }

  @override
  bool getPermissionAsked() =>
      sharedPreferences.getBool(AppConstants.permissionAskedKey) ?? false;

  @override
  Future<void> setPermissionAsked() async {
    final saved = await sharedPreferences.setBool(
      AppConstants.permissionAskedKey,
      true,
    );
    if (!saved) {
      throw const StorageWriteException(AppConstants.permissionAskedKey);
    }
  }
}
