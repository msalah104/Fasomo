import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// What the log says about one day.
enum DayMark { fasted, makeUp, missed }

/// How many days of one fasting type were fasted in a period.
class TypeTotal extends Equatable {
  const new({required this.type, required this.fasted, required this.due})
    : assert(fasted <= due, 'cannot fast more days than were due');

  final FastingType type;
  final int fasted;

  /// The type's days from the start of the period up to and including today.
  final int due;

  @override
  List<Object> get props => [type, fasted, due];
}

/// Fasted and due fasting days in a Hijri month or year, so far.
class PeriodTotals extends Equatable {
  const new({
    required this.fastedDays,
    required this.dueDays,
    required this.byType,
  });

  static const empty = PeriodTotals(fastedDays: 0, dueDays: 0, byType: []);

  /// Fasting days fasted; a day with several types counts once.
  final int fastedDays;
  final int dueDays;

  /// One entry per type with at least one day due, in [FastingType] order.
  final List<TypeTotal> byType;

  @override
  List<Object> get props => [fastedDays, dueDays, byType];
}

/// A logged day in both calendars.
class LoggedDay extends Equatable {
  const new({required this.date, required this.hijri});

  /// Local midnight of the Gregorian day.
  final DateTime date;
  final HijriDate hijri;

  @override
  List<Object> get props => [date, hijri];
}

/// Make-up fasts owed and made up for one Ramadan.
class QadaYear extends Equatable {
  const new({
    required this.hijriYear,
    required this.owed,
    required this.madeUp,
    required this.extraOwed,
  }) : assert(madeUp <= owed, 'a year cannot be made up beyond what it owes');

  final int hijriYear;

  /// Missed days marked in this Ramadan plus [extraOwed].
  final int owed;

  /// Make-up fasts allocated to this year, oldest year first.
  final int madeUp;

  /// The part of [owed] entered as a number rather than marked day by day.
  final int extraOwed;

  int get remaining => owed - madeUp;

  @override
  List<Object> get props => [hijriYear, owed, madeUp, extraOwed];
}

/// The make-up (Qada) balance derived from the log.
class QadaSummary extends Equatable {
  const new({
    required this.owed,
    required this.madeUp,
    required this.byYear,
    required this.latestOwableYear,
    this.daysUntilRamadan,
    this.makeUps = const [],
  });

  static const empty = QadaSummary(
    owed: 0,
    madeUp: 0,
    byYear: [],
    latestOwableYear: null,
  );

  final int owed;

  /// Every make-up fast logged, including any beyond what is owed.
  final int madeUp;

  /// Years that owe at least one day, oldest first.
  final List<QadaYear> byYear;

  /// The latest Hijri year whose Ramadan has started, so days can be owed
  /// for it; `null` outside the supported calendar range.
  final int? latestOwableYear;

  /// Calendar days until the next Ramadan begins; `null` during Ramadan or
  /// past the supported calendar range.
  final int? daysUntilRamadan;

  /// Every make-up fast logged, newest first.
  final List<LoggedDay> makeUps;

  int get remaining => owed > madeUp ? owed - madeUp : 0;

  /// The days entered for [hijriYear] rather than marked day by day.
  int extraOwedFor(int hijriYear) =>
      byYear.where((y) => y.hijriYear == hijriYear).firstOrNull?.extraOwed ?? 0;

  @override
  List<Object?> get props => [
    owed,
    madeUp,
    byYear,
    latestOwableYear,
    daysUntilRamadan,
    makeUps,
  ];
}

/// The fasting log and everything derived from it. Streaks and totals are
/// computed from [fastedDays] on every read and never stored.
class FastLogSummary extends Equatable {
  const new({
    required this.fastedDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.month,
    required this.year,
    this.makeUpDays = const {},
    this.missedRamadanDays = const {},
    this.qada = QadaSummary.empty,
  });

  static const empty = FastLogSummary(
    fastedDays: {},
    currentStreak: 0,
    longestStreak: 0,
    month: PeriodTotals.empty,
    year: PeriodTotals.empty,
  );

  /// Local midnights of every day marked as fasted.
  final Set<DateTime> fastedDays;

  /// The fasted days that were make-up fasts.
  final Set<DateTime> makeUpDays;

  /// Ramadan days marked as missed.
  final Set<DateTime> missedRamadanDays;

  /// Consecutive fasting days fasted, ending at the latest one. Today does not
  /// break it before it is marked.
  final int currentStreak;
  final int longestStreak;

  /// The current Hijri month so far.
  final PeriodTotals month;

  /// The current Hijri year so far.
  final PeriodTotals year;

  final QadaSummary qada;

  bool get isEmpty => fastedDays.isEmpty;

  bool isFasted(DateTime date) =>
      fastedDays.contains(CalendarDays.dateOnly(date));

  bool isMakeUp(DateTime date) =>
      makeUpDays.contains(CalendarDays.dateOnly(date));

  bool isMissed(DateTime date) =>
      missedRamadanDays.contains(CalendarDays.dateOnly(date));

  /// The day's mark, or `null` when nothing is logged for it.
  DayMark? markFor(DateTime date) {
    if (isMakeUp(date)) return DayMark.makeUp;
    if (isFasted(date)) return DayMark.fasted;
    if (isMissed(date)) return DayMark.missed;
    return null;
  }

  @override
  List<Object> get props => [
    fastedDays,
    currentStreak,
    longestStreak,
    month,
    year,
    makeUpDays,
    missedRamadanDays,
    qada,
  ];
}
