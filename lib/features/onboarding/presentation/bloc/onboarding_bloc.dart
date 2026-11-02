import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/usecases/choose_city.dart';
import 'package:fasomo/core/location/usecases/use_device_location.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/onboarding/domain/entities/fasting_interest.dart';
import 'package:fasomo/features/onboarding/domain/entities/onboarding_step.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';
import 'package:fasomo/features/onboarding/domain/onboarding_handoff.dart';
import 'package:fasomo/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:fasomo/features/onboarding/domain/usecases/start_onboarding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// The first-run flow: which step is showing, the answers so far, and
/// saving them at the end. The app language is not here: it changes live
/// through the settings feature, which the app wires into the first step.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  new({
    required this.startOnboarding,
    required this.completeOnboarding,
    required this.useDeviceLocation,
    required this.chooseCity,
    required this.handoff,
  }) : super(const OnboardingState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingNextPressed>(
      (_, emit) => _whileInProgress(emit, step: state.step.next),
    );
    on<OnboardingBackPressed>(
      (_, emit) => _whileInProgress(emit, step: state.step.previous),
    );
    on<OnboardingInterestToggled>(_onInterestToggled);
    on<OnboardingReminderPresetChanged>(
      (event, emit) => _whileInProgress(emit, preset: event.preset),
    );
    on<OnboardingCustomTimingChanged>(
      (event, emit) => _whileInProgress(
        emit,
        preset: ReminderTimePreset.custom,
        customTiming: event.timing,
      ),
    );
    on<OnboardingDeviceLocationRequested>(
      _onDeviceLocation,
      transformer: droppable(),
    );
    on<OnboardingCityChosen>(_onCityChosen);
    // One save at a time; a second tap while saving is dropped.
    on<OnboardingFinished>(_onFinished, transformer: droppable());
    on<OnboardingSkipped>(_onSkipped, transformer: droppable());
  }

  final StartOnboarding startOnboarding;
  final CompleteOnboarding completeOnboarding;
  final UseDeviceLocation useDeviceLocation;
  final ChooseCity chooseCity;
  final OnboardingHandoff handoff;

  bool get _inProgress => state.status == OnboardingStatus.inProgress;

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    // A failed write is logged by the repository; the flow still runs.
    await startOnboarding(const NoParams());
  }

  void _whileInProgress(
    Emitter<OnboardingState> emit, {
    OnboardingStep? step,
    ReminderTimePreset? preset,
    ReminderTiming? customTiming,
  }) {
    if (!_inProgress) return;
    final next = state.copyWith(
      step: step,
      reminderPreset: preset,
      customTiming: customTiming,
    );
    // E.g. Back on the first step: nothing to show.
    if (next != state) emit(next);
  }

  void _onInterestToggled(
    OnboardingInterestToggled event,
    Emitter<OnboardingState> emit,
  ) {
    if (!_inProgress) return;
    final interests = {...state.interests};
    if (!interests.remove(event.interest)) interests.add(event.interest);
    emit(state.copyWith(interests: interests));
  }

  Future<void> _onDeviceLocation(
    OnboardingDeviceLocationRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    final before = state.locationStatus;
    emit(state.copyWith(locationStatus: OnboardingLocationStatus.locating));
    switch (await useDeviceLocation(const NoParams())) {
      case Ok(value: final point):
        emit(
          state.copyWith(
            locationStatus: OnboardingLocationStatus.set,
            location: point,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(locationStatus: before, locationFailure: failure));
    }
  }

  Future<void> _onCityChosen(
    OnboardingCityChosen event,
    Emitter<OnboardingState> emit,
  ) async {
    final point = await chooseCity(event.city);
    emit(
      state.copyWith(
        locationStatus: OnboardingLocationStatus.set,
        location: point,
      ),
    );
  }

  Future<void> _onFinished(
    OnboardingFinished event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!_inProgress) return;
    emit(state.copyWith(status: OnboardingStatus.saving));
    if (await handoff.applyReminderPlan(state.reminderPlan) case Err(
      :final failure,
    )) {
      // Stay on the step so the user can try again, or skip.
      emit(
        state.copyWith(status: OnboardingStatus.inProgress, failure: failure),
      );
      return;
    }
    if (event.allowNotifications) {
      await handoff.requestNotificationPermission();
    }
    // A failed write is logged; the worst case is seeing onboarding again.
    await completeOnboarding(const NoParams());
    emit(state.copyWith(status: OnboardingStatus.completed));
  }

  Future<void> _onSkipped(
    OnboardingSkipped event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!_inProgress) return;
    emit(state.copyWith(status: OnboardingStatus.saving));
    final plan = state.reminderPlan;
    // Untouched answers are the defaults already; only changes are saved.
    // Skipping never fails: a save error is logged and the defaults stand.
    if (plan != ReminderPlan.defaults) await handoff.applyReminderPlan(plan);
    await completeOnboarding(const NoParams());
    emit(state.copyWith(status: OnboardingStatus.skipped));
  }
}
