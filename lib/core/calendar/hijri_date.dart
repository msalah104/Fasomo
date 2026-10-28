import 'package:equatable/equatable.dart';

/// An immutable Hijri (Umm al-Qura) calendar date.
class HijriDate extends Equatable implements Comparable<HijriDate> {
  const new(this.year, this.month, this.day)
    : assert(month >= 1 && month <= 12, 'month must be 1..12'),
      assert(day >= 1 && day <= 30, 'day must be 1..30');

  final int year;

  /// 1 = Muharram … 12 = Dhul Hijjah.
  final int month;
  final int day;

  HijriMonth get hijriMonth => HijriMonth(year, month);

  @override
  int compareTo(HijriDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  List<Object> get props => [year, month, day];

  @override
  String toString() => 'HijriDate($year-$month-$day)';
}

/// A Hijri month of a specific year, used for calendar navigation.
class HijriMonth extends Equatable {
  const new(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'month must be 1..12');

  final int year;
  final int month;

  HijriMonth get next =>
      month == 12 ? HijriMonth(year + 1, 1) : HijriMonth(year, month + 1);

  HijriMonth get previous =>
      month == 1 ? HijriMonth(year - 1, 12) : HijriMonth(year, month - 1);

  @override
  List<Object> get props => [year, month];

  @override
  String toString() => 'HijriMonth($year-$month)';
}
