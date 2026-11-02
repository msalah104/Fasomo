import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/repositories/suhoor_iftar_settings_repository.dart';

/// Replaces the suhoor and iftar reminder settings.
class SaveSuhoorIftarSettings
    implements
        UseCase<Future<Result<void, StorageFailure>>, SuhoorIftarSettings> {
  const new(this.repository);

  final SuhoorIftarSettingsRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(SuhoorIftarSettings settings) =>
      repository.saveSettings(settings);
}
