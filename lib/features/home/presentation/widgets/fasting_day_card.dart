import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class FastingDayCard extends StatelessWidget {
  const new({
    required this.fastingDay,
    required this.isReminderOn,
    required this.onToggleReminder,
    this.extraAction,
    super.key,
  });

  final FastingDay fastingDay;

  /// Whether a reminder is active for the day's primary type.
  final bool isReminderOn;
  final VoidCallback onToggleReminder;

  /// Shown after the reminder button, e.g. to mark today as fasted.
  final Widget? extraAction;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final type = fastingDay.primaryType;

    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: type.color(colors),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(type.icon, color: type.onColor(colors)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fastingDay.types
                            .map(localization.fastingTypeTitle)
                            .join(' · '),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localization.daysUntil(fastingDay.daysUntil),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              localization.fastingTypeDescription(type),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            // Wraps so the buttons stack instead of overflowing at large text.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReminderButton(
                  isOn: isReminderOn,
                  onPressed: onToggleReminder,
                ),
                ?extraAction,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderButton extends StatelessWidget {
  const new({required this.isOn, required this.onPressed});

  final bool isOn;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final color = isOn ? colorScheme.primary : colorScheme.secondary;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(isOn ? Icons.notifications_active : Icons.notifications_none),
      label: Text(
        isOn ? localization.deactivateReminder : localization.activateReminder,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
      ),
    );
  }
}
