import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';

class SaveLanguage
    implements UseCase<Future<Result<void, StorageFailure>>, AppLanguage> {
  const new(this.repository);

  final SettingsRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(AppLanguage language) =>
      repository.saveLanguage(language);
}
