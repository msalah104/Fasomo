import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';

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

/// The fasting log and everything derived from it. Streaks and totals are
/// computed from [fastedDays] on every read and never stored.
class FastLogSummary extends Equatable {
  const new({
    required this.fastedDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.month,
    required this.year,
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

  /// Consecutive fasting days fasted, ending at the latest one. Today does not
  /// break it before it is marked.
  final int currentStreak;
  final int longestStreak;

  /// The current Hijri month so far.
  final PeriodTotals month;

  /// The current Hijri year so far.
  final PeriodTotals year;

  bool get isEmpty => fastedDays.isEmpty;

  bool isFasted(DateTime date) =>
      fastedDays.contains(CalendarDays.dateOnly(date));

  @override
  List<Object> get props => [
    fastedDays,
    currentStreak,
    longestStreak,
    month,
    year,
  ];
}
