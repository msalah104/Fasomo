import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';

abstract interface class SettingsRepository {
  /// The saved language, or [AppLanguage.system] when none was saved.
  Result<AppLanguage, StorageFailure> getLanguage();

  Future<Result<void, StorageFailure>> saveLanguage(AppLanguage language);
}
