import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';

class GetHijriMonth
    implements UseCase<Result<List<CalendarDay>, CalendarFailure>, HijriMonth> {
  const new(this.repository);

  final CalendarRepository repository;

  @override
  Result<List<CalendarDay>, CalendarFailure> call(HijriMonth month) =>
      repository.getMonth(month);
}
