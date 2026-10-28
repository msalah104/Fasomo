import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_current_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  new({required this.getCurrentHijriMonth, required this.getHijriMonth})
    : super(const CalendarState()) {
    on<LoadCalendar>(_onLoadCalendar);
    on<ChangeMonth>((event, emit) => _showMonth(event.month, emit));
    on<NextMonth>(_onNextMonth);
    on<PreviousMonth>(_onPreviousMonth);
  }

  final GetCurrentHijriMonth getCurrentHijriMonth;
  final GetHijriMonth getHijriMonth;

  void _onLoadCalendar(LoadCalendar event, Emitter<CalendarState> emit) {
    emit(state.copyWith(status: CalendarStatus.loading));
    switch (getCurrentHijriMonth(const NoParams())) {
      case Ok(value: final month):
        _showMonth(month, emit);
      case Err(:final failure):
        emit(state.copyWith(status: CalendarStatus.error, failure: failure));
    }
  }

  void _onNextMonth(NextMonth event, Emitter<CalendarState> emit) {
    final month = state.month;
    if (month != null) _showMonth(month.next, emit);
  }

  void _onPreviousMonth(PreviousMonth event, Emitter<CalendarState> emit) {
    final month = state.month;
    if (month != null) _showMonth(month.previous, emit);
  }

  void _showMonth(HijriMonth month, Emitter<CalendarState> emit) {
    switch (getHijriMonth(month)) {
      case Ok(value: final days):
        emit(
          state.copyWith(
            status: CalendarStatus.success,
            days: days,
            month: month,
          ),
        );
      case Err(:final failure):
        // Keep the last good month visible; only the status changes.
        emit(state.copyWith(status: CalendarStatus.error, failure: failure));
    }
  }
}
