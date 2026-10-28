import 'dart:async';

import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/theme/app_shapes.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/reminders/presentation/widgets/reminder_edit_dialog.dart';
import 'package:fasomo/features/reminders/presentation/widgets/reminder_timing_text.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderCard extends StatelessWidget {
  const new({
    required this.reminder,
    super.key,
  });
  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
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
                        localization.fastingTypeTitle(reminder.fastingType),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminderTimingText(context, reminder),
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
                      ToggleReminder(reminder.fastingType),
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
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: AppShapes.of(context).smallRadius,
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
                    unawaited(
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: context.read<ReminderBloc>(),
                          child: ReminderEditDialog(reminder: reminder),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(localization.edit),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(context, reminder);
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text(localization.delete),
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

  void _showDeleteConfirmation(BuildContext context, Reminder reminder) {
    final localization = AppLocalizations.of(context);

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(localization.deleteReminderTitle),
          content: Text(localization.deleteReminderConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(localization.cancel),
            ),
            TextButton(
              onPressed: () {
                context.read<ReminderBloc>().add(
                  DeleteReminderEvent(reminder.fastingType),
                );
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(localization.delete),
            ),
          ],
        ),
      ),
    );
  }
}
