import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../reminders/presentation/bloc/reminder_bloc.dart';
import '../../domain/entities/fasting_day.dart';

class FastingDayCard extends StatelessWidget {
  final FastingDay fastingDay;
  final Locale locale;

  const FastingDayCard({
    super.key,
    required this.fastingDay,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: _getColorForType(fastingDay.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForType(fastingDay.type),
                    color: _getColorForType(fastingDay.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fastingDay.title,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDaysUntilText(fastingDay.daysUntil, localization),
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
              fastingDay.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            BlocBuilder<ReminderBloc, ReminderState>(
              builder: (context, state) {
                final hasReminder = state.reminders.any(
                  (r) =>
                      r.fastingDay == fastingDay.type.toString() &&
                      r.isEnabled,
                );

                return OutlinedButton.icon(
                  onPressed: () {
                    if (hasReminder) {
                      context.read<ReminderBloc>().add(
                            ToggleReminder(fastingDay.type.toString()),
                          );
                    } else {
                      context.read<ReminderBloc>().add(
                            AddFastingDayReminder(
                              fastingDay.type.toString(),
                              fastingDay.title,
                            ),
                          );
                    }
                  },
                  icon: Icon(
                    hasReminder
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                  ),
                  label: Text(
                    hasReminder
                        ? localization.deactivateReminder
                        : localization.activateReminder,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasReminder
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    side: BorderSide(
                      color: hasReminder
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysUntilText(int days, AppLocalizations localization) {
    if (days == 0) {
      return localization.today;
    } else if (days == 1) {
      return localization.tomorrow;
    } else {
      return '$days ${localization.daysLeft}';
    }
  }

  Color _getColorForType(FastingType type) {
    switch (type) {
      case FastingType.ramadan:
        return Colors.purple;
      case FastingType.arafah:
      case FastingType.ashura:
      case FastingType.tasua:
        return Colors.blue;
      case FastingType.whiteDays:
        return Colors.green;
      case FastingType.mondayThursday:
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  IconData _getIconForType(FastingType type) {
    switch (type) {
      case FastingType.ramadan:
        return Icons.mosque;
      case FastingType.arafah:
        return Icons.terrain;
      case FastingType.ashura:
      case FastingType.tasua:
        return Icons.favorite;
      case FastingType.whiteDays:
        return Icons.brightness_3;
      case FastingType.mondayThursday:
        return Icons.calendar_view_week;
      default:
        return Icons.star;
    }
  }
}
