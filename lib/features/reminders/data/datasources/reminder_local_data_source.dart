import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/reminder.dart';

abstract class ReminderLocalDataSource {
  List<Reminder> getReminders();
  Future<void> saveReminder(Reminder reminder);
  Future<void> deleteReminder(String id);
  Future<void> updateReminder(Reminder reminder);
}

class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  final SharedPreferences sharedPreferences;

  ReminderLocalDataSourceImpl({required this.sharedPreferences});

  @override
  List<Reminder> getReminders() {
    final remindersJson =
        sharedPreferences.getStringList(AppConstants.remindersKey) ?? [];

    return remindersJson
        .map((json) => Reminder.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {
    final reminders = getReminders();
    reminders.add(reminder);

    final remindersJson =
        reminders.map((r) => jsonEncode(r.toJson())).toList();

    await sharedPreferences.setStringList(
        AppConstants.remindersKey, remindersJson);
  }

  @override
  Future<void> deleteReminder(String id) async {
    final reminders = getReminders();
    reminders.removeWhere((r) => r.id == id);

    final remindersJson =
        reminders.map((r) => jsonEncode(r.toJson())).toList();

    await sharedPreferences.setStringList(
        AppConstants.remindersKey, remindersJson);
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final reminders = getReminders();
    final index = reminders.indexWhere((r) => r.id == reminder.id);

    if (index != -1) {
      reminders[index] = reminder;

      final remindersJson =
          reminders.map((r) => jsonEncode(r.toJson())).toList();

      await sharedPreferences.setStringList(
          AppConstants.remindersKey, remindersJson);
    }
  }
}
