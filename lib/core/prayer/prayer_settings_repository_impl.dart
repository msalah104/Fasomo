import 'dart:convert';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the prayer settings in [SharedPreferences] as one JSON value:
/// `{"method": "egyptian", "asr": "hanafi", "highLatitude":
/// "seventhOfTheNight", "adjust": {"maghrib": 3}}`. No `method` means
/// automatic; adjustments left out are zero.
class PrayerSettingsRepositoryImpl implements PrayerSettingsRepository {
  const new({required this.sharedPreferences});

  static const String storageKey = 'prayer.settings';

  final SharedPreferences sharedPreferences;

  @override
  Result<PrayerSettings, StorageFailure> getSettings() {
    final raw = sharedPreferences.get(storageKey);
    if (raw == null) return const Ok(PrayerSettings.defaults);
    if (raw is! String) return const Err(StorageReadFailed(storageKey));
    try {
      return switch (_decode(jsonDecode(raw))) {
        final settings? => Ok(settings),
        null => const Err(StorageReadFailed(storageKey)),
      };
    } on FormatException catch (e, st) {
      AppLog.error('prayer.settings.read', e, st);
      return const Err(StorageReadFailed(storageKey));
    }
  }

  @override
  Future<Result<void, StorageFailure>> saveSettings(
    PrayerSettings settings,
  ) async {
    final adjustments = {
      for (final prayer in Prayer.values)
        if (settings.adjustments[prayer] != 0)
          prayer.name: settings.adjustments[prayer],
    };
    final encoded = jsonEncode({
      if (settings.method case final method?) 'method': method.name,
      'asr': settings.asrMethod.name,
      'highLatitude': settings.highLatitudeRule.name,
      if (adjustments.isNotEmpty) 'adjust': adjustments,
    });
    try {
      final saved = await sharedPreferences.setString(storageKey, encoded);
      return saved ? const Ok(null) : const Err(StorageWriteFailed(storageKey));
    } on PlatformException catch (e, st) {
      AppLog.error('prayer.settings.write', e, st);
      return const Err(StorageWriteFailed(storageKey));
    }
  }

  static PrayerSettings? _decode(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final method = switch (json['method']) {
      null => null,
      final String name => _byName(CalculationMethod.values, name),
      _ => null,
    };
    if (json['method'] != null && method == null) return null;
    final asr = _byName(AsrMethod.values, json['asr']);
    final rule = _byName(HighLatitudeRule.values, json['highLatitude']);
    final adjustments = _decodeAdjustments(json['adjust']);
    if (asr == null || rule == null || adjustments == null) return null;
    return PrayerSettings(
      method: method,
      asrMethod: asr,
      highLatitudeRule: rule,
      adjustments: adjustments,
    );
  }

  static PrayerAdjustments? _decodeAdjustments(Object? json) {
    if (json == null) return PrayerAdjustments.none;
    if (json is! Map<String, Object?>) return null;
    var adjustments = PrayerAdjustments.none;
    for (final MapEntry(:key, :value) in json.entries) {
      final prayer = _byName(Prayer.values, key);
      if (prayer == null || value is! int) return null;
      adjustments = adjustments.withMinutes(prayer, value);
    }
    return adjustments;
  }

  static T? _byName<T extends Enum>(List<T> values, Object? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
