import 'package:equatable/equatable.dart';
import 'package:hijri/hijri.dart';

class HijriDateInfo extends Equatable {
  final HijriCalendar hijriDate;
  final DateTime gregorianDate;
  final String formattedHijri;
  final String formattedGregorian;

  const HijriDateInfo({
    required this.hijriDate,
    required this.gregorianDate,
    required this.formattedHijri,
    required this.formattedGregorian,
  });

  @override
  List<Object?> get props => [
        hijriDate,
        gregorianDate,
        formattedHijri,
        formattedGregorian,
      ];
}
