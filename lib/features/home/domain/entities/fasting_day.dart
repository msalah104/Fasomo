import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// An upcoming day on which at least one kind of fasting applies.
class FastingDay extends Equatable {
  const new({
    required this.hijriDate,
    required this.gregorianDate,
    required this.types,
    required this.daysUntil,
  }) : assert(types.length > 0, 'a fasting day has at least one type');

  final HijriDate hijriDate;

  /// Local midnight of the Gregorian day.
  final DateTime gregorianDate;

  /// Sorted by priority; never empty.
  final List<FastingType> types;

  /// Calendar days from today: 0 for today, 1 for tomorrow.
  final int daysUntil;

  FastingType get primaryType => types.first;

  bool get isObligatory => types.any((type) => type.isObligatory);

  @override
  List<Object> get props => [hijriDate, gregorianDate, types, daysUntil];
}
