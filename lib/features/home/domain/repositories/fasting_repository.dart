import '../entities/fasting_day.dart';
import '../entities/hijri_date_info.dart';

abstract class FastingRepository {
  HijriDateInfo getCurrentHijriDate(String languageCode);
  List<FastingDay> getUpcomingFastingDays(String languageCode);
}
