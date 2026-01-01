import 'package:equatable/equatable.dart';
import 'package:hijri/hijri.dart';

enum FastingType {
  whiteDays,
  mondayThursday,
  arafah,
  ashura,
  tasua,
  ramadan,
  shawwal,
  other,
}

class FastingDay extends Equatable {
  final HijriCalendar hijriDate;
  final DateTime gregorianDate;
  final FastingType type;
  final String title;
  final String description;
  final bool isMandatory;
  final int daysUntil;

  const FastingDay({
    required this.hijriDate,
    required this.gregorianDate,
    required this.type,
    required this.title,
    required this.description,
    required this.isMandatory,
    required this.daysUntil,
  });

  @override
  List<Object?> get props => [
        hijriDate,
        gregorianDate,
        type,
        title,
        description,
        isMandatory,
        daysUntil,
      ];
}
