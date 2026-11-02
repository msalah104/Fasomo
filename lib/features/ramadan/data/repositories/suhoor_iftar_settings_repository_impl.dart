import 'dart:convert';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/repositories/suhoor_iftar_settings_repository.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the suhoor and iftar reminder settings in [SharedPreferences] as
/// one JSON value: `{"suhoor": true, "suhoorMinutes": 45, "iftar": true,
/// "iftarMinutes": 0, "otherDays": false}`.
class SuhoorIftarSettingsRepositoryImpl
    implements SuhoorIftarSettingsRepository {
  const new({required this.sharedPreferences});

  static const String storageKey = 'ramadan.reminders';

  /// The longest lead time accepted from storage, in minutes.
  static const int maxMinutesBefore = 180;

  final SharedPreferences sharedPreferences;

  @override
  Result<SuhoorIftarSettings, StorageFailure> getSettings() {
    final raw = sharedPreferences.get(storageKey);
    if (raw == null) return const Ok(SuhoorIftarSettings.defaults);
    if (raw is! String) return const Err(StorageReadFailed(storageKey));
    try {
      return switch (jsonDecode(raw)) {
        {
          'suhoor': final bool suhoor,
          'suhoorMinutes': final int suhoorMinutes,
          'iftar': final bool iftar,
          'iftarMinutes': final int iftarMinutes,
          'otherDays': final bool otherDays,
        }
            when _isLeadTime(suhoorMinutes) && _isLeadTime(iftarMinutes) =>
          Ok(
            SuhoorIftarSettings(
              suhoorEnabled: suhoor,
              suhoorMinutesBeforeFajr: suhoorMinutes,
              iftarEnabled: iftar,
              iftarMinutesBeforeMaghrib: iftarMinutes,
              onOtherFastingDays: otherDays,
            ),
          ),
        _ => const Err(StorageReadFailed(storageKey)),
      };
    } on FormatException catch (e, st) {
      AppLog.error('ramadan.reminders.read', e, st);
      return const Err(StorageReadFailed(storageKey));
    }
  }

  @override
  Future<Result<void, StorageFailure>> saveSettings(
    SuhoorIftarSettings settings,
  ) async {
    final encoded = jsonEncode({
      'suhoor': settings.suhoorEnabled,
      'suhoorMinutes': settings.suhoorMinutesBeforeFajr,
      'iftar': settings.iftarEnabled,
      'iftarMinutes': settings.iftarMinutesBeforeMaghrib,
      'otherDays': settings.onOtherFastingDays,
    });
    try {
      final saved = await sharedPreferences.setString(storageKey, encoded);
      return saved ? const Ok(null) : const Err(StorageWriteFailed(storageKey));
    } on PlatformException catch (e, st) {
      AppLog.error('ramadan.reminders.write', e, st);
      return const Err(StorageWriteFailed(storageKey));
    }
  }

  static bool _isLeadTime(int minutes) =>
      minutes >= 0 && minutes <= maxMinutesBefore;
}
