import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class DayDetailSheet extends StatelessWidget {
  const new({required this.day, this.action, super.key});

  final CalendarDay day;

  /// Shown above the close button, e.g. to mark the day as fasted.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.formatHijri(day.hijriDate),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              localization.formatGregorian(day.gregorianDate),
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
            if (action case final action?) ...[
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: action),
            ],
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
    final colors = AppColors.of(context);

    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      color: type.fill(colors),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: type.color(colors),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(type.icon, color: type.onColor(colors)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localization.fastingTypeTitle(type),
                    style: theme.textTheme.titleMedium?.copyWith(
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
