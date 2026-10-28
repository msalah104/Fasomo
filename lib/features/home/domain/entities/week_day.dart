import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// One day of the seven-day strip on Home, fasting or not.
class WeekDay extends Equatable {
  const new({
    required this.hijriDate,
    required this.gregorianDate,
    required this.types,
  });

  final HijriDate hijriDate;

  /// Local midnight of the Gregorian day.
  final DateTime gregorianDate;

  /// Sorted by priority; empty on an ordinary day.
  final List<FastingType> types;

  bool get isFastingDay => types.isNotEmpty;

  @override
  List<Object> get props => [hijriDate, gregorianDate, types];
}
