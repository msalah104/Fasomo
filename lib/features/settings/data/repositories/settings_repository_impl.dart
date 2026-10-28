import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const new({required this.sharedPreferences});

  static const String _key = AppConstants.languageKey;

  final SharedPreferences sharedPreferences;

  @override
  Result<AppLanguage, StorageFailure> getLanguage() {
    final stored = sharedPreferences.get(_key);
    if (stored == null) return const Ok(AppLanguage.system);
    for (final language in AppLanguage.values) {
      if (language.name == stored) return Ok(language);
    }
    return const Err(StorageReadFailed(_key));
  }

  @override
  Future<Result<void, StorageFailure>> saveLanguage(
    AppLanguage language,
  ) async {
    try {
      final saved = await sharedPreferences.setString(_key, language.name);
      return saved ? const Ok(null) : const Err(StorageWriteFailed(_key));
    } on PlatformException catch (e, st) {
      AppLog.error('settings.language.write', e, st);
      return const Err(StorageWriteFailed(_key));
    }
  }
}
