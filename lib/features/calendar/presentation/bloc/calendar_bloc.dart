import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_current_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_month.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_hijri_year.dart';
import 'package:fasomo/features/calendar/domain/usecases/get_show_gregorian_days.dart';
import 'package:fasomo/features/calendar/domain/usecases/save_show_gregorian_days.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  /// Reads the saved display preferences synchronously, so the first frame
  /// already shows them.
  new({
    required this.getCurrentHijriMonth,
    required this.getHijriMonth,
    required this.getHijriYear,
    required this.getShowGregorianDays,
    required this.saveShowGregorianDays,
  }) : super(
         CalendarState(
           // An unreadable preference was logged by the repository; the
           // default is a safe fallback.
           showGregorianDays: getShowGregorianDays(
             const NoParams(),
           ).fold((show) => show, (_) => false),
         ),
       ) {
    on<LoadCalendar>(_onLoadCalendar);
    on<GoToToday>((event, emit) => _showToday(emit));
    on<ChangeMonth>((event, emit) => _showMonth(event.month, emit));
    on<NextMonth>(_onNextMonth);
    on<PreviousMonth>(_onPreviousMonth);
    on<ShowYearView>(_onShowYearView);
    on<ShowMonthView>(_onShowMonthView);
    on<NextYear>(_onNextYear);
    on<PreviousYear>(_onPreviousYear);
    // Sequential, so two quick taps flip the setting twice.
    on<ToggleGregorianDays>(
      _onToggleGregorianDays,
      transformer: sequential(),
    );
  }

  final GetCurrentHijriMonth getCurrentHijriMonth;
  final GetHijriMonth getHijriMonth;
  final GetHijriYear getHijriYear;
  final GetShowGregorianDays getShowGregorianDays;
  final SaveShowGregorianDays saveShowGregorianDays;

  void _onLoadCalendar(LoadCalendar event, Emitter<CalendarState> emit) {
    emit(state.copyWith(status: CalendarStatus.loading));
    _showToday(emit);
  }

  void _showToday(Emitter<CalendarState> emit) {
    switch (getCurrentHijriMonth(const NoParams())) {
      case Ok(value: final month):
        _showMonth(month, emit, currentMonth: month);
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

  void _showMonth(
    HijriMonth month,
    Emitter<CalendarState> emit, {
    HijriMonth? currentMonth,
  }) {
    switch (getHijriMonth(month)) {
      case Ok(value: final days):
        emit(
          state.copyWith(
            status: CalendarStatus.success,
            view: CalendarView.month,
            days: days,
            previousDays: _daysOrEmpty(month.previous),
            nextDays: _daysOrEmpty(month.next),
            month: month,
            currentMonth: currentMonth,
          ),
        );
      case Err(:final failure):
        // Keep the last good month visible; only the status changes.
        emit(state.copyWith(status: CalendarStatus.error, failure: failure));
    }
  }

  void _onShowYearView(ShowYearView event, Emitter<CalendarState> emit) {
    final month = state.month;
    if (month != null) _showYear(month.year, emit);
  }

  void _onShowMonthView(ShowMonthView event, Emitter<CalendarState> emit) {
    // The month was already loaded; a year view failure no longer applies.
    if (state.month != null) {
      emit(
        state.copyWith(
          status: CalendarStatus.success,
          view: CalendarView.month,
        ),
      );
    }
  }

  void _onNextYear(NextYear event, Emitter<CalendarState> emit) {
    final year = state.year;
    if (year != null) _showYear(year + 1, emit);
  }

  void _onPreviousYear(PreviousYear event, Emitter<CalendarState> emit) {
    final year = state.year;
    if (year != null) _showYear(year - 1, emit);
  }

  void _showYear(int year, Emitter<CalendarState> emit) {
    switch (getHijriYear(year)) {
      case Ok(value: final months):
        emit(
          state.copyWith(
            status: CalendarStatus.success,
            view: CalendarView.year,
            year: year,
            yearMonths: months,
          ),
        );
      case Err(:final failure):
        // Keep the last good year visible; only the status changes.
        emit(state.copyWith(status: CalendarStatus.error, failure: failure));
    }
  }

  /// A neighbouring month outside the supported range has no days to preview;
  /// swiping to it reports the failure through [_showMonth].
  List<CalendarDay> _daysOrEmpty(HijriMonth month) =>
      getHijriMonth(month).fold((days) => days, (_) => const []);

  Future<void> _onToggleGregorianDays(
    ToggleGregorianDays event,
    Emitter<CalendarState> emit,
  ) async {
    final show = !state.showGregorianDays;
    // Persist first, then publish: the screen never shows an unsaved choice.
    switch (await saveShowGregorianDays(show)) {
      case Ok():
        emit(state.copyWith(showGregorianDays: show));
      case Err(:final failure):
        emit(state.copyWith(preferenceFailure: failure));
    }
  }
}
