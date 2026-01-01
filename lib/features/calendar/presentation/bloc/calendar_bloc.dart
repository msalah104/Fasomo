import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/hijri_utils.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/usecases/get_hijri_month.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetHijriMonth getHijriMonth;

  CalendarBloc({required this.getHijriMonth})
      : super(CalendarState(
          currentMonth: HijriUtils.getCurrentHijriDate().hMonth,
          currentYear: HijriUtils.getCurrentHijriDate().hYear,
        )) {
    on<LoadCalendar>(_onLoadCalendar);
    on<ChangeMonth>(_onChangeMonth);
    on<NextMonth>(_onNextMonth);
    on<PreviousMonth>(_onPreviousMonth);
    on<SelectDay>(_onSelectDay);
  }

  Future<void> _onLoadCalendar(
    LoadCalendar event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading));

    try {
      final days = getHijriMonth(HijriMonthParams(
        month: state.currentMonth,
        year: state.currentYear,
      ));

      emit(state.copyWith(
        status: CalendarStatus.success,
        days: days,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CalendarStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading));

    try {
      final days = getHijriMonth(HijriMonthParams(
        month: event.month,
        year: event.year,
      ));

      emit(state.copyWith(
        status: CalendarStatus.success,
        days: days,
        currentMonth: event.month,
        currentYear: event.year,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CalendarStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onNextMonth(
    NextMonth event,
    Emitter<CalendarState> emit,
  ) async {
    int newMonth = state.currentMonth + 1;
    int newYear = state.currentYear;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }

    add(ChangeMonth(newMonth, newYear));
  }

  Future<void> _onPreviousMonth(
    PreviousMonth event,
    Emitter<CalendarState> emit,
  ) async {
    int newMonth = state.currentMonth - 1;
    int newYear = state.currentYear;

    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    add(ChangeMonth(newMonth, newYear));
  }

  Future<void> _onSelectDay(
    SelectDay event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(selectedDay: event.day));
  }
}
