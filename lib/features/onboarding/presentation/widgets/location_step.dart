import 'dart:async';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/presentation/location/city_picker_page.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fasomo/features/onboarding/presentation/onboarding_text.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/onboarding_step_layout.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Step 4 (optional): the device's approximate location, or a city from the
/// bundled list. "Later" in the bottom bar moves on without one.
class LocationStep extends StatelessWidget {
  const new({super.key});

  Future<void> _chooseCity(BuildContext context) async {
    final bloc = context.read<OnboardingBloc>();
    final city = await CityPickerPage.show(
      context,
      selected: bloc.state.location?.city,
    );
    if (city != null) bloc.add(OnboardingCityChosen(city));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final state = context.watch<OnboardingBloc>().state;
    final isLocating =
        state.locationStatus == OnboardingLocationStatus.locating;
    return OnboardingStepLayout(
      illustration: const OnboardingStepIcon(Icons.travel_explore),
      title: localization.onboardingLocationTitle,
      body: localization.onboardingLocationBody,
      children: [
        _LocationOption(
          icon: Icons.my_location,
          title: localization.locationUseDevice,
          detail: localization.locationUseDeviceDetail,
          onPressed: isLocating
              ? null
              : () => context.read<OnboardingBloc>().add(
                  const OnboardingDeviceLocationRequested(),
                ),
        ),
        const SizedBox(height: 8),
        _LocationOption(
          icon: Icons.location_city,
          title: localization.locationChooseCity,
          detail: localization.locationChooseCityDetail,
          onPressed: isLocating ? null : () => unawaited(_chooseCity(context)),
        ),
        const SizedBox(height: 16),
        _LocationStatusLine(
          isLocating: isLocating,
          location: state.locationStatus == OnboardingLocationStatus.set
              ? state.location
              : null,
          failure: state.locationFailure,
        ),
      ],
    );
  }
}

class _LocationOption extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        enabled: onPressed != null,
        leading: Icon(icon, color: colors.accent),
        title: Text(title),
        subtitle: Text(detail),
        onTap: onPressed,
      ),
    );
  }
}

/// What happened with the location: finding it, where it was set, or why
/// the device could not give one. Read out as it changes.
class _LocationStatusLine extends StatelessWidget {
  const new({
    required this.isLocating,
    required this.location,
    required this.failure,
  });

  final bool isLocating;
  final GeoPoint? location;
  final LocationFailure? failure;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final line = switch ((
      isLocating,
      failure,
      location,
    )) {
      (true, _, _) => (
        reduceMotion
            ? Icon(Icons.hourglass_empty, size: 20, color: colors.onSurface)
            : SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.accent,
                ),
              ),
        localization.locationLocating,
        colors.onSurface,
      ),
      (_, final failure?, _) => (
        Icon(Icons.error_outline, size: 20, color: colors.danger),
        localization.locationFailureMessage(failure),
        colors.danger,
      ),
      (_, _, final location?) => (
        Icon(Icons.check_circle, size: 20, color: colors.accent),
        localization.locationSetLabel(location),
        colors.onSurface,
      ),
      _ => null,
    };
    if (line == null) return const SizedBox.shrink();
    final (icon, text, color) = line;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          ExcludeSemantics(child: icon),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
