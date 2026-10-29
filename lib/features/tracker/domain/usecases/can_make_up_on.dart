import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';

/// Whether a day may be logged as a make-up fast; used to limit the day
/// picker to valid days.
class CanMakeUpOn implements UseCase<bool, DateTime> {
  const new(this.repository);

  final FastLogRepository repository;

  @override
  bool call(DateTime date) => repository.canMakeUpOn(date);
}
