import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/usecases/get_saved_location.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/core/prayer/usecases/get_prayer_settings.dart';
import 'package:fasomo/core/prayer/usecases/save_prayer_settings.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'prayer_settings_event.dart';
part 'prayer_settings_state.dart';

/// The prayer-time settings. Each change applies at once and is then saved;
/// a failed save only means it is not remembered.
class PrayerSettingsBloc
    extends Bloc<PrayerSettingsEvent, PrayerSettingsState> {
  /// Starts from the saved settings, read synchronously.
  new({
    required GetPrayerSettings getPrayerSettings,
    required this.savePrayerSettings,
    required this.getSavedLocation,
  }) : super(
         PrayerSettingsState(
           settings: switch (getPrayerSettings(const NoParams())) {
             Ok(:final value) => value,
             Err() => PrayerSettings.defaults,
           },
           location: getSavedLocation(const NoParams()),
         ),
       ) {
    // Processed in order, so saves never overtake each other.
    on<PrayerSettingsEvent>(_onEvent, transformer: sequential());
  }

  final SavePrayerSettings savePrayerSettings;
  final GetSavedLocation getSavedLocation;

  Future<void> _onEvent(
    PrayerSettingsEvent event,
    Emitter<PrayerSettingsState> emit,
  ) async {
    final settings = state.settings;
    switch (event) {
      case PrayerSettingsRefreshed():
        emit(state.copyWith(location: getSavedLocation(const NoParams())));
      case PrayerMethodChanged(:final method):
        await _save(settings.withMethod(method), emit);
      case AsrMethodChanged(:final asrMethod):
        await _save(settings.copyWith(asrMethod: asrMethod), emit);
      case HighLatitudeRuleChanged(:final rule):
        await _save(settings.copyWith(highLatitudeRule: rule), emit);
      case PrayerAdjustmentChanged(:final prayer, :final minutes):
        await _save(
          settings.copyWith(
            adjustments: settings.adjustments.withMinutes(prayer, minutes),
          ),
          emit,
        );
      case PrayerAdjustmentsReset():
        await _save(
          settings.copyWith(adjustments: PrayerAdjustments.none),
          emit,
        );
    }
  }

  Future<void> _save(
    PrayerSettings settings,
    Emitter<PrayerSettingsState> emit,
  ) async {
    if (settings == state.settings) return;
    emit(PrayerSettingsState(settings: settings, location: state.location));
    if (await savePrayerSettings(settings) case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
    }
  }
}
