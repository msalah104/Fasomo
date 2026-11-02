import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/usecases/get_hijri_offset.dart';
import 'package:fasomo/features/settings/domain/usecases/get_today_hijri_date.dart';
import 'package:fasomo/features/settings/domain/usecases/save_hijri_offset.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'hijri_adjustment_event.dart';
part 'hijri_adjustment_state.dart';

/// The Hijri date adjustment and a preview of today with it applied.
///
/// The state always mirrors the offset the Hijri converter reads, so when
/// [HijriAdjustmentState.offset] changes every Hijri date in the app has
/// moved and screens can reload.
class HijriAdjustmentBloc
    extends Bloc<HijriAdjustmentEvent, HijriAdjustmentState> {
  /// Starts from the saved offset, read synchronously like the converter.
  new({
    required this.getHijriOffset,
    required this.saveHijriOffset,
    required this.getTodayHijriDate,
  }) : super(
         HijriAdjustmentState(
           offset: _offsetFrom(getHijriOffset),
           today: getTodayHijriDate(const NoParams()),
         ),
       ) {
    // One change at a time, so rapid taps save and apply in order.
    on<HijriOffsetChanged>(_onOffsetChanged, transformer: sequential());
    on<HijriPreviewRefreshed>(_onPreviewRefreshed);
  }

  final GetHijriOffset getHijriOffset;
  final SaveHijriOffset saveHijriOffset;
  final GetTodayHijriDate getTodayHijriDate;

  /// An unreadable offset counts as none, as it does for the converter.
  static HijriOffset _offsetFrom(GetHijriOffset getHijriOffset) =>
      switch (getHijriOffset(const NoParams())) {
        Ok(:final value) => value,
        Err() => HijriOffset.none,
      };

  Future<void> _onOffsetChanged(
    HijriOffsetChanged event,
    Emitter<HijriAdjustmentState> emit,
  ) async {
    if (event.offset == state.offset) return;
    final failure = switch (await saveHijriOffset(event.offset)) {
      Ok() => null,
      Err(:final failure) => failure,
    };
    // Read back what the converter now uses rather than assuming the save
    // took, so the setting never disagrees with the dates on screen.
    emit(
      HijriAdjustmentState(
        offset: _offsetFrom(getHijriOffset),
        today: getTodayHijriDate(const NoParams()),
        failure: failure,
      ),
    );
  }

  void _onPreviewRefreshed(
    HijriPreviewRefreshed event,
    Emitter<HijriAdjustmentState> emit,
  ) => emit(
    HijriAdjustmentState(
      offset: state.offset,
      today: getTodayHijriDate(const NoParams()),
    ),
  );
}
