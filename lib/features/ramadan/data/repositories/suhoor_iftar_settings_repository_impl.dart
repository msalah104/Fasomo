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
      return switch (decode(jsonDecode(raw))) {
        final settings? => Ok(settings),
        null => const Err(StorageReadFailed(storageKey)),
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
    final encoded = jsonEncode(encode(settings));
    try {
      final saved = await sharedPreferences.setString(storageKey, encoded);
      return saved ? const Ok(null) : const Err(StorageWriteFailed(storageKey));
    } on PlatformException catch (e, st) {
      AppLog.error('ramadan.reminders.write', e, st);
      return const Err(StorageWriteFailed(storageKey));
    }
  }

  /// [settings] as the JSON object they are stored and backed up as.
  static Map<String, Object?> encode(SuhoorIftarSettings settings) => {
    'suhoor': settings.suhoorEnabled,
    'suhoorMinutes': settings.suhoorMinutesBeforeFajr,
    'iftar': settings.iftarEnabled,
    'iftarMinutes': settings.iftarMinutesBeforeMaghrib,
    'otherDays': settings.onOtherFastingDays,
  };

  /// The settings in [json], or `null` when it is not what [encode] writes.
  static SuhoorIftarSettings? decode(Object? json) => switch (json) {
    {
      'suhoor': final bool suhoor,
      'suhoorMinutes': final int suhoorMinutes,
      'iftar': final bool iftar,
      'iftarMinutes': final int iftarMinutes,
      'otherDays': final bool otherDays,
    }
        when _isLeadTime(suhoorMinutes) && _isLeadTime(iftarMinutes) =>
      SuhoorIftarSettings(
        suhoorEnabled: suhoor,
        suhoorMinutesBeforeFajr: suhoorMinutes,
        iftarEnabled: iftar,
        iftarMinutesBeforeMaghrib: iftarMinutes,
        onOtherFastingDays: otherDays,
      ),
    _ => null,
  };

  static bool _isLeadTime(int minutes) =>
      minutes >= 0 && minutes <= maxMinutesBefore;
}
