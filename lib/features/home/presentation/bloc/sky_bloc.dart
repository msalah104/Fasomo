import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/usecases/choose_city.dart';
import 'package:fasomo/core/location/usecases/open_location_settings.dart';
import 'package:fasomo/core/location/usecases/use_device_location.dart';
import 'package:fasomo/core/time/minute_ticker.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/usecases/get_sky_scene.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sky_event.dart';
part 'sky_state.dart';

/// Keeps the Home sky current: recomputed every minute while it is in view,
/// at once on resume, and whenever the location changes.
class SkyBloc extends Bloc<SkyEvent, SkyState> {
  new({
    required this.getSkyScene,
    required this.useDeviceLocation,
    required this.chooseCity,
    required this.openLocationSettings,
    required this.ticker,
  }) : super(SkyState(scene: getSkyScene(const NoParams()))) {
    on<SkyStarted>(_onResumed);
    on<SkyResumed>(_onResumed);
    on<SkyTicked>((event, emit) => _redraw(emit));
    on<SkyPaused>(_onPaused);
    // A second tap while a fix is on its way is ignored.
    on<SkyDeviceLocationRequested>(_onDeviceLocation, transformer: droppable());
    on<SkyCityChosen>(_onCityChosen);
    on<SkyLocationSettingsRequested>(_onSettings);
  }

  final GetSkyScene getSkyScene;
  final UseDeviceLocation useDeviceLocation;
  final ChooseCity chooseCity;
  final OpenLocationSettings openLocationSettings;
  final MinuteTicker ticker;

  StreamSubscription<void>? _ticks;

  void _redraw(Emitter<SkyState> emit) =>
      emit(state.copyWith(scene: getSkyScene(const NoParams())));

  void _onResumed(SkyEvent event, Emitter<SkyState> emit) {
    _redraw(emit);
    _ticks ??= ticker.ticks().listen((_) => add(const SkyTicked()));
  }

  Future<void> _onPaused(SkyPaused event, Emitter<SkyState> emit) async {
    final ticks = _ticks;
    _ticks = null;
    await ticks?.cancel();
  }

  Future<void> _onDeviceLocation(
    SkyDeviceLocationRequested event,
    Emitter<SkyState> emit,
  ) async {
    emit(state.copyWith(isLocating: true));
    switch (await useDeviceLocation(const NoParams())) {
      case Ok():
        emit(
          state.copyWith(
            isLocating: false,
            scene: getSkyScene(const NoParams()),
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isLocating: false, locationFailure: failure));
    }
  }

  Future<void> _onCityChosen(
    SkyCityChosen event,
    Emitter<SkyState> emit,
  ) async {
    await chooseCity(event.city);
    _redraw(emit);
  }

  Future<void> _onSettings(
    SkyLocationSettingsRequested event,
    Emitter<SkyState> emit,
  ) async {
    await openLocationSettings(const NoParams());
  }

  @override
  Future<void> close() async {
    await _ticks?.cancel();
    await super.close();
  }
}
