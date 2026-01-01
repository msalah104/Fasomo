import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../domain/entities/reminder.dart';
import '../bloc/reminder_bloc.dart';

class ReminderEditDialog extends StatefulWidget {
  final Reminder reminder;

  const ReminderEditDialog({
    super.key,
    required this.reminder,
  });

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
    _messageController =
        TextEditingController(text: widget.reminder.customMessage ?? '');
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
              widget.reminder.title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Text(
              localization.reminderTime,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            RadioListTile<ReminderTime>(
              title: Text(localization.dayBefore),
              subtitle: const Text('One day before the fasting day'),
              value: ReminderTime.dayBefore,
              groupValue: _selectedTime,
              onChanged: (value) {
                setState(() {
                  _selectedTime = value!;
                });
              },
            ),
            RadioListTile<ReminderTime>(
              title: Text(localization.morningOfDay),
              subtitle: const Text('Morning of the fasting day'),
              value: ReminderTime.morningOfDay,
              groupValue: _selectedTime,
              onChanged: (value) {
                setState(() {
                  _selectedTime = value!;
                });
              },
            ),
            RadioListTile<ReminderTime>(
              title: Text(localization.customTime),
              subtitle: const Text('Set a custom time'),
              value: ReminderTime.custom,
              groupValue: _selectedTime,
              onChanged: (value) {
                setState(() {
                  _selectedTime = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              localization.notificationMessage,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter custom notification message',
                border: const OutlineInputBorder(),
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
            final updatedReminder = widget.reminder.copyWith(
              reminderTime: _selectedTime,
              customMessage: _messageController.text.isEmpty
                  ? null
                  : _messageController.text,
            );

            context
                .read<ReminderBloc>()
                .add(UpdateReminderSettings(updatedReminder));

            Navigator.pop(context);
          },
          child: Text(localization.save),
        ),
      ],
    );
  }
}
