import 'dart:async';

import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/utils/app_localizations.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/reminders/presentation/widgets/reminder_timing_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderEditDialog extends StatefulWidget {
  const new({required this.reminder, super.key});

  final Reminder reminder;

  @override
  State<ReminderEditDialog> createState() => _ReminderEditDialogState();
}

class _ReminderEditDialogState extends State<ReminderEditDialog> {
  late ReminderTime _selectedTime = widget.reminder.reminderTime;
  late ReminderTiming _customTiming = widget.reminder.customTiming;
  late final TextEditingController _messageController = TextEditingController(
    text: widget.reminder.customMessage ?? '',
  );

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _customTiming.time.hour,
        minute: _customTiming.time.minute,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customTiming = ReminderTiming(
        daysBefore: _customTiming.daysBefore,
        time: WallClockTime(picked.hour, picked.minute),
      );
    });
  }

  void _save() {
    final message = _messageController.text.trim();
    final updated = widget.reminder
        .copyWith(reminderTime: _selectedTime, customTiming: _customTiming)
        .withCustomMessage(message.isEmpty ? null : message);
    context.read<ReminderBloc>().add(UpdateReminderSettings(updated));
    Navigator.pop(context);
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
            Text(localization.reminderTime, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            RadioGroup<ReminderTime>(
              groupValue: _selectedTime,
              onChanged: (value) {
                if (value != null) setState(() => _selectedTime = value);
              },
              child: Column(
                children: [
                  RadioListTile<ReminderTime>(
                    title: Text(localization.dayBefore),
                    subtitle: Text(
                      localization.atTime(
                        formatWallClock(context, ReminderTiming.dayBefore.time),
                      ),
                    ),
                    value: ReminderTime.dayBefore,
                  ),
                  RadioListTile<ReminderTime>(
                    title: Text(localization.morningOfDay),
                    subtitle: Text(
                      localization.atTime(
                        formatWallClock(context, ReminderTiming.morningOf.time),
                      ),
                    ),
                    value: ReminderTime.morningOfDay,
                  ),
                  RadioListTile<ReminderTime>(
                    title: Text(localization.customTime),
                    value: ReminderTime.custom,
                  ),
                ],
              ),
            ),
            if (_selectedTime == ReminderTime.custom)
              _CustomTimingEditor(
                timing: _customTiming,
                onDaysBeforeChanged: (days) => setState(() {
                  _customTiming = ReminderTiming(
                    daysBefore: days,
                    time: _customTiming.time,
                  );
                }),
                onPickTime: () => unawaited(_pickTime()),
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
        ElevatedButton(onPressed: _save, child: Text(localization.save)),
      ],
    );
  }
}

class _CustomTimingEditor extends StatelessWidget {
  const new({
    required this.timing,
    required this.onDaysBeforeChanged,
    required this.onPickTime,
  });

  final ReminderTiming timing;
  final ValueChanged<int> onDaysBeforeChanged;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 1, label: Text(localization.dayBefore)),
              ButtonSegment(value: 0, label: Text(localization.sameDay)),
            ],
            selected: {timing.daysBefore},
            onSelectionChanged: (selection) =>
                onDaysBeforeChanged(selection.first),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onPickTime,
            icon: const Icon(Icons.schedule),
            label: Text(formatWallClock(context, timing.time)),
          ),
        ],
      ),
    );
  }
}
