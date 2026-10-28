import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';

class GetUpcomingFastingDays
    implements
        UseCase<Result<List<FastingDay>, CalendarFailure>, UpcomingFrom> {
  const new(this.repository);

  final FastingRepository repository;

  @override
  Result<List<FastingDay>, CalendarFailure> call(UpcomingFrom params) =>
      repository.getUpcomingFastingDays(from: params.date);
}

/// Where the upcoming list starts: [date], or today when null.
class UpcomingFrom extends Equatable {
  const new([this.date]);

  final DateTime? date;

  @override
  List<Object?> get props => [date];
}
