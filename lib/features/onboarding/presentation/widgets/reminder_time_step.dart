import 'dart:async';

import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';
import 'package:fasomo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fasomo/features/onboarding/presentation/onboarding_text.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Step 3: when every chosen reminder fires.
class ReminderTimeStep extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final (preset, custom) = context
        .select<OnboardingBloc, (ReminderTimePreset, ReminderTiming)>(
          (bloc) => (bloc.state.reminderPreset, bloc.state.customTiming),
        );
    void choose(ReminderTimePreset? value) {
      if (value != null) {
        context.read<OnboardingBloc>().add(
          OnboardingReminderPresetChanged(value),
        );
      }
    }

    return OnboardingStepLayout(
      illustration: const OnboardingStepIcon(Icons.schedule),
      title: localization.onboardingTimeTitle,
      body: localization.onboardingTimeBody,
      children: [
        RadioGroup<ReminderTimePreset>(
          groupValue: preset,
          onChanged: choose,
          child: Column(
            children: [
              RadioListTile<ReminderTimePreset>(
                contentPadding: EdgeInsetsDirectional.zero,
                title: Text(localization.onboardingEveningBefore),
                subtitle: Text(
                  localization.atTime(
                    wallClockLabel(context, ReminderTiming.dayBefore.time),
                  ),
                ),
                value: ReminderTimePreset.eveningBefore,
              ),
              RadioListTile<ReminderTimePreset>(
                contentPadding: EdgeInsetsDirectional.zero,
                title: Text(localization.onboardingMorningOf),
                subtitle: Text(
                  localization.atTime(
                    wallClockLabel(context, ReminderTiming.morningOf.time),
                  ),
                ),
                value: ReminderTimePreset.morningOf,
              ),
              RadioListTile<ReminderTimePreset>(
                contentPadding: EdgeInsetsDirectional.zero,
                title: Text(localization.customTime),
                subtitle: Text(
                  localization.reminderTimingLabel(context, custom),
                ),
                value: ReminderTimePreset.custom,
              ),
            ],
          ),
        ),
        if (preset == ReminderTimePreset.custom)
          _CustomTimingEditor(timing: custom),
      ],
    );
  }
}

/// The day and time of the custom reminder time.
class _CustomTimingEditor extends StatelessWidget {
  const new({required this.timing});

  final ReminderTiming timing;

  void _change(BuildContext context, ReminderTiming timing) =>
      context.read<OnboardingBloc>().add(OnboardingCustomTimingChanged(timing));

  Future<void> _pickTime(BuildContext context) async {
    final bloc = context.read<OnboardingBloc>();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: timing.time.hour,
        minute: timing.time.minute,
      ),
    );
    if (picked == null) return;
    bloc.add(
      OnboardingCustomTimingChanged(
        ReminderTiming(
          daysBefore: timing.daysBefore,
          time: WallClockTime(picked.hour, picked.minute),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 1, label: Text(localization.dayBefore)),
              ButtonSegment(value: 0, label: Text(localization.sameDay)),
            ],
            selected: {timing.daysBefore},
            onSelectionChanged: (selection) => _change(
              context,
              ReminderTiming(daysBefore: selection.first, time: timing.time),
            ),
          ),
          Semantics(
            hint: localization.onboardingPickTime,
            child: OutlinedButton.icon(
              onPressed: () => unawaited(_pickTime(context)),
              icon: const Icon(Icons.schedule),
              label: Text(wallClockLabel(context, timing.time)),
            ),
          ),
        ],
      ),
    );
  }
}
