import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';

class GetHijriMonth implements UseCase<List<CalendarDay>, HijriMonthParams> {
  new(this.repository);
  final CalendarRepository repository;

  @override
  List<CalendarDay> call(HijriMonthParams params) {
    return repository.getHijriMonth(params.month, params.year);
  }
}

class HijriMonthParams {
  new({required this.month, required this.year});
  final int month;
  final int year;
}
