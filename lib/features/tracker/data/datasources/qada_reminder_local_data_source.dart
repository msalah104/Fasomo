import 'dart:convert';

import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the make-up reminder settings as one JSON string.
///
/// Throws [FormatException] for undecodable data and [StorageWriteException]
/// when the platform refuses a write; the repository converts both into
/// typed failures.
abstract interface class QadaReminderLocalDataSource {
  /// The saved settings, or `null` when none were saved.
  QadaReminderSettings? getSettings();
  Future<void> saveSettings(QadaReminderSettings settings);
}

class QadaReminderLocalDataSourceImpl implements QadaReminderLocalDataSource {
  const new({required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  QadaReminderSettings? getSettings() {
    final encoded = sharedPreferences.getString(AppConstants.qadaRemindersKey);
    if (encoded == null) return null;
    return QadaReminderSettings.tryFromJson(jsonDecode(encoded)) ??
        (throw FormatException('Malformed make-up reminders', encoded));
  }

  @override
  Future<void> saveSettings(QadaReminderSettings settings) async {
    final saved = await sharedPreferences.setString(
      AppConstants.qadaRemindersKey,
      jsonEncode(settings.toJson()),
    );
    if (!saved) {
      throw const StorageWriteException(AppConstants.qadaRemindersKey);
    }
  }
}
