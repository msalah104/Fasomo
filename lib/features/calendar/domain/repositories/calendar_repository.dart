import '../entities/calendar_day.dart';

abstract class CalendarRepository {
  List<CalendarDay> getHijriMonth(int month, int year);
}
