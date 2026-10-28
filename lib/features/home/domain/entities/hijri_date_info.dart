import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// Today's date in both calendars.
class HijriDateInfo extends Equatable {
  const new({required this.hijriDate, required this.gregorianDate});

  final HijriDate hijriDate;
  final DateTime gregorianDate;

  @override
  List<Object> get props => [hijriDate, gregorianDate];
}
