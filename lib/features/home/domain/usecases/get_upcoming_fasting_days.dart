import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';

class GetUpcomingFastingDays
    implements UseCase<Result<List<FastingDay>, CalendarFailure>, NoParams> {
  const new(this.repository);

  final FastingRepository repository;

  @override
  Result<List<FastingDay>, CalendarFailure> call(NoParams params) =>
      repository.getUpcomingFastingDays();
}
