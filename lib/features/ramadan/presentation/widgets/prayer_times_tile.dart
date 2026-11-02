import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/core/presentation/prayer_text.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// "Today's prayer times", collapsed, opening to the six times.
class PrayerTimesTile extends StatelessWidget {
  const new({required this.times, super.key});

  final PrayerTimes times;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final use24HourClock = MediaQuery.alwaysUse24HourFormatOf(context);

    return ExpansionTile(
      leading: const Icon(Icons.schedule_outlined),
      title: Text(localization.ramadanPrayerTimesToday),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
      children: [
        for (final prayer in Prayer.values)
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      localization.prayerName(prayer),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    localization.prayerTime(
                      times[prayer],
                      use24HourClock: use24HourClock,
                    ),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
