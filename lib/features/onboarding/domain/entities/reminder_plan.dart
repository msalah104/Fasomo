import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/onboarding/domain/entities/fasting_interest.dart';

/// The default reminder time offered on the reminder-time step.
enum ReminderTimePreset {
  /// The evening before, at 8 PM ([ReminderTiming.dayBefore]).
  eveningBefore,

  /// The morning of the fast, at 7 AM ([ReminderTiming.morningOf]).
  morningOf,

  /// A day and time the user picks.
  custom,
}

/// What onboarding sets up for reminders: which fasting types are on, and
/// when every one of them fires.
final class ReminderPlan extends Equatable {
  const new({required this.enabledTypes, required this.timing});

  /// Builds the plan from the step answers.
  factory fromChoices({
    required Set<FastingInterest> interests,
    required ReminderTimePreset preset,
    required ReminderTiming customTiming,
  }) => ReminderPlan(
    enabledTypes: {for (final interest in interests) ...interest.types},
    timing: switch (preset) {
      ReminderTimePreset.eveningBefore => ReminderTiming.dayBefore,
      ReminderTimePreset.morningOf => ReminderTiming.morningOf,
      ReminderTimePreset.custom => customTiming,
    },
  );

  /// What the app does without onboarding: every reminder on, the evening
  /// before.
  static final ReminderPlan defaults = ReminderPlan(
    enabledTypes: FastingType.values.toSet(),
    timing: ReminderTiming.dayBefore,
  );

  /// The types whose reminders are on; every other type's is off.
  final Set<FastingType> enabledTypes;

  /// When each enabled reminder fires.
  final ReminderTiming timing;

  @override
  List<Object> get props => [enabledTypes, timing];
}
