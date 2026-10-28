import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/usecases/get_fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_day_fasted.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_extra_qada_owed.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_make_up_fast.dart';
import 'package:fasomo/features/tracker/domain/usecases/set_ramadan_day_missed.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'tracker_event.dart';
part 'tracker_state.dart';

class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  new({
    required this.getSummary,
    required this.setDayFasted,
    required this.setRamadanDayMissed,
    required this.setMakeUpFast,
    required this.setExtraQadaOwed,
  }) : super(const TrackerState()) {
    // One handler, processed in order, so quick double taps never interleave.
    on<TrackerEvent>(_onEvent, transformer: sequential());
  }

  final GetFastLogSummary getSummary;
  final SetDayFasted setDayFasted;
  final SetRamadanDayMissed setRamadanDayMissed;
  final SetMakeUpFast setMakeUpFast;
  final SetExtraQadaOwed setExtraQadaOwed;

  Future<void> _onEvent(TrackerEvent event, Emitter<TrackerState> emit) async {
    switch (event) {
      case LoadTracker():
        emit(state.copyWith(status: TrackerStatus.loading));
        _load(emit);
      case RefreshTracker():
        _load(emit);
      case ToggleDayFasted(:final date):
        await _change(
          setDayFasted(
            SetDayFastedParams(date: date, fasted: !state.isFasted(date)),
          ),
          emit,
        );
      case ToggleRamadanMissed(:final date):
        await _change(
          setRamadanDayMissed(
            SetRamadanDayMissedParams(
              date: date,
              missed: !state.summary.isMissed(date),
            ),
          ),
          emit,
        );
      case ToggleMakeUp(:final date):
        await _change(
          setMakeUpFast(
            SetMakeUpFastParams(
              date: date,
              makeUp: !state.summary.isMakeUp(date),
            ),
          ),
          emit,
        );
      case SetExtraOwed(:final hijriYear, :final days):
        await _change(
          setExtraQadaOwed(
            SetExtraQadaOwedParams(hijriYear: hijriYear, days: days),
          ),
          emit,
        );
    }
  }

  /// Reloads after a successful change, or reports why it failed.
  Future<void> _change(
    Future<Result<void, Failure>> change,
    Emitter<TrackerState> emit,
  ) async {
    switch (await change) {
      case Ok():
        _load(emit);
      case Err(:final failure):
        emit(state.copyWith(failure: failure));
    }
  }

  void _load(Emitter<TrackerState> emit) {
    switch (getSummary(const NoParams())) {
      case Ok(value: final summary):
        emit(state.copyWith(status: TrackerStatus.success, summary: summary));
      case Err(:final failure):
        emit(state.copyWith(status: TrackerStatus.error, failure: failure));
    }
  }
}
