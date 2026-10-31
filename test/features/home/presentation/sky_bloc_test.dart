import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/time/minute_ticker.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/usecases/get_sky_scene.dart';
import 'package:fasomo/features/home/domain/usecases/open_location_settings.dart';
import 'package:fasomo/features/home/domain/usecases/refresh_saved_location.dart';
import 'package:fasomo/features/home/domain/usecases/use_device_location.dart';
import 'package:fasomo/features/home/presentation/bloc/sky_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSkyScene extends Mock implements GetSkyScene;

class MockUseDeviceLocation extends Mock implements UseDeviceLocation;

class MockRefreshSavedLocation extends Mock implements RefreshSavedLocation;

class MockOpenLocationSettings extends Mock implements OpenLocationSettings;

class FakeTicker implements MinuteTicker {
  final controller = StreamController<void>.broadcast();

  @override
  Stream<void> get ticks => controller.stream;
}

void main() {
  late MockGetSkyScene getSkyScene;
  late FakeTicker ticker;
  late MockUseDeviceLocation useDeviceLocation;
  late MockRefreshSavedLocation refreshSaved;
  late MockOpenLocationSettings openSettings;
  var minute = 0;

  SkyScene sceneAt(int minute) => SkyScene(
    now: DateTime(2026, 10, 31, 12, minute),
    location: GeoPoint.makkah,
    sun: const CelestialBodyState(altitudeDegrees: 50, azimuthDegrees: 0),
    moon: const CelestialBodyState(altitudeDegrees: -10, azimuthDegrees: 0),
    moonPhase: const MoonPhase(fraction: 0.6, phase: 0.3),
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const LocationUnavailable());
  });

  setUp(() {
    minute = 0;
    getSkyScene = MockGetSkyScene();
    ticker = FakeTicker();
    when(() => getSkyScene(any())).thenAnswer((_) => sceneAt(minute));
    useDeviceLocation = MockUseDeviceLocation();
    refreshSaved = MockRefreshSavedLocation();
    openSettings = MockOpenLocationSettings();
    when(() => refreshSaved(any())).thenAnswer((_) async => null);
    when(() => openSettings(any())).thenAnswer((_) async {});
  });

  SkyBloc build() => SkyBloc(
    getSkyScene: getSkyScene,
    ticker: ticker,
    useDeviceLocation: useDeviceLocation,
    refreshSavedLocation: refreshSaved,
    openLocationSettings: openSettings,
  );

  test('starts without a scene', () {
    expect(build().state, const SkyState());
  });

  blocTest<SkyBloc, SkyState>(
    'computes the scene on start',
    build: build,
    act: (bloc) => bloc.add(const SkyStarted()),
    expect: () => [SkyState(scene: sceneAt(0))],
  );

  blocTest<SkyBloc, SkyState>(
    'recomputes on every tick',
    build: build,
    act: (bloc) async {
      bloc.add(const SkyStarted());
      await Future<void>.delayed(Duration.zero);
      minute = 1;
      ticker.controller.add(null);
      await Future<void>.delayed(Duration.zero);
      minute = 2;
      ticker.controller.add(null);
    },
    expect: () => [
      SkyState(scene: sceneAt(0)),
      SkyState(scene: sceneAt(1)),
      SkyState(scene: sceneAt(2)),
    ],
  );

  blocTest<SkyBloc, SkyState>(
    'stops listening to the ticker when closed',
    build: build,
    act: (bloc) => bloc.add(const SkyStarted()),
    verify: (_) => expect(ticker.controller.hasListener, isFalse),
  );

  const cairo = GeoPoint(
    latitude: 30.04,
    longitude: 31.24,
    source: LocationSource.device,
  );

  blocTest<SkyBloc, SkyState>(
    'a silent refresh on start recomputes the sky when the location changed',
    setUp: () {
      when(() => refreshSaved(any())).thenAnswer((_) async {
        minute = 1;
        return cairo;
      });
    },
    build: build,
    act: (bloc) => bloc.add(const SkyStarted()),
    expect: () => [SkyState(scene: sceneAt(0)), SkyState(scene: sceneAt(1))],
  );

  blocTest<SkyBloc, SkyState>(
    'using the device location shows progress, then the new sky',
    setUp: () {
      when(() => useDeviceLocation(any())).thenAnswer((_) async {
        minute = 5;
        return const Ok(cairo);
      });
    },
    build: build,
    seed: () => SkyState(scene: sceneAt(0)),
    act: (bloc) => bloc.add(const SkyLocationRequested()),
    expect: () => [
      SkyState(scene: sceneAt(0), isLocating: true),
      SkyState(scene: sceneAt(5)),
    ],
  );

  blocTest<SkyBloc, SkyState>(
    'a refused location keeps the sky and reports why',
    setUp: () {
      when(() => useDeviceLocation(any())).thenAnswer(
        (_) async => const Err(LocationPermissionDenied(permanently: true)),
      );
    },
    build: build,
    seed: () => SkyState(scene: sceneAt(0)),
    act: (bloc) => bloc.add(const SkyLocationRequested()),
    expect: () => [
      SkyState(scene: sceneAt(0), isLocating: true),
      SkyState(
        scene: sceneAt(0),
        failure: const LocationPermissionDenied(permanently: true),
      ),
    ],
  );

  blocTest<SkyBloc, SkyState>(
    'opens settings for a failure',
    build: build,
    act: (bloc) =>
        bloc.add(const SkySettingsRequested(LocationServiceDisabled())),
    verify: (_) =>
        verify(() => openSettings(const LocationServiceDisabled())).called(1),
  );
}
