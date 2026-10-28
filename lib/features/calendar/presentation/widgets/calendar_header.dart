import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // chevron_left/right mirror automatically in RTL.
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: localization.previousMonth,
              onPressed: onPreviousMonth,
            ),
            Column(
              children: [
                Text(
                  localization.hijriMonthName(month.month),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localization.hijriYear('${month.year}'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: localization.nextMonth,
              onPressed: onNextMonth,
            ),
          ],
        ),
      ),
    );
  }
}
