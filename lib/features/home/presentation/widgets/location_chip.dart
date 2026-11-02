import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/theme/sky_palette.dart';
import 'package:fasomo/features/home/presentation/sky_text.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The place the sky is drawn for, on the sky: "📍 Cairo", or
/// "Approximate · Set location" before the user has set one. Tapping it
/// changes the location.
class LocationChip extends StatelessWidget {
  const new({
    required this.location,
    required this.isLocating,
    required this.palette,
    required this.onPressed,
    super.key,
  });

  final GeoPoint location;
  final bool isLocating;
  final SkyPalette palette;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final label = isLocating
        ? localization.locationLocating
        : location.isApproximate
        ? localization.locationApproximate
        : localization.placeName(location);
    final textStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: palette.ink);

    return Semantics(
      button: true,
      hint: localization.locationChipHint,
      child: Material(
        color: palette.chipFill,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLocating ? null : onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 14, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A spinner moves; with reduced motion a still icon says
                  // the same, next to the "Locating…" label.
                  if (isLocating && MediaQuery.disableAnimationsOf(context))
                    Icon(Icons.hourglass_empty, size: 18, color: palette.ink)
                  else if (isLocating)
                    SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.ink,
                      ),
                    )
                  else
                    Icon(Icons.place, size: 18, color: palette.ink),
                  const SizedBox(width: 6),
                  Flexible(child: Text(label, style: textStyle)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
