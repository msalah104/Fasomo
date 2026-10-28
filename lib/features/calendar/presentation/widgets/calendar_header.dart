import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/constants/app_constants.dart';
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
    final languageCode = Localizations.localeOf(context).languageCode;
    final monthNames = languageCode == 'ar'
        ? AppConstants.arabicMonthNames
        : AppConstants.englishMonthNames;
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
              onPressed: onPreviousMonth,
            ),
            Column(
              children: [
                Text(
                  monthNames[month.month - 1],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${month.year} ${languageCode == 'ar' ? 'هـ' : 'AH'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextMonth,
            ),
          ],
        ),
      ),
    );
  }
}
