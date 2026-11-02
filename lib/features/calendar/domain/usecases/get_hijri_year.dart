import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_month.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';

/// The twelve months of a Hijri year; the parameter is the year.
class GetHijriYear
    implements UseCase<Result<List<CalendarMonth>, CalendarFailure>, int> {
  const new(this.repository);

  final CalendarRepository repository;

  @override
  Result<List<CalendarMonth>, CalendarFailure> call(int year) =>
      repository.getYear(year);
}
