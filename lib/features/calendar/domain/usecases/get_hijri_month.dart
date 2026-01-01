import '../../../../core/usecases/usecase.dart';
import '../entities/calendar_day.dart';
import '../repositories/calendar_repository.dart';

class GetHijriMonth implements UseCase<List<CalendarDay>, HijriMonthParams> {
  final CalendarRepository repository;

  GetHijriMonth(this.repository);

  @override
  List<CalendarDay> call(HijriMonthParams params) {
    return repository.getHijriMonth(params.month, params.year);
  }
}

class HijriMonthParams {
  final int month;
  final int year;

  HijriMonthParams({required this.month, required this.year});
}
