import 'dart:async';

import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/qada_reminder_text.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Switches and options for each kind of make-up reminder. Every change is
/// saved at once, which resyncs the notifications.
class QadaReminderSheet extends StatelessWidget {
  const new({super.key});

  static void show(BuildContext context) => unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const QadaReminderSheet(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return BlocSelector<TrackerBloc, TrackerState, QadaReminderSettings>(
      selector: (state) => state.qadaReminders,
      builder: (context, settings) {
        void update(QadaReminderSettings next) =>
            context.read<TrackerBloc>().add(UpdateQadaReminders(next));

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.qadaReminders,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localization.weeklyReminder),
                  value: settings.weeklyEnabled,
                  onChanged: (on) =>
                      update(settings.copyWith(weeklyEnabled: on)),
                ),
                if (settings.weeklyEnabled)
                  _WeekdayPicker(
                    selected: settings.weekdays,
                    onChanged: (days) =>
                        update(settings.copyWith(weekdays: days)),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localization.monthlyReminder),
                  value: settings.monthlyEnabled,
                  onChanged: (on) =>
                      update(settings.copyWith(monthlyEnabled: on)),
                ),
                if (settings.monthlyEnabled)
                  DropdownButton<int>(
                    isExpanded: true,
                    value: settings.monthlyHijriDay,
                    items: [
                      for (var day = 1; day <= 30; day++)
                        DropdownMenuItem(
                          value: day,
                          child: Text(
                            day == QadaReminderSettings.whiteDaysStart
                                ? localization.whiteDaysOption
                                : localization.hijriDayOption('$day'),
                          ),
                        ),
                    ],
                    onChanged: (day) {
                      if (day != null) {
                        update(settings.copyWith(monthlyHijriDay: day));
                      }
                    },
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localization.beforeRamadanReminder),
                  value: settings.beforeRamadanEnabled,
                  onChanged: (on) =>
                      update(settings.copyWith(beforeRamadanEnabled: on)),
                ),
                if (settings.beforeRamadanEnabled)
                  _CountdownPicker(
                    selected: settings.daysBeforeRamadan,
                    onChanged: (days) =>
                        update(settings.copyWith(daysBeforeRamadan: days)),
                  ),
                const SizedBox(height: 16),
                Text(
                  localization.reminderTimeLabel,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<QadaReminderTime>(
                  segments: [
                    ButtonSegment(
                      value: QadaReminderTime.eveningBefore,
                      label: Text(localization.dayBefore),
                    ),
                    ButtonSegment(
                      value: QadaReminderTime.morningOf,
                      label: Text(localization.morningOfDay),
                    ),
                  ],
                  selected: {settings.time},
                  onSelectionChanged: (selection) =>
                      update(settings.copyWith(time: selection.single)),
                ),
                const SizedBox(height: 16),
                Text(
                  localization.qadaRemindersFootnote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  const new({required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  /// Saturday first, the start of the week in much of the Muslim world.
  static const List<int> _order = [
    DateTime.saturday,
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  ];

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final weekday in _order)
          FilterChip(
            label: Text(localization.weekdayName(weekday)),
            selected: selected.contains(weekday),
            onSelected: (on) => onChanged(
              on ? {...selected, weekday} : ({...selected}..remove(weekday)),
            ),
          ),
      ],
    );
  }
}

class _CountdownPicker extends StatelessWidget {
  const new({required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final days = selected.toList()..sort((a, b) => b.compareTo(a));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final count in days)
          InputChip(
            label: Text(localization.daysBeforeOption(count)),
            onDeleted: () => onChanged({...selected}..remove(count)),
          ),
        ActionChip(
          avatar: const Icon(Icons.add),
          label: Text(localization.addDaysBefore),
          onPressed: () async {
            final count = await showDialog<int>(
              context: context,
              builder: (_) => const _DaysBeforeDialog(),
            );
            if (count != null) onChanged({...selected, count});
          },
        ),
      ],
    );
  }
}

/// Asks for a number of days before Ramadan, 1 to
/// [QadaReminderSettings.maxDaysBeforeRamadan].
class _DaysBeforeDialog extends StatefulWidget {
  const new();

  @override
  State<_DaysBeforeDialog> createState() => _DaysBeforeDialogState();
}

class _DaysBeforeDialogState extends State<_DaysBeforeDialog> {
  final _controller = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value == null ||
        value < 1 ||
        value > QadaReminderSettings.maxDaysBeforeRamadan) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(localization.daysBeforeDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          errorText: _invalid
              ? localization.daysBeforeInvalid(
                  QadaReminderSettings.maxDaysBeforeRamadan,
                )
              : null,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localization.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(localization.save)),
      ],
    );
  }
}
