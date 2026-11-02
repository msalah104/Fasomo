import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/onboarding/domain/entities/onboarding_step.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// One dot per step, with "Step 2 of 5" under them. The current step's dot
/// is longer as well as filled, so position does not rely on colour.
class OnboardingProgress extends StatelessWidget {
  const new({required this.step, super.key});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final label = localization.onboardingStepOf(
      step.number,
      OnboardingStep.values.length,
    );
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              for (final each in OnboardingStep.values)
                _Dot(
                  isCurrent: each == step,
                  isReached: each.index <= step.index,
                  colors: colors,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const new({
    required this.isCurrent,
    required this.isReached,
    required this.colors,
  });

  final bool isCurrent;
  final bool isReached;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCurrent ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isReached ? colors.accent : null,
        border: Border.all(
          color: isReached ? colors.accent : colors.onSurfaceMuted,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
