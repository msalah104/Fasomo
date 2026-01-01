part of 'calendar_bloc.dart';

enum CalendarStatus { initial, loading, success, error }

class CalendarState extends Equatable {
  final CalendarStatus status;
  final List<CalendarDay> days;
  final int currentMonth;
  final int currentYear;
  final CalendarDay? selectedDay;
  final String? errorMessage;

  const CalendarState({
    this.status = CalendarStatus.initial,
    this.days = const [],
    required this.currentMonth,
    required this.currentYear,
    this.selectedDay,
    this.errorMessage,
  });

  CalendarState copyWith({
    CalendarStatus? status,
    List<CalendarDay>? days,
    int? currentMonth,
    int? currentYear,
    CalendarDay? selectedDay,
    String? errorMessage,
  }) {
    return CalendarState(
      status: status ?? this.status,
      days: days ?? this.days,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
      selectedDay: selectedDay ?? this.selectedDay,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        days,
        currentMonth,
        currentYear,
        selectedDay,
        errorMessage,
      ];
}
