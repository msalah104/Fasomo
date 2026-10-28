import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';

abstract interface class FastingRepository {
  /// Today in both calendars.
  Result<HijriDateInfo, CalendarFailure> getCurrentHijriDate();

  /// The next [limit] fasting days, starting today.
  Result<List<FastingDay>, CalendarFailure> getUpcomingFastingDays({
    int limit,
  });
}
