import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
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
  });

  /// Make-up days still owed.
  final int remaining;

  @override
  List<Object> get props => [date, timing, remaining];
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
