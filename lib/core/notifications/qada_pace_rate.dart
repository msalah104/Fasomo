import 'package:equatable/equatable.dart';

/// How fast the suggested make-up pace asks the user to go, so the
/// notification text can say it. Worked out by the tracker from the days
/// owed and the days left before Ramadan.
sealed class QadaPaceRate extends Equatable {
  const new();
}

/// A number of make-up days each week, fewer than every day.
final class PerWeekPace extends QadaPaceRate {
  const new(this.daysPerWeek)
    : assert(daysPerWeek >= 1 && daysPerWeek <= 6, 'daysPerWeek is 1..6');

  /// 1–6.
  final int daysPerWeek;

  @override
  List<Object> get props => [daysPerWeek];
}

/// Every day a make-up fast is allowed until Ramadan, exactly enough.
final class EveryDayPace extends QadaPaceRate {
  const new();

  @override
  List<Object> get props => [];
}

/// More days owed than there are days left before Ramadan: every available
/// day is suggested and the rest stays owed after it.
final class NotEnoughDaysPace extends QadaPaceRate {
  const new(this.availableDays) : assert(availableDays >= 0, 'not negative');

  /// The days a make-up fast is still allowed on before Ramadan.
  final int availableDays;

  @override
  List<Object> get props => [availableDays];
}
