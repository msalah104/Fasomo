import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';

class GetCurrentHijriDate
    implements UseCase<Result<HijriDateInfo, CalendarFailure>, NoParams> {
  const new(this.repository);

  final FastingRepository repository;

  @override
  Result<HijriDateInfo, CalendarFailure> call(NoParams params) =>
      repository.getCurrentHijriDate();
}
