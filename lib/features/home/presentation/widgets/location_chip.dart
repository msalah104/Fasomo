import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Offers to use the device's location for the sky. While the sky is shown
/// for the fallback it says "Use my location"; once located it shrinks to an
/// icon that refreshes the fix.
class LocationChip extends StatelessWidget {
  const new({
    required this.isApproximate,
    required this.isLocating,
    required this.onPressed,
    required this.color,
    super.key,
  });

  final bool isApproximate;
  final bool isLocating;
  final VoidCallback onPressed;

  /// Ink that reads on the sky behind the chip.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final onPressed = isLocating ? null : this.onPressed;
    final icon = isLocating
        ? SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        : Icon(
            isApproximate ? Icons.location_on_outlined : Icons.my_location,
            color: color,
          );

    if (!isApproximate) {
      return IconButton(
        tooltip: localization.updateMyLocation,
        onPressed: onPressed,
        icon: icon,
      );
    }
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(localization.useMyLocation),
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
