import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/utils/app_localizations.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder.dart';
import 'package:flutter/material.dart';

/// "Day before · at 8:00 PM", in the current language and clock format.
String reminderTimingText(BuildContext context, Reminder reminder) {
  final localization = AppLocalizations.of(context);
  final timing = reminder.timing;
  final day = timing.daysBefore == 0
      ? localization.sameDay
      : localization.dayBefore;
  return '$day · ${localization.atTime(formatWallClock(context, timing.time))}';
}

String formatWallClock(BuildContext context, WallClockTime time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: time.hour, minute: time.minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
