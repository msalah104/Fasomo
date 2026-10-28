import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/usecases/get_current_hijri_date.dart';
import 'package:fasomo/features/home/domain/usecases/get_upcoming_fasting_days.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  new({
    required this.getCurrentHijriDate,
    required this.getUpcomingFastingDays,
  }) : super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<DaySelected>(_onDaySelected);
  }

  final GetCurrentHijriDate getCurrentHijriDate;
  final GetUpcomingFastingDays getUpcomingFastingDays;

  void _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.loading));
    _load(emit);
  }

  void _onRefreshHomeData(RefreshHomeData event, Emitter<HomeState> emit) =>
      _load(emit);

  void _onDaySelected(DaySelected event, Emitter<HomeState> emit) {
    switch (getUpcomingFastingDays(UpcomingFrom(event.date))) {
      case Ok(value: final days):
        emit(
          state.copyWith(selectedDate: event.date, upcomingFastingDays: days),
        );
      case Err(:final failure):
        emit(state.copyWith(status: HomeStatus.error, failure: failure));
    }
  }

  /// Loads today and resets the selection to it, since "today" may have
  /// moved on since the last load.
  void _load(Emitter<HomeState> emit) {
    final today = getCurrentHijriDate(const NoParams());
    final upcoming = getUpcomingFastingDays(const UpcomingFrom());

    switch ((today, upcoming)) {
      case (Ok(value: final date), Ok(value: final days)):
        emit(
          state.copyWith(
            status: HomeStatus.success,
            currentDate: date,
            upcomingFastingDays: days,
            selectedDate: date.gregorianDate,
          ),
        );
      case (Err(:final failure), _) || (_, Err(:final failure)):
        emit(state.copyWith(status: HomeStatus.error, failure: failure));
    }
  }
}
