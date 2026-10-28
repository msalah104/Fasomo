import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';

abstract class CalendarRepository {
  List<CalendarDay> getHijriMonth(int month, int year);
}
