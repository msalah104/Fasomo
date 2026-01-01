import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../domain/entities/reminder.dart';
import '../bloc/reminder_bloc.dart';
import 'reminder_edit_dialog.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;

  const ReminderCard({
    super.key,
    required this.reminder,
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
                Icon(
                  reminder.isEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: reminder.isEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getReminderTimeText(reminder.reminderTime, localization),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isEnabled,
                  onChanged: (value) {
                    context.read<ReminderBloc>().add(
                          ToggleReminder(reminder.fastingDay),
                        );
                  },
                ),
              ],
            ),
            if (reminder.customMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.message,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reminder.customMessage!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: context.read<ReminderBloc>(),
                        child: ReminderEditDialog(reminder: reminder),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(context, reminder);
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text(localization.cancel),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getReminderTimeText(ReminderTime time, AppLocalizations localization) {
    switch (time) {
      case ReminderTime.dayBefore:
        return localization.dayBefore;
      case ReminderTime.morningOfDay:
        return localization.morningOfDay;
      case ReminderTime.custom:
        return localization.customTime;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Reminder reminder) {
    final localization = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localization.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ReminderBloc>().add(DeleteReminderEvent(reminder.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
