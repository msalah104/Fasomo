part of 'calendar_bloc.dart';

enum CalendarStatus { initial, loading, success, error }

/// Which view of the calendar is shown.
enum CalendarView { month, year }

class CalendarState extends Equatable {
  const new({
    this.status = CalendarStatus.initial,
    this.view = CalendarView.month,
    this.days = const [],
    this.previousDays = const [],
    this.nextDays = const [],
    this.month,
    this.currentMonth,
    this.year,
    this.yearMonths = const [],
    this.showGregorianDays = false,
    this.failure,
    this.preferenceFailure,
  });

  final CalendarStatus status;
  final CalendarView view;
  final List<CalendarDay> days;

  /// The days of the months either side of [month], so a swipe slides real
  /// days into view. Empty when that month is outside the supported range.
  final List<CalendarDay> previousDays;
  final List<CalendarDay> nextDays;

  /// The month shown; `null` until the first load resolves today.
  final HijriMonth? month;

  /// The month containing today, as of the last time it was resolved.
  final HijriMonth? currentMonth;

  /// The Hijri year of the year view; `null` until it is first opened.
  final int? year;

  /// The twelve months of [year], Muharram first.
  final List<CalendarMonth> yearMonths;

  /// Whether each day cell also shows its Gregorian day number.
  final bool showGregorianDays;
  final CalendarFailure? failure;

  /// Set only on the state emitted right after a preference failed to save.
  final StorageFailure? preferenceFailure;

  /// Whether the month view shows the month containing today.
  bool get isShowingCurrentMonth =>
      view == CalendarView.month && month != null && month == currentMonth;

  CalendarState copyWith({
    CalendarStatus? status,
    CalendarView? view,
    List<CalendarDay>? days,
    List<CalendarDay>? previousDays,
    List<CalendarDay>? nextDays,
    HijriMonth? month,
    HijriMonth? currentMonth,
    int? year,
    List<CalendarMonth>? yearMonths,
    bool? showGregorianDays,
    CalendarFailure? failure,
    StorageFailure? preferenceFailure,
  }) {
    final nextStatus = status ?? this.status;
    return CalendarState(
      status: nextStatus,
      view: view ?? this.view,
      days: days ?? this.days,
      previousDays: previousDays ?? this.previousDays,
      nextDays: nextDays ?? this.nextDays,
      month: month ?? this.month,
      currentMonth: currentMonth ?? this.currentMonth,
      year: year ?? this.year,
      yearMonths: yearMonths ?? this.yearMonths,
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
    view,
    days,
    previousDays,
    nextDays,
    month,
    currentMonth,
    year,
    yearMonths,
    showGregorianDays,
    failure,
    preferenceFailure,
  ];
}
