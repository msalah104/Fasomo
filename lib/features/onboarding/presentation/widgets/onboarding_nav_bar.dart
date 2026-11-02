import 'package:fasomo/features/onboarding/domain/entities/onboarding_step.dart';
import 'package:fasomo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Back on the start side, the step's forward actions on the end side. The
/// actions stack when large text leaves no room for them side by side.
class OnboardingNavBar extends StatelessWidget {
  const new({required this.state, super.key});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<OnboardingBloc>();
    final enabled = state.status == OnboardingStatus.inProgress;
    void send(OnboardingEvent event) => bloc.add(event);

    final actions = switch (state.step) {
      OnboardingStep.notifications => [
        TextButton(
          onPressed: enabled
              ? () => send(const OnboardingFinished(allowNotifications: false))
              : null,
          child: Text(localization.onboardingNotNow),
        ),
        FilledButton(
          onPressed: enabled
              ? () => send(const OnboardingFinished(allowNotifications: true))
              : null,
          child: Text(localization.onboardingAllowNotifications),
        ),
      ],
      OnboardingStep.location => [
        FilledButton(
          onPressed: enabled ? () => send(const OnboardingNextPressed()) : null,
          child: Text(
            state.locationStatus == OnboardingLocationStatus.set
                ? localization.onboardingNext
                : localization.onboardingLater,
          ),
        ),
      ],
      OnboardingStep.welcome ||
      OnboardingStep.fastingTypes ||
      OnboardingStep.reminderTime => [
        FilledButton(
          onPressed: enabled ? () => send(const OnboardingNextPressed()) : null,
          child: Text(localization.onboardingNext),
        ),
      ],
    };

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          if (!state.step.isFirst)
            TextButton(
              onPressed: enabled
                  ? () => send(const OnboardingBackPressed())
                  : null,
              child: Text(localization.onboardingBack),
            ),
          Expanded(
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: 8,
              overflowSpacing: 8,
              children: actions,
            ),
          ),
        ],
      ),
    );
  }
}
