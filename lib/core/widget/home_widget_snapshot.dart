import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';

/// What the home-screen widget shows on one day, already in the app's
/// language.
final class HomeWidgetDay extends Equatable {
  const new({
    required this.date,
    required this.hijriText,
    required this.gregorianText,
    required this.nextFastText,
    required this.isFastingDay,
  });

  /// Local midnight of the day this entry is for.
  final DateTime date;

  /// e.g. "13 Jumada al-Akhirah 1448 AH".
  final String hijriText;

  /// e.g. "Monday, November 23".
  final String gregorianText;

  /// e.g. "Today: White Days" or "White Days in 3 days".
  final String nextFastText;

  /// Whether [date] is itself a fasting day, which the widget highlights.
  final bool isFastingDay;

  @override
  List<Object> get props => [
    date,
    hijriText,
    gregorianText,
    nextFastText,
    isFastingDay,
  ];
}

/// Everything the home-screen widget needs, computed by the app.
///
/// The widget reads it without the app running, so it holds an entry for
/// each of the next few days: at midnight the widget moves on to the next
/// entry by itself, and only shows [staleText] once the app has not been
/// opened for longer than the entries last.
final class HomeWidgetSnapshot extends Equatable {
  const new({
    required this.generatedFor,
    required this.isRightToLeft,
    required this.days,
    required this.staleText,
  });

  /// Local midnight of the day the snapshot was computed on.
  final DateTime generatedFor;

  /// Whether the app's language is written right to left.
  final bool isRightToLeft;

  /// One entry per day from [generatedFor], in date order. Shorter only at
  /// the very end of the supported calendar range.
  final List<HomeWidgetDay> days;

  /// Shown when no entry matches the current day.
  final String staleText;

  /// The entry for [date]'s calendar day, or `null` when there is none.
  HomeWidgetDay? dayFor(DateTime date) {
    for (final day in days) {
      if (CalendarDays.isSameDay(day.date, date)) return day;
    }
    return null;
  }

  @override
  List<Object> get props => [generatedFor, isRightToLeft, days, staleText];
}
