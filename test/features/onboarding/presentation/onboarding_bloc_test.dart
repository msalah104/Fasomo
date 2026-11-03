import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/onboarding/domain/entities/fasting_interest.dart';
import 'package:fasomo/features/onboarding/domain/entities/onboarding_step.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';
import 'package:fasomo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'onboarding_mocks.dart';

void main() {
  final cairo = CityCatalog.byId('EG:Cairo')!;
  final cairoPoint = GeoPoint.fromCity(cairo);
  const devicePoint = GeoPoint(
    latitude: 51.5,
    longitude: -0.13,
    source: LocationSource.device,
  );
  const ninePm = ReminderTiming(daysBefore: 1, time: WallClockTime(21, 30));

  late OnboardingFakes fakes;

  setUpAll(OnboardingFakes.registerFallbacks);

  setUp(() => fakes = OnboardingFakes());

  test('starts on the welcome step with every reminder on', () {
    final state = fakes.bloc().state;
    expect(state.step, OnboardingStep.welcome);
    expect(state.reminderPlan, ReminderPlan.defaults);
    expect(state.status, OnboardingStatus.inProgress);
  });

  blocTest<OnboardingBloc, OnboardingState>(
    'records that onboarding is under way',
    build: () => fakes.bloc(),
    act: (bloc) => bloc.add(const OnboardingStarted()),
    expect: () => <OnboardingState>[],
    verify: (_) => verify(() => fakes.start(any())).called(1),
  );

  blocTest<OnboardingBloc, OnboardingState>(
    'walks forward and back through the steps',
    build: () => fakes.bloc(),
    act: (bloc) => bloc
      ..add(const OnboardingBackPressed())
      ..add(const OnboardingNextPressed())
      ..add(const OnboardingNextPressed())
      ..add(const OnboardingBackPressed()),
    expect: () => [
      // Back on the first step changes nothing, so emits nothing.
      const OnboardingState(step: OnboardingStep.fastingTypes),
      const OnboardingState(step: OnboardingStep.reminderTime),
      const OnboardingState(step: OnboardingStep.fastingTypes),
    ],
  );

  blocTest<OnboardingBloc, OnboardingState>(
    'toggles fasting interests off and on',
    build: () => fakes.bloc(),
    act: (bloc) => bloc
      ..add(const OnboardingInterestToggled(FastingInterest.ramadan))
      ..add(const OnboardingInterestToggled(FastingInterest.ramadan)),
    expect: () => [
      isA<OnboardingState>().having(
        (state) => state.interests,
        'interests',
        isNot(contains(FastingInterest.ramadan)),
      ),
      const OnboardingState(),
    ],
  );

  blocTest<OnboardingBloc, OnboardingState>(
    'changing the custom time also selects it',
    build: () => fakes.bloc(),
    act: (bloc) => bloc
      ..add(const OnboardingReminderPresetChanged(ReminderTimePreset.morningOf))
      ..add(const OnboardingCustomTimingChanged(ninePm)),
    expect: () => [
      const OnboardingState(reminderPreset: ReminderTimePreset.morningOf),
      const OnboardingState(
        reminderPreset: ReminderTimePreset.custom,
        customTiming: ninePm,
      ),
    ],
  );

  group('location', () {
    blocTest<OnboardingBloc, OnboardingState>(
      'uses the device location when it is given',
      setUp: () => when(
        () => fakes.useDeviceLocation(any()),
      ).thenAnswer((_) async => const Ok(devicePoint)),
      build: () => fakes.bloc(),
      act: (bloc) => bloc.add(const OnboardingDeviceLocationRequested()),
      expect: () => [
        const OnboardingState(
          locationStatus: OnboardingLocationStatus.locating,
        ),
        const OnboardingState(
          locationStatus: OnboardingLocationStatus.set,
          location: devicePoint,
        ),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'reports why the device location could not be used',
      setUp: () => when(() => fakes.useDeviceLocation(any())).thenAnswer(
        (_) async => const Err(LocationPermissionDenied(permanently: false)),
      ),
      build: () => fakes.bloc(),
      act: (bloc) => bloc.add(const OnboardingDeviceLocationRequested()),
      expect: () => [
        const OnboardingState(
          locationStatus: OnboardingLocationStatus.locating,
        ),
        const OnboardingState(
          locationFailure: LocationPermissionDenied(permanently: false),
        ),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'saves a chosen city',
      setUp: () => when(
        () => fakes.chooseCity(cairo),
      ).thenAnswer((_) async => cairoPoint),
      build: () => fakes.bloc(),
      act: (bloc) => bloc.add(OnboardingCityChosen(cairo)),
      expect: () => [
        OnboardingState(
          locationStatus: OnboardingLocationStatus.set,
          location: cairoPoint,
        ),
      ],
      verify: (_) => verify(() => fakes.chooseCity(cairo)).called(1),
    );
  });

  group('finishing', () {
    const chosen = OnboardingState(
      step: OnboardingStep.notifications,
      interests: {FastingInterest.whiteDays},
      reminderPreset: ReminderTimePreset.morningOf,
    );
    const chosenPlan = ReminderPlan(
      enabledTypes: {FastingType.whiteDays},
      timing: ReminderTiming.morningOf,
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'applies the choices, asks for permission, then completes',
      build: () => fakes.bloc(),
      seed: () => chosen,
      act: (bloc) =>
          bloc.add(const OnboardingFinished(allowNotifications: true)),
      expect: () => [
        chosen.copyWith(status: OnboardingStatus.saving),
        chosen.copyWith(status: OnboardingStatus.completed),
      ],
      verify: (_) => verifyInOrder([
        () => fakes.handoff.applyReminderPlan(chosenPlan),
        () => fakes.handoff.requestNotificationPermission(),
        () => fakes.complete(any()),
      ]),
    );

    blocTest<OnboardingBloc, OnboardingState>(
      '"Not now" completes without asking for permission',
      build: () => fakes.bloc(),
      seed: () => chosen,
      act: (bloc) =>
          bloc.add(const OnboardingFinished(allowNotifications: false)),
      expect: () => [
        chosen.copyWith(status: OnboardingStatus.saving),
        chosen.copyWith(status: OnboardingStatus.completed),
      ],
      verify: (_) {
        verify(() => fakes.handoff.applyReminderPlan(chosenPlan)).called(1);
        verifyNever(() => fakes.handoff.requestNotificationPermission());
        verify(() => fakes.complete(any())).called(1);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'stays on the step when the choices cannot be saved',
      setUp: () =>
          when(() => fakes.handoff.applyReminderPlan(any())).thenAnswer(
            (_) async => const Err(StorageWriteFailed('reminders')),
          ),
      build: () => fakes.bloc(),
      seed: () => chosen,
      act: (bloc) =>
          bloc.add(const OnboardingFinished(allowNotifications: true)),
      expect: () => [
        chosen.copyWith(status: OnboardingStatus.saving),
        chosen.copyWith(failure: const StorageWriteFailed('reminders')),
      ],
      verify: (_) {
        verifyNever(() => fakes.handoff.requestNotificationPermission());
        verifyNever(() => fakes.complete(any()));
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'ignores steps and a second finish while saving',
      build: () => fakes.bloc(),
      seed: () => chosen.copyWith(status: OnboardingStatus.saving),
      act: (bloc) => bloc
        ..add(const OnboardingBackPressed())
        ..add(const OnboardingSkipped())
        ..add(const OnboardingFinished(allowNotifications: true)),
      expect: () => <OnboardingState>[],
    );
  });

  group('skipping', () {
    blocTest<OnboardingBloc, OnboardingState>(
      'keeps the defaults without saving reminders',
      build: () => fakes.bloc(),
      act: (bloc) => bloc.add(const OnboardingSkipped()),
      expect: () => [
        const OnboardingState(status: OnboardingStatus.saving),
        const OnboardingState(status: OnboardingStatus.skipped),
      ],
      verify: (_) {
        verifyNever(() => fakes.handoff.applyReminderPlan(any()));
        verifyNever(() => fakes.handoff.requestNotificationPermission());
        verify(() => fakes.complete(any())).called(1);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'keeps the choices made so far, even if saving them fails',
      setUp: () =>
          when(() => fakes.handoff.applyReminderPlan(any())).thenAnswer(
            (_) async => const Err(StorageWriteFailed('reminders')),
          ),
      build: () => fakes.bloc(),
      seed: () => const OnboardingState(
        step: OnboardingStep.reminderTime,
        interests: {FastingInterest.ramadan},
      ),
      act: (bloc) => bloc.add(const OnboardingSkipped()),
      expect: () => [
        const OnboardingState(
          step: OnboardingStep.reminderTime,
          interests: {FastingInterest.ramadan},
          status: OnboardingStatus.saving,
        ),
        const OnboardingState(
          step: OnboardingStep.reminderTime,
          interests: {FastingInterest.ramadan},
          status: OnboardingStatus.skipped,
        ),
      ],
      verify: (_) {
        verify(
          () => fakes.handoff.applyReminderPlan(
            const ReminderPlan(
              enabledTypes: {FastingType.ramadan},
              timing: ReminderTiming.dayBefore,
            ),
          ),
        ).called(1);
        verify(() => fakes.complete(any())).called(1);
      },
    );
  });
}
