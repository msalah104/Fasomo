import 'package:equatable/equatable.dart';

/// Everything the user has logged. All dates are local midnights.
class FastLog extends Equatable {
  const new({
    this.fastedDays = const {},
    this.makeUpDays = const {},
    this.missedRamadanDays = const {},
    this.extraOwed = const {},
  });

  static const empty = FastLog();

  /// Days marked as fasted, make-up fasts included.
  final Set<DateTime> fastedDays;

  /// The fasted days that were make-up (Qada) fasts; a subset of
  /// [fastedDays].
  final Set<DateTime> makeUpDays;

  /// Ramadan days marked as missed, each owing one make-up fast.
  final Set<DateTime> missedRamadanDays;

  /// Days owed per Hijri year that are not marked day by day, e.g. from
  /// Ramadans before the app was used. Never holds zero.
  final Map<int, int> extraOwed;

  FastLog copyWith({
    Set<DateTime>? fastedDays,
    Set<DateTime>? makeUpDays,
    Set<DateTime>? missedRamadanDays,
    Map<int, int>? extraOwed,
  }) {
    return FastLog(
      fastedDays: fastedDays ?? this.fastedDays,
      makeUpDays: makeUpDays ?? this.makeUpDays,
      missedRamadanDays: missedRamadanDays ?? this.missedRamadanDays,
      extraOwed: extraOwed ?? this.extraOwed,
    );
  }

  @override
  List<Object> get props => [
    fastedDays,
    makeUpDays,
    missedRamadanDays,
    extraOwed,
  ];
}
