import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/qada_pace_rate.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';

/// One dated thing a reminder source wants to announce. Sources say *what*
/// is happening; `ReminderComposer` decides the text and merges occurrences
/// that fall on the same day.
sealed class ReminderOccurrence extends Equatable {
  const new({required this.date, required this.timing});

  /// Local midnight of the day the occurrence is about.
  final DateTime date;
  final ReminderTiming timing;

  /// The local moment the notification fires.
  DateTime get fireAt => timing.fireTimeFor(date);
}

/// A recommended or obligatory fasting day with an enabled reminder.
final class FastingOccurrence extends ReminderOccurrence {
  const new({
    required super.date,
    required super.timing,
    required this.type,
    this.customMessage,
  });

  /// The highest-priority type with a reminder on.
  final FastingType type;
  final String? customMessage;

  @override
  List<Object?> get props => [date, timing, type, customMessage];
}

/// A day suggested for a make-up (Qada) fast.
final class QadaOccurrence extends ReminderOccurrence {
  const new({
    required super.date,
    required super.timing,
    required this.remaining,
    this.pace,
  });

  /// Make-up days still owed.
  final int remaining;

  /// The suggested pace this day was planned for, so the text can say it;
  /// `null` for a weekly or monthly day.
  final QadaPaceRate? pace;

  @override
  List<Object?> get props => [date, timing, remaining, pace];
}

/// Which meal a [SuhoorIftarOccurrence] is about.
enum FastingMeal {
  /// The pre-dawn meal, which ends at Fajr.
  suhoor,

  /// Breaking the fast, at Maghrib.
  iftar,
}

/// A reminder timed from a prayer: before Fajr for suhoor, at or before
/// Maghrib for iftar. Its [timing] is the resolved local minute it fires,
/// on its [date]; it is never merged with another notification.
final class SuhoorIftarOccurrence extends ReminderOccurrence {
  const new({
    required super.date,
    required super.timing,
    required this.meal,
    required this.prayerTime,
    required this.minutesBefore,
  });

  final FastingMeal meal;

  /// Fajr for suhoor, Maghrib for iftar (UTC).
  final DateTime prayerTime;

  /// How long before [prayerTime] it fires; 0 for at the time.
  final int minutesBefore;

  @override
  List<Object> get props => [date, timing, meal, prayerTime, minutesBefore];
}

/// A countdown to Ramadan while make-up days are still owed.
final class RamadanCountdownOccurrence extends ReminderOccurrence {
  const new({
    required super.date,
    required super.timing,
    required this.daysUntilRamadan,
    required this.remaining,
  });

  final int daysUntilRamadan;
  final int remaining;

  @override
  List<Object> get props => [date, timing, daysUntilRamadan, remaining];
}
