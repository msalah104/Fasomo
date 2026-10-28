import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/widgets/owed_days_dialog.dart';
import 'package:fasomo/features/tracker/presentation/widgets/streak_stat.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The make-up (Qada) balance: what's left, the split per Ramadan, a button
/// for today's make-up fast and one to enter days owed.
class QadaSection extends StatelessWidget {
  const new({required this.summary, super.key});

  final FastLogSummary summary;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final qada = summary.qada;
    final today = CalendarDays.dateOnly(clock.now());
    final isMadeUpToday = summary.isMakeUp(today);
    final showMakeUpToday =
        summary.canMakeUpToday && (qada.remaining > 0 || isMadeUpToday);

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
                const SizedBox(height: 8),
                if (showMakeUpToday)
                  _MakeUpTodayButton(
                    isMadeUp: isMadeUpToday,
                    onPressed: () =>
                        context.read<TrackerBloc>().add(ToggleMakeUp(today)),
                  ),
                if (qada.latestOwableYear != null)
                  TextButton.icon(
                    onPressed: () => _addOwed(context, qada),
                    icon: const Icon(Icons.add),
                    label: Text(localization.qadaAddOwed),
                  ),
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

class _MakeUpTodayButton extends StatelessWidget {
  const new({required this.isMadeUp, required this.onPressed});

  final bool isMadeUp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Semantics(
      toggled: isMadeUp,
      child: isMadeUp
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.history),
              label: Text(localization.madeUp),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.history),
              label: Text(localization.makeUpFastToday),
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
