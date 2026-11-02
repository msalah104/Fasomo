import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// How the user wants to set their location.
enum LocationChoice {
  /// Ask the device for a coarse fix.
  device,

  /// Pick from the bundled city list.
  city,
}

/// A bottom sheet offering the two ways to set a location. It only reports
/// the choice; the caller acts on it.
class LocationChoiceSheet extends StatelessWidget {
  const new({super.key});

  /// Shows the sheet and returns the choice, or `null` when dismissed.
  static Future<LocationChoice?> show(BuildContext context) =>
      showModalBottomSheet<LocationChoice>(
        context: context,
        showDragHandle: true,
        builder: (_) => const LocationChoiceSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    void choose(LocationChoice choice) => Navigator.of(context).pop(choice);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      localization.locationSheetTitle,
                      style: textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localization.locationSheetBody,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: Text(localization.locationUseDevice),
              subtitle: Text(localization.locationUseDeviceDetail),
              onTap: () => choose(LocationChoice.device),
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(localization.locationChooseCity),
              subtitle: Text(localization.locationChooseCityDetail),
              onTap: () => choose(LocationChoice.city),
            ),
          ],
        ),
      ),
    );
  }
}
