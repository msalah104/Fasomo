import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/prayer_text.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// "Ramadan in 12 days", with the expected first day and, the day before,
/// when the first suhoor ends.
class RamadanCountdownCard extends StatelessWidget {
  const new({required this.countdown, super.key});

  final RamadanCountdown countdown;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final firstSuhoor = countdown.firstSuhoorEnds;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                FastingType.ramadan.icon,
                color: FastingType.ramadan.color(colors),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      localization.ramadanCountdownTitle(countdown.daysUntil),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    localization.ramadanStartsOn(
                      DateFormat.MMMMEEEEd(
                        localization.localeName,
                      ).format(countdown.startDate),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (firstSuhoor != null)
                    Text(
                      localization.ramadanFirstSuhoor(
                        localization.prayerTime(
                          firstSuhoor,
                          use24HourClock: MediaQuery.alwaysUse24HourFormatOf(
                            context,
                          ),
                        ),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
