import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/utils/app_localizations.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:flutter/material.dart';

class CurrentDateCard extends StatelessWidget {
  const new({required this.dateInfo, super.key});

  final HijriDateInfo dateInfo;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.currentHijriDate,
              style: theme.textTheme.titleMedium?.copyWith(
                color: onPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateFormatter.hijri(dateInfo.hijriDate, languageCode),
              style: theme.textTheme.displaySmall?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: onPrimary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.gregorian(dateInfo.gregorianDate, languageCode),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
