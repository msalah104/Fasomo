import 'package:equatable/equatable.dart';
import 'package:fasomo/core/notifications/qada_pace_rate.dart';

/// The suggested make-up pace: how many days a week it takes to pay off the
/// balance before the next Ramadan, and the concrete days to do it on.
///
/// Worked out again on every read, so it adapts as the balance changes.
class QadaPace extends Equatable {
  const new({
    required this.rate,
    required this.days,
    required this.owed,
    required this.availableDays,
    required this.ramadanStart,
  });

  final QadaPaceRate rate;

  /// The suggested make-up days, earliest first: as many as [owed], or
  /// every available day when there aren't enough.
  final List<DateTime> days;

  /// Make-up days still owed.
  final int owed;

  /// Days from tomorrow until Ramadan on which a make-up fast is allowed.
  final int availableDays;

  /// Local midnight of the first day of the Ramadan the pace aims at.
  final DateTime ramadanStart;

  /// The next suggested day, or `null` when no day is left before Ramadan.
  DateTime? get next => days.isEmpty ? null : days.first;

  @override
  List<Object> get props => [rate, days, owed, availableDays, ramadanStart];
}
