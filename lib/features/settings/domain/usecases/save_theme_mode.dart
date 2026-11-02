import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';

class SaveThemeMode
    implements UseCase<Future<Result<void, StorageFailure>>, AppThemeMode> {
  const new(this.repository);

  final SettingsRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(AppThemeMode mode) =>
      repository.saveThemeMode(mode);
}
