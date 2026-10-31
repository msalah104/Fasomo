import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/core/time/minute_ticker.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/usecases/get_sky_scene.dart';
import 'package:fasomo/features/home/domain/usecases/open_location_settings.dart';
import 'package:fasomo/features/home/domain/usecases/refresh_saved_location.dart';
import 'package:fasomo/features/home/domain/usecases/use_device_location.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sky_event.dart';
part 'sky_state.dart';

/// Keeps the sky scene current: computed on start, then once a minute and
/// whenever the app returns to the foreground, and recomputed when the
/// location changes.
class SkyBloc extends Bloc<SkyEvent, SkyState> {
  new({
    required this.getSkyScene,
    required this.ticker,
    required this.useDeviceLocation,
    required this.refreshSavedLocation,
    required this.openLocationSettings,
  }) : super(const SkyState()) {
    on<SkyStarted>(_onStarted);
    on<SkyRefreshed>((event, emit) => _compute(emit));
    // A second tap while locating is ignored.
    on<SkyLocationRequested>(_onLocationRequested, transformer: droppable());
    on<SkySettingsRequested>(
      (event, emit) => openLocationSettings(event.failure),
    );
  }

  final GetSkyScene getSkyScene;
  final MinuteTicker ticker;
  final UseDeviceLocation useDeviceLocation;
  final RefreshSavedLocation refreshSavedLocation;
  final OpenLocationSettings openLocationSettings;

  StreamSubscription<void>? _ticks;

  Future<void> _onStarted(SkyStarted event, Emitter<SkyState> emit) async {
    _compute(emit);
    _ticks ??= ticker.ticks.listen((_) => add(const SkyRefreshed()));
    // Silent: never prompts, at most once a day.
    if (await refreshSavedLocation(const NoParams()) != null) _compute(emit);
  }

  Future<void> _onLocationRequested(
    SkyLocationRequested event,
    Emitter<SkyState> emit,
  ) async {
    AppLog.info('location', '"Use my location" tapped');
    emit(SkyState(scene: state.scene, isLocating: true));
    switch (await useDeviceLocation(const NoParams())) {
      case Ok():
        AppLog.info('location', 'sky redrawn for the new location');
        _compute(emit);
      case Err(:final failure):
        AppLog.info('location', 'request failed: ${failure.code}');
        emit(SkyState(scene: state.scene, failure: failure));
    }
  }

  void _compute(Emitter<SkyState> emit) =>
      emit(SkyState(scene: getSkyScene(const NoParams())));

  @override
  Future<void> close() async {
    await _ticks?.cancel();
    return await super.close();
  }
}
