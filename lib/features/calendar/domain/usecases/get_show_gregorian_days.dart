import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_preferences_repository.dart';

class GetShowGregorianDays
    implements UseCase<Result<bool, StorageFailure>, NoParams> {
  const new(this.repository);

  final CalendarPreferencesRepository repository;

  @override
  Result<bool, StorageFailure> call(NoParams params) =>
      repository.getShowGregorianDays();
}
