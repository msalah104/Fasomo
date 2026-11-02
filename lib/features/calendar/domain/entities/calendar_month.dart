import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';

/// One Hijri month with its days, as drawn in the year view.
class CalendarMonth extends Equatable {
  const new({required this.month, required this.days});

  final HijriMonth month;

  /// Every day of [month], in order.
  final List<CalendarDay> days;

  /// Whether today falls in this month.
  bool get containsToday => days.any((day) => day.isToday);

  /// How many of the days are fasting days.
  int get fastingDayCount => days.where((day) => day.isFastingDay).length;

  @override
  List<Object> get props => [month, days];
}
