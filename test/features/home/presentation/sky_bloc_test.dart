import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/usecases/choose_city.dart';
import 'package:fasomo/core/location/usecases/open_location_settings.dart';
import 'package:fasomo/core/location/usecases/use_device_location.dart';
import 'package:fasomo/core/time/minute_ticker.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/sky_scene_builder.dart';
import 'package:fasomo/features/home/domain/usecases/get_sky_scene.dart';
import 'package:fasomo/features/home/presentation/bloc/sky_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSkyScene extends Mock implements GetSkyScene;

class MockUseDeviceLocation extends Mock implements UseDeviceLocation;

class MockChooseCity extends Mock implements ChooseCity;

class MockOpenLocationSettings extends Mock implements OpenLocationSettings;

/// A [MinuteTicker] the test ticks by hand; it counts live listeners.
class FakeMinuteTicker implements MinuteTicker {
  final _controller = StreamController<void>.broadcast();

  int get listeners => _listeners;
  int _listeners = 0;

  void tick() => _controller.add(null);

  Future<void> dispose() => _controller.close();

  @override
  Stream<void> ticks() {
    late StreamController<void> own;
    StreamSubscription<void>? source;
    own = StreamController<void>(
      onListen: () {
        _listeners++;
        source = _controller.stream.listen(own.add);
      },
      onCancel: () async {
        _listeners--;
        await source?.cancel();
        await own.close();
      },
    );
    return own.stream;
  }
}

void main() {
  final cairo = CityCatalog.byId('EG:Cairo')!;
  final first = buildSkyScene(
    DateTime.utc(2026, 10, 28, 18, 40),
    GeoPoint.makkah,
  );
  final later = buildSkyScene(
    DateTime.utc(2026, 10, 28, 18, 41),
    GeoPoint.makkah,
  );
  final inCairo = buildSkyScene(
    DateTime.utc(2026, 10, 28, 18, 41),
    GeoPoint.fromCity(cairo),
  );

  late MockGetSkyScene getSkyScene;
  late MockUseDeviceLocation useDeviceLocation;
  late MockChooseCity chooseCity;
  late MockOpenLocationSettings openLocationSettings;
  late FakeMinuteTicker ticker;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(cairo);
  });

  setUp(() {
    getSkyScene = MockGetSkyScene();
    useDeviceLocation = MockUseDeviceLocation();
    chooseCity = MockChooseCity();
    openLocationSettings = MockOpenLocationSettings();
    ticker = FakeMinuteTicker();
    final scenes = [first, later];
    when(() => getSkyScene(any())).thenAnswer(
      (_) => scenes.length > 1 ? scenes.removeAt(0) : scenes.first,
    );
  });

  tearDown(() => ticker.dispose());

  SkyBloc build() => SkyBloc(
    getSkyScene: getSkyScene,
    useDeviceLocation: useDeviceLocation,
    chooseCity: chooseCity,
    openLocationSettings: openLocationSettings,
    ticker: ticker,
  );

  test('starts with the sky already computed', () {
    expect(build().state, SkyState(scene: first));
  });

  blocTest<SkyBloc, SkyState>(
    'redraws on start and on every minute while started',
    build: build,
    act: (bloc) async {
      bloc.add(const SkyStarted());
      await Future<void>.delayed(Duration.zero);
      expect(ticker.listeners, 1);
      ticker.tick();
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [SkyState(scene: later)],
    // Constructor, start, tick.
    verify: (_) => verify(() => getSkyScene(any())).called(3),
  );

  blocTest<SkyBloc, SkyState>(
    'stops ticking while paused and redraws at once on resume',
    build: build,
    act: (bloc) async {
      bloc.add(const SkyStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SkyPaused());
      await Future<void>.delayed(Duration.zero);
      expect(ticker.listeners, 0);
      ticker.tick();
      bloc.add(const SkyResumed());
      await Future<void>.delayed(Duration.zero);
      expect(ticker.listeners, 1);
    },
    // Constructor, start, resume: the tick while paused was not heard.
    verify: (_) => verify(() => getSkyScene(any())).called(3),
  );

  test('stops listening to the ticker when closed', () async {
    final bloc = build()..add(const SkyStarted());
    await Future<void>.delayed(Duration.zero);
    expect(ticker.listeners, 1);
    await bloc.close();
    expect(ticker.listeners, 0);
  });

  group('device location', () {
    blocTest<SkyBloc, SkyState>(
      'shows progress, then the sky over the new place',
      setUp: () {
        when(() => useDeviceLocation(any())).thenAnswer(
          (_) async => Ok(inCairo.location),
        );
        final scenes = [first, inCairo];
        when(() => getSkyScene(any())).thenAnswer(
          (_) => scenes.length > 1 ? scenes.removeAt(0) : scenes.first,
        );
      },
      build: build,
      act: (bloc) => bloc.add(const SkyDeviceLocationRequested()),
      expect: () => [
        SkyState(scene: first, isLocating: true),
        SkyState(scene: inCairo),
      ],
    );

    for (final failure in const <LocationFailure>[
      LocationPermissionDenied(permanently: false),
      LocationPermissionDenied(permanently: true),
      LocationServiceDisabled(),
      LocationUnavailable(),
    ]) {
      blocTest<SkyBloc, SkyState>(
        '${failure.code} keeps the sky and reports the failure',
        setUp: () => when(
          () => useDeviceLocation(any()),
        ).thenAnswer((_) async => Err(failure)),
        build: build,
        act: (bloc) => bloc.add(const SkyDeviceLocationRequested()),
        expect: () => [
          SkyState(scene: first, isLocating: true),
          SkyState(scene: first, locationFailure: failure),
        ],
      );
    }

    blocTest<SkyBloc, SkyState>(
      'a failure is cleared by the next change',
      setUp: () => when(
        () => useDeviceLocation(any()),
      ).thenAnswer((_) async => const Err(LocationUnavailable())),
      build: build,
      act: (bloc) async {
        bloc.add(const SkyDeviceLocationRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SkyTicked());
      },
      skip: 2,
      expect: () => [SkyState(scene: later)],
    );
  });

  blocTest<SkyBloc, SkyState>(
    'a chosen city is saved, then drawn',
    setUp: () {
      when(
        () => chooseCity(any()),
      ).thenAnswer((invocation) async {
        final city = invocation.positionalArguments.single as City;
        return GeoPoint.fromCity(city);
      });
      final scenes = [first, inCairo];
      when(() => getSkyScene(any())).thenAnswer(
        (_) => scenes.length > 1 ? scenes.removeAt(0) : scenes.first,
      );
    },
    build: build,
    act: (bloc) => bloc.add(SkyCityChosen(cairo)),
    expect: () => [SkyState(scene: inCairo)],
    verify: (_) => verify(() => chooseCity(cairo)).called(1),
  );

  blocTest<SkyBloc, SkyState>(
    'opens the system settings on request',
    setUp: () => when(
      () => openLocationSettings(any()),
    ).thenAnswer((_) async => true),
    build: build,
    act: (bloc) => bloc.add(const SkyLocationSettingsRequested()),
    expect: () => <SkyState>[],
    verify: (_) => verify(() => openLocationSettings(any())).called(1),
  );

  test('scenes for the same moment and place are equal', () {
    final again = buildSkyScene(
      DateTime.utc(2026, 10, 28, 18, 40),
      GeoPoint.makkah,
    );
    expect(again, first);
    expect(again, isA<SkyScene>());
  });
}
