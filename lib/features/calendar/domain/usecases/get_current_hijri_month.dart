import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';

class GetCurrentHijriMonth
    implements UseCase<Result<HijriMonth, CalendarFailure>, NoParams> {
  const new(this.repository);

  final CalendarRepository repository;

  @override
  Result<HijriMonth, CalendarFailure> call(NoParams params) =>
      repository.getCurrentMonth();
}
