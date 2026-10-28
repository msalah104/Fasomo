import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/utils/app_localizations.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderEditDialog extends StatefulWidget {
  const new({
    required this.reminder,
    super.key,
  });
  final Reminder reminder;

  @override
  State<ReminderEditDialog> createState() => _ReminderEditDialogState();
}

class _ReminderEditDialogState extends State<ReminderEditDialog> {
  late ReminderTime _selectedTime;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.reminder.reminderTime;
    _messageController = TextEditingController(
      text: widget.reminder.customMessage ?? '',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Edit Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.fastingTypeTitle(widget.reminder.fastingType),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Text(
              localization.reminderTime,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            RadioGroup<ReminderTime>(
              groupValue: _selectedTime,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedTime = value);
              },
              child: Column(
                children: [
                  RadioListTile<ReminderTime>(
                    title: Text(localization.dayBefore),
                    subtitle: const Text('One day before the fasting day'),
                    value: ReminderTime.dayBefore,
                  ),
                  RadioListTile<ReminderTime>(
                    title: Text(localization.morningOfDay),
                    subtitle: const Text('Morning of the fasting day'),
                    value: ReminderTime.morningOfDay,
                  ),
                  RadioListTile<ReminderTime>(
                    title: Text(localization.customTime),
                    subtitle: const Text('Set a custom time'),
                    value: ReminderTime.custom,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localization.notificationMessage,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter custom notification message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localization.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final message = _messageController.text.trim();
            final updatedReminder = widget.reminder
                .copyWith(reminderTime: _selectedTime)
                .withCustomMessage(message.isEmpty ? null : message);

            context.read<ReminderBloc>().add(
              UpdateReminderSettings(updatedReminder),
            );

            Navigator.pop(context);
          },
          child: Text(localization.save),
        ),
      ],
    );
  }
}
