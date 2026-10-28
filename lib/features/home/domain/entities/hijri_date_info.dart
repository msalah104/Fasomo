import 'package:equatable/equatable.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriDateInfo extends Equatable {
  const new({
    required this.hijriDate,
    required this.gregorianDate,
    required this.formattedHijri,
    required this.formattedGregorian,
  });
  final HijriCalendar hijriDate;
  final DateTime gregorianDate;
  final String formattedHijri;
  final String formattedGregorian;

  @override
  List<Object?> get props => [
    hijriDate,
    gregorianDate,
    formattedHijri,
    formattedGregorian,
  ];
}
