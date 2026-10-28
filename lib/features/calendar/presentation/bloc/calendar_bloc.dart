import 'package:equatable/equatable.dart';
import 'package:fasomo/core/utils/hijri_utils.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  new({required this.getHijriMonth})
    : super(
        CalendarState(
          currentMonth: HijriUtils.getCurrentHijriDate().hMonth,
          currentYear: HijriUtils.getCurrentHijriDate().hYear,
        ),
      ) {
    on<LoadCalendar>(_onLoadCalendar);
    on<ChangeMonth>(_onChangeMonth);
    on<NextMonth>(_onNextMonth);
    on<PreviousMonth>(_onPreviousMonth);
    on<SelectDay>(_onSelectDay);
  }
  final GetHijriMonth getHijriMonth;

  Future<void> _onLoadCalendar(
    LoadCalendar event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading));

    try {
      final days = getHijriMonth(
        HijriMonthParams(
          month: state.currentMonth,
          year: state.currentYear,
        ),
      );

      emit(
        state.copyWith(
          status: CalendarStatus.success,
          days: days,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: CalendarStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading));

    try {
      final days = getHijriMonth(
        HijriMonthParams(
          month: event.month,
          year: event.year,
        ),
      );

      emit(
        state.copyWith(
          status: CalendarStatus.success,
          days: days,
          currentMonth: event.month,
          currentYear: event.year,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: CalendarStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onNextMonth(
    NextMonth event,
    Emitter<CalendarState> emit,
  ) async {
    var newMonth = state.currentMonth + 1;
    var newYear = state.currentYear;

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
    var newMonth = state.currentMonth - 1;
    var newYear = state.currentYear;

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
