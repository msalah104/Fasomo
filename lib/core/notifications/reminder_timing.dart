import 'package:equatable/equatable.dart';

/// A local wall-clock time of day. Stored as wall-clock, never as a UTC
/// instant, so a reminder keeps its hour across daylight-saving changes.
class WallClockTime extends Equatable implements Comparable<WallClockTime> {
  const new(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour must be 0..23'),
      assert(minute >= 0 && minute < 60, 'minute must be 0..59');

  final int hour;
  final int minute;

  int get minutesOfDay => hour * 60 + minute;

  @override
  int compareTo(WallClockTime other) =>
      minutesOfDay.compareTo(other.minutesOfDay);

  @override
  List<Object> get props => [hour, minute];
}

/// When a reminder fires relative to the fasting day it announces.
class ReminderTiming extends Equatable {
  const new({required this.daysBefore, required this.time})
    : assert(daysBefore >= 0, 'daysBefore must not be negative');

  /// The evening before, in time to plan suhoor.
  static const ReminderTiming dayBefore = ReminderTiming(
    daysBefore: 1,
    time: WallClockTime(20, 0),
  );

  /// Early on the fasting day itself.
  static const ReminderTiming morningOf = ReminderTiming(
    daysBefore: 0,
    time: WallClockTime(7, 0),
  );

  /// 0 = on the fasting day, 1 = the day before.
  final int daysBefore;
  final WallClockTime time;

  /// The local wall-clock moment the reminder for [fastingDate] fires.
  ///
  /// Built from calendar fields, so it lands on the intended day and hour
  /// even when a DST change falls in between.
  DateTime fireTimeFor(DateTime fastingDate) => DateTime(
    fastingDate.year,
    fastingDate.month,
    fastingDate.day - daysBefore,
    time.hour,
    time.minute,
  );

  @override
  List<Object> get props => [daysBefore, time];
}
