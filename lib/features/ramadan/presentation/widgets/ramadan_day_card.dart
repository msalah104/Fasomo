import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/prayer_text.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';
import 'package:fasomo/features/ramadan/presentation/ramadan_text.dart';
import 'package:fasomo/features/ramadan/presentation/widgets/prayer_times_tile.dart';
import 'package:fasomo/features/ramadan/presentation/widgets/ramadan_checklist_section.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// A day of Ramadan: which day it is, the next suhoor end or iftar with a
/// countdown, today's two times, the checklist and all the prayer times.
class RamadanDayCard extends StatelessWidget {
  const new({
    required this.day,
    required this.checklist,
    required this.checklistFailed,
    this.fastedAction,
    super.key,
  });

  final RamadanDay day;

  /// `null` until read, or when [checklistFailed].
  final RamadanChecklist? checklist;
  final bool checklistFailed;

  /// The tracker's "fasted today" control, from the app shell.
  final Widget? fastedAction;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final next = day.next;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                _RamadanHeader(day: day),
                Semantics(
                  label: next == null
                      ? null
                      : localization.fastingMomentCountdownSpoken(next),
                  excludeSemantics: next != null,
                  child: Text(
                    next == null
                        ? localization.ramadanComplete
                        : localization.fastingMomentCountdown(next),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                _FastTimes(day: day),
                Text(
                  localization.ramadanTimesSource(day.location, day.method),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          RamadanChecklistSection(
            checklist: checklist,
            failed: checklistFailed,
            fastedAction: fastedAction,
          ),
          const Divider(height: 1),
          PrayerTimesTile(times: day.times),
        ],
      ),
    );
  }
}

/// "Ramadan · Day 12 of 30". The month bar above the card already shows
/// the month so far, so there is no second bar here.
class _RamadanHeader extends StatelessWidget {
  const new({required this.day});

  final RamadanDay day;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return Row(
      children: [
        ExcludeSemantics(
          child: Icon(
            FastingType.ramadan.icon,
            color: FastingType.ramadan.color(colors),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              localization.ramadan,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        Text(
          localization.ramadanDayOf(day.dayOfRamadan, day.daysInMonth),
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}

/// When suhoor ends (Fajr) and when iftar is (Maghrib) today.
class _FastTimes extends StatelessWidget {
  const new({required this.day});

  final RamadanDay day;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final use24HourClock = MediaQuery.alwaysUse24HourFormatOf(context);
    return Row(
      children: [
        Expanded(
          child: _TimeColumn(
            icon: Icons.wb_twilight_outlined,
            label: localization.ramadanSuhoorEnds,
            time: localization.prayerTime(
              day.times.fajr,
              use24HourClock: use24HourClock,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeColumn(
            icon: Icons.nights_stay_outlined,
            label: localization.ramadanIftar,
            time: localization.prayerTime(
              day.times.maghrib,
              use24HourClock: use24HourClock,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const new({required this.icon, required this.label, required this.time});

  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Icon(icon, color: colors.accent)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                Text(time, style: theme.textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
