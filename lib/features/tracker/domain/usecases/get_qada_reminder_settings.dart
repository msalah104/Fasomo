import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/domain/repositories/qada_reminder_repository.dart';

class GetQadaReminderSettings
    implements UseCase<Result<QadaReminderSettings, StorageFailure>, NoParams> {
  const new(this.repository);

  final QadaReminderRepository repository;

  @override
  Result<QadaReminderSettings, StorageFailure> call(NoParams params) =>
      repository.getSettings();
}
