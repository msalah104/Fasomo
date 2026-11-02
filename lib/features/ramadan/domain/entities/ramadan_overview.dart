import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';

/// Where today stands relative to Ramadan, and what Home shows for it.
sealed class RamadanOverview extends Equatable {
  const new();

  /// How many days before 1 Ramadan the countdown appears.
  static const int countdownDays = 30;
}

/// Ramadan is more than [RamadanOverview.countdownDays] away (or past the
/// supported calendar): nothing is shown.
final class RamadanNotNear extends RamadanOverview {
  const new();

  @override
  List<Object?> get props => [];
}

/// Ramadan starts in [daysUntil] days, 1 to
/// [RamadanOverview.countdownDays].
final class RamadanCountdown extends RamadanOverview {
  const new({
    required this.daysUntil,
    required this.startDate,
    this.firstSuhoorEnds,
  });

  final int daysUntil;

  /// Local midnight of 1 Ramadan, by the adjusted calendar.
  final DateTime startDate;

  /// Fajr on 1 Ramadan (UTC), given the day before so the first suhoor can
  /// be planned; `null` earlier or where Fajr is undefined.
  final DateTime? firstSuhoorEnds;

  @override
  List<Object?> get props => [daysUntil, startDate, firstSuhoorEnds];
}

/// Today is a day of Ramadan.
final class RamadanDay extends RamadanOverview {
  const new({
    required this.date,
    required this.hijriDate,
    required this.daysInMonth,
    required this.times,
    required this.location,
    required this.method,
    this.next,
  });

  /// Local midnight of today.
  final DateTime date;
  final HijriDate hijriDate;

  /// 29 or 30.
  final int daysInMonth;

  /// Today's prayer times, with Ramadan's Isha.
  final PrayerTimes times;

  /// Where the times are for.
  final GeoPoint location;
  final CalculationMethod method;

  /// The next suhoor end or iftar; `null` after the last iftar of the month
  /// or where neither is defined.
  final FastingMoment? next;

  /// 1 to [daysInMonth].
  int get dayOfRamadan => hijriDate.day;

  @override
  List<Object?> get props => [
    date,
    hijriDate,
    daysInMonth,
    times,
    location,
    method,
    next,
  ];
}

enum FastingMomentKind {
  /// Fajr, when eating and drinking stop.
  suhoorEnds,

  /// Maghrib, when the fast is broken.
  iftar,
}

/// The next moment of the fasting day and how long until it.
final class FastingMoment extends Equatable {
  const new({required this.kind, required this.at, required this.remaining});

  final FastingMomentKind kind;

  /// UTC.
  final DateTime at;

  /// From now until [at]; always positive.
  final Duration remaining;

  @override
  List<Object> get props => [kind, at, remaining];
}
