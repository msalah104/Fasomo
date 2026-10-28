part of 'calendar_bloc.dart';

enum CalendarStatus { initial, loading, success, error }

class CalendarState extends Equatable {
  const new({
    this.status = CalendarStatus.initial,
    this.days = const [],
    this.month,
    this.failure,
  });

  final CalendarStatus status;
  final List<CalendarDay> days;

  /// The month shown; `null` until the first load resolves today.
  final HijriMonth? month;
  final CalendarFailure? failure;

  CalendarState copyWith({
    CalendarStatus? status,
    List<CalendarDay>? days,
    HijriMonth? month,
    CalendarFailure? failure,
  }) {
    return CalendarState(
      status: status ?? this.status,
      days: days ?? this.days,
      month: month ?? this.month,
      failure: status == CalendarStatus.error ? failure ?? this.failure : null,
    );
  }

  @override
  List<Object?> get props => [status, days, month, failure];
}
