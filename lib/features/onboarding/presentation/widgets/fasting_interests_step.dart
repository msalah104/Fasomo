import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/onboarding/domain/entities/fasting_interest.dart';
import 'package:fasomo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fasomo/features/onboarding/presentation/onboarding_text.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Step 2: which kinds of fasting day to be reminded of.
class FastingInterestsStep extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final interests = context.select<OnboardingBloc, Set<FastingInterest>>(
      (bloc) => bloc.state.interests,
    );
    return OnboardingStepLayout(
      illustration: const OnboardingStepIcon(Icons.event_available_outlined),
      title: localization.onboardingFastsTitle,
      body: localization.onboardingFastsBody,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final interest in FastingInterest.values)
              FastingInterestChip(
                interest: interest,
                isSelected: interests.contains(interest),
                onPressed: () => context.read<OnboardingBloc>().add(
                  OnboardingInterestToggled(interest),
                ),
              ),
          ],
        ),
        if (interests.isEmpty) ...[
          const SizedBox(height: 16),
          Text(
            localization.onboardingFastsNone,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

/// A multi-select chip in the fasting type's colour and icon. Selection is
/// shown by the fill, a thicker outline and a check mark, never by colour
/// alone.
class FastingInterestChip extends StatelessWidget {
  const new({
    required this.interest,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  final FastingInterest interest;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final type = interest.representative;
    final label = AppLocalizations.of(context).fastingInterestLabel(interest);
    // A type whose colour is also its fill (the White Days) is outlined in
    // its "on" colour, so the outline still shows.
    final outline = type.fill(colors) == type.color(colors)
        ? type.onColor(colors)
        : type.color(colors);
    return Semantics(
      checked: isSelected,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Material(
        color: isSelected ? type.fill(colors) : colors.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? outline : colors.onSurfaceMuted,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 14, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: type.color(colors),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        type.icon,
                        size: 18,
                        color: type.onColor(colors),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    size: 20,
                    color: colors.onSurface,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
