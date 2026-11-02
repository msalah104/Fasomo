import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/onboarding/domain/entities/fasting_interest.dart';
import 'package:fasomo/features/onboarding/domain/entities/onboarding_step.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastingInterest', () {
    test('covers every fasting type exactly once', () {
      final types = [
        for (final interest in FastingInterest.values) ...interest.types,
      ];
      expect(types.toSet(), FastingType.values.toSet());
      expect(types, hasLength(FastingType.values.length));
    });
  });

  group('OnboardingStep', () {
    test('walks forward and back, stopping at both ends', () {
      expect(OnboardingStep.welcome.previous, OnboardingStep.welcome);
      expect(OnboardingStep.welcome.next, OnboardingStep.fastingTypes);
      expect(OnboardingStep.location.next, OnboardingStep.notifications);
      expect(OnboardingStep.notifications.next, OnboardingStep.notifications);
      expect(OnboardingStep.notifications.previous, OnboardingStep.location);
      expect(OnboardingStep.welcome.isFirst, isTrue);
      expect(OnboardingStep.notifications.isLast, isTrue);
      expect(OnboardingStep.reminderTime.number, 3);
    });
  });

  group('ReminderPlan.fromChoices', () {
    const custom = ReminderTiming(daysBefore: 0, time: WallClockTime(4, 30));

    test('every interest and the evening before are the defaults', () {
      expect(
        ReminderPlan.fromChoices(
          interests: FastingInterest.values.toSet(),
          preset: ReminderTimePreset.eveningBefore,
          customTiming: custom,
        ),
        ReminderPlan.defaults,
      );
    });

    test('special days turn on Arafah, Ashura and Tasua together', () {
      final plan = ReminderPlan.fromChoices(
        interests: const {FastingInterest.specialDays, FastingInterest.ramadan},
        preset: ReminderTimePreset.morningOf,
        customTiming: custom,
      );
      expect(plan.enabledTypes, {
        FastingType.arafah,
        FastingType.ashura,
        FastingType.tasua,
        FastingType.ramadan,
      });
      expect(plan.timing, ReminderTiming.morningOf);
    });

    test('the custom preset uses the custom timing', () {
      final plan = ReminderPlan.fromChoices(
        interests: const {},
        preset: ReminderTimePreset.custom,
        customTiming: custom,
      );
      expect(plan.enabledTypes, isEmpty);
      expect(plan.timing, custom);
    });
  });
}
