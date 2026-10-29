import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/widgets/owed_days_dialog.dart';
import 'package:fasomo/features/tracker/presentation/widgets/streak_stat.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The make-up (Qada) balance: what's left, the split per Ramadan, the
/// recent make-up fasts, and buttons to log one on any day and to enter days
/// owed, so nothing here needs the calendar.
class QadaSection extends StatelessWidget {
  const new({required this.summary, super.key});

  /// How many of the latest make-up fasts are listed.
  static const int recentCount = 5;

  final FastLogSummary summary;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final qada = summary.qada;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localization.qadaTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (qada.byYear.isEmpty)
                  Text(
                    localization.qadaNoneOwed,
                    style: theme.textTheme.bodyMedium,
                  )
                else ...[
                  StreakStat(
                    value: qada.remaining,
                    label: localization.qadaDaysLeft,
                  ),
                  if (qada.remaining > 0 && qada.daysUntilRamadan != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      localization.daysUntilRamadan(qada.daysUntilRamadan!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  for (final year in qada.byYear) _QadaYearRow(year: year),
                ],
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _logMakeUp(context),
                  icon: const Icon(Icons.history),
                  label: Text(localization.logMakeUpFast),
                ),
                if (qada.latestOwableYear != null)
                  TextButton.icon(
                    onPressed: () => _addOwed(context, qada),
                    icon: const Icon(Icons.add),
                    label: Text(localization.qadaAddOwed),
                  ),
                if (qada.makeUps.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    localization.recentMakeUps,
                    style: theme.textTheme.titleSmall,
                  ),
                  for (final day in qada.makeUps.take(recentCount))
                    _MakeUpRow(day: day),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localization.qadaExplanation,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }

  /// Picks any valid past day (not Ramadan, an Eid or a day already logged as
  /// a make-up fast) and logs it.
  Future<void> _logMakeUp(BuildContext context) async {
    final bloc = context.read<TrackerBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final localization = AppLocalizations.of(context);
    final today = CalendarDays.dateOnly(clock.now());
    bool selectable(DateTime day) =>
        bloc.canMakeUpOn(day) && !summary.isMakeUp(day);

    // The picker needs a selectable starting day: today, or the nearest
    // earlier one (today may fall in Ramadan or on Eid).
    final initial = [
      for (var offset = 0; offset <= _initialSearchDays; offset++)
        CalendarDays.addDays(today, -offset),
    ].where(selectable).firstOrNull;
    if (initial == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(localization.noMakeUpDayAvailable)),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(today.year - _yearsBack),
      lastDate: today,
      helpText: localization.pickMakeUpDay,
      selectableDayPredicate: selectable,
    );
    if (picked == null) return;
    bloc.add(ToggleMakeUp(picked));
  }

  /// Longer than Ramadan plus Eid, so a start day is always found.
  static const int _initialSearchDays = 40;

  /// How far back the picker reaches.
  static const int _yearsBack = 15;

  Future<void> _addOwed(BuildContext context, QadaSummary qada) async {
    final bloc = context.read<TrackerBloc>();
    final picked = await showDialog<OwedDays>(
      context: context,
      builder: (_) => OwedDaysDialog(qada: qada),
    );
    if (picked == null) return;
    bloc.add(SetExtraOwed(hijriYear: picked.hijriYear, days: picked.days));
  }
}

class _MakeUpRow extends StatelessWidget {
  const new({required this.day});

  final LoggedDay day;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(Icons.history, color: colors.accent),
      title: Text(localization.formatGregorian(day.date)),
      subtitle: Text(
        localization.formatHijri(day.hijri),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceMuted,
        ),
      ),
      // Removing undoes the whole entry, so a day logged by mistake doesn't
      // stay behind as fasted. The calendar's switch clears only the flag.
      trailing: IconButton(
        tooltip: localization.removeMakeUp,
        icon: const Icon(Icons.delete_outline),
        onPressed: () =>
            context.read<TrackerBloc>().add(ToggleDayFasted(day.date)),
      ),
    );
  }
}

class _QadaYearRow extends StatelessWidget {
  const new({required this.year});

  final QadaYear year;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localization.ramadanOfYear('${year.hijriYear}'),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Text(
                  localization.qadaMadeUpOfOwed(year.madeUp, year.owed),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: LinearProgressIndicator(
                value: year.madeUp / year.owed,
                color: colors.accent,
                backgroundColor: colors.hairline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
