import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';

abstract class FastingRepository {
  HijriDateInfo getCurrentHijriDate(String languageCode);
  List<FastingDay> getUpcomingFastingDays(String languageCode);
}
