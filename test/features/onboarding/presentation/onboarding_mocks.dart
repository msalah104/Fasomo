import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/usecases/choose_city.dart';
import 'package:fasomo/core/location/usecases/use_device_location.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';
import 'package:fasomo/features/onboarding/domain/onboarding_handoff.dart';
import 'package:fasomo/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:fasomo/features/onboarding/domain/usecases/start_onboarding.dart';
import 'package:fasomo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockStartOnboarding extends Mock implements StartOnboarding;

class MockCompleteOnboarding extends Mock implements CompleteOnboarding;

class MockUseDeviceLocation extends Mock implements UseDeviceLocation;

class MockChooseCity extends Mock implements ChooseCity;

class MockOnboardingHandoff extends Mock implements OnboardingHandoff;

/// The onboarding bloc's collaborators, stubbed to succeed.
class OnboardingFakes {
  new() {
    when(() => start(any())).thenAnswer((_) async => const Ok(null));
    when(() => complete(any())).thenAnswer((_) async => const Ok(null));
    when(
      () => useDeviceLocation(any()),
    ).thenAnswer((_) async => const Err(LocationUnavailable()));
    when(
      () => handoff.applyReminderPlan(any()),
    ).thenAnswer((_) async => const Ok(null));
    when(handoff.requestNotificationPermission).thenAnswer((_) async => true);
  }

  /// Fallbacks for `any()`; call once from `setUpAll`.
  static void registerFallbacks() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(ReminderPlan.defaults);
    registerFallbackValue(CityCatalog.byId('EG:Cairo'));
  }

  final start = MockStartOnboarding();
  final complete = MockCompleteOnboarding();
  final useDeviceLocation = MockUseDeviceLocation();
  final chooseCity = MockChooseCity();
  final handoff = MockOnboardingHandoff();

  OnboardingBloc bloc() => OnboardingBloc(
    startOnboarding: start,
    completeOnboarding: complete,
    useDeviceLocation: useDeviceLocation,
    chooseCity: chooseCity,
    handoff: handoff,
  );
}
