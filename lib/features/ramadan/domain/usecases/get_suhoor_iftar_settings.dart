import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/repositories/suhoor_iftar_settings_repository.dart';

/// The saved suhoor and iftar reminder settings, or the defaults.
class GetSuhoorIftarSettings
    implements UseCase<Result<SuhoorIftarSettings, StorageFailure>, NoParams> {
  const new(this.repository);

  final SuhoorIftarSettingsRepository repository;

  @override
  Result<SuhoorIftarSettings, StorageFailure> call(NoParams params) =>
      repository.getSettings();
}
