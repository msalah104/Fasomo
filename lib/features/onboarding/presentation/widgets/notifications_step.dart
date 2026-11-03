import 'package:fasomo/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Step 5: why notifications matter. The bottom bar asks for permission,
/// or moves on without asking.
class NotificationsStep extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return OnboardingStepLayout(
      illustration: const OnboardingStepIcon(
        Icons.notifications_active_outlined,
      ),
      title: localization.onboardingNotificationsTitle,
      body: localization.onboardingNotificationsBody,
    );
  }
}
