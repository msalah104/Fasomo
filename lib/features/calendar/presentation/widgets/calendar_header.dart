import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The month name and year between the previous and next month buttons.
class CalendarHeader extends StatelessWidget {
  const new({
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
    super.key,
  });

  final HijriMonth month;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return CalendarPeriodHeader(
      title: localization.hijriMonthName(month.month),
      subtitle: localization.hijriYear('${month.year}'),
      previousTooltip: localization.previousMonth,
      nextTooltip: localization.nextMonth,
      onPrevious: onPreviousMonth,
      onNext: onNextMonth,
    );
  }
}

/// A period title between previous and next buttons, shared by the month and
/// year views.
class CalendarPeriodHeader extends StatelessWidget {
  const new({
    required this.title,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            // Directional icons: chevron_left/right mirror in RTL, so
            // "previous" always points to the start edge.
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: previousTooltip,
              onPressed: onPrevious,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle case final subtitle?) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: nextTooltip,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
