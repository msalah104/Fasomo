import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/domain/repositories/qada_reminder_repository.dart';

class SaveQadaReminderSettings
    implements
        UseCase<Future<Result<void, StorageFailure>>, QadaReminderSettings> {
  const new(this.repository);

  final QadaReminderRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(QadaReminderSettings settings) =>
      repository.saveSettings(settings);
}
