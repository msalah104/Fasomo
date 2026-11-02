part of 'calendar_bloc.dart';

enum CalendarStatus { initial, loading, success, error }

class CalendarState extends Equatable {
  const new({
    this.status = CalendarStatus.initial,
    this.days = const [],
    this.previousDays = const [],
    this.nextDays = const [],
    this.month,
    this.currentMonth,
    this.showGregorianDays = false,
    this.failure,
    this.preferenceFailure,
  });

  final CalendarStatus status;
  final List<CalendarDay> days;

  /// The days of the months either side of [month], so a swipe slides real
  /// days into view. Empty when that month is outside the supported range.
  final List<CalendarDay> previousDays;
  final List<CalendarDay> nextDays;

  /// The month shown; `null` until the first load resolves today.
  final HijriMonth? month;

  /// The month containing today, as of the last time it was resolved.
  final HijriMonth? currentMonth;

  /// Whether each day cell also shows its Gregorian day number.
  final bool showGregorianDays;
  final CalendarFailure? failure;

  /// Set only on the state emitted right after a preference failed to save.
  final StorageFailure? preferenceFailure;

  /// Whether the month containing today is the one shown.
  bool get isShowingCurrentMonth => month != null && month == currentMonth;

  CalendarState copyWith({
    CalendarStatus? status,
    List<CalendarDay>? days,
    List<CalendarDay>? previousDays,
    List<CalendarDay>? nextDays,
    HijriMonth? month,
    HijriMonth? currentMonth,
    bool? showGregorianDays,
    CalendarFailure? failure,
    StorageFailure? preferenceFailure,
  }) {
    final nextStatus = status ?? this.status;
    return CalendarState(
      status: nextStatus,
      days: days ?? this.days,
      previousDays: previousDays ?? this.previousDays,
      nextDays: nextDays ?? this.nextDays,
      month: month ?? this.month,
      currentMonth: currentMonth ?? this.currentMonth,
      showGregorianDays: showGregorianDays ?? this.showGregorianDays,
      failure: nextStatus == CalendarStatus.error
          ? failure ?? this.failure
          : null,
      preferenceFailure: preferenceFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    days,
    previousDays,
    nextDays,
    month,
    currentMonth,
    showGregorianDays,
    failure,
    preferenceFailure,
  ];
}
