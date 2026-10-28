import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';

class GetLanguage
    implements UseCase<Result<AppLanguage, StorageFailure>, NoParams> {
  const new(this.repository);

  final SettingsRepository repository;

  @override
  Result<AppLanguage, StorageFailure> call(NoParams params) =>
      repository.getLanguage();
}
