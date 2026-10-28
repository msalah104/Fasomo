import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';

abstract interface class CalendarRepository {
  /// The Hijri month containing today.
  Result<HijriMonth, CalendarFailure> getCurrentMonth();

  /// Every day of [month], in order.
  Result<List<CalendarDay>, CalendarFailure> getMonth(HijriMonth month);
}
