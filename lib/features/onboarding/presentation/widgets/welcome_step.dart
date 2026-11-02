import 'package:fasomo/core/presentation/logo_mark.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/core/theme/app_shapes.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Step 1: what the app does, and the language it speaks.
class WelcomeStep extends StatelessWidget {
  const new({required this.languagePicker, super.key});

  /// The language choices. The app supplies them from the settings feature,
  /// so a change applies to this screen at once.
  final Widget languagePicker;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    return OnboardingStepLayout(
      illustration: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.brand,
          borderRadius: AppShapes.of(context).cardRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: LogoMark(
            color: colors.onBrand,
            dotColor: colors.fastWeekly,
            semanticLabel: localization.appName,
            size: 44,
          ),
        ),
      ),
      title: localization.onboardingWelcomeTitle,
      body: localization.onboardingWelcomeBody,
      children: [
        Semantics(
          header: true,
          child: Text(
            localization.onboardingLanguageTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        languagePicker,
      ],
    );
  }
}
