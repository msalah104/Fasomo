import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_preferences_repository.dart';

/// Saves whether day cells show the Gregorian day number; the parameter is
/// the new choice.
class SaveShowGregorianDays
    implements UseCase<Future<Result<void, StorageFailure>>, bool> {
  const new(this.repository);

  final CalendarPreferencesRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(bool show) =>
      repository.saveShowGregorianDays(show: show);
}
