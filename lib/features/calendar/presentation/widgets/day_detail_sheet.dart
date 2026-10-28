import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/utils/app_localizations.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:flutter/material.dart';

class DayDetailSheet extends StatelessWidget {
  const new({required this.day, super.key});

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormatter.hijri(day.hijriDate, languageCode),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              DateFormatter.gregorian(day.gregorianDate, languageCode),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            if (day.isFastingDay) ...[
              Text(
                localization.fastingDay,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              for (final type in day.fastingTypes) _FastingTypeCard(type: type),
            ] else
              _NoFastingCard(message: localization.noSpecificFastingDay),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localization.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FastingTypeCard extends StatelessWidget {
  const new({required this.type});

  final FastingType type;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      color: type.color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(type.icon, color: type.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localization.fastingTypeTitle(type),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: type.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              localization.fastingTypeDescription(type),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoFastingCard extends StatelessWidget {
  const new({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: theme.textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }
}
