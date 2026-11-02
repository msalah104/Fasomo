import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';

class GetThemeMode
    implements UseCase<Result<AppThemeMode, StorageFailure>, NoParams> {
  const new(this.repository);

  final SettingsRepository repository;

  @override
  Result<AppThemeMode, StorageFailure> call(NoParams params) =>
      repository.getThemeMode();
}
