import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/widgets/fasted_toggle.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// What can be logged for one day in the day sheet: fasted or missed on a
/// Ramadan day; otherwise fasted, plus a make-up switch once something is
/// owed. Draws nothing for a day that can't be logged.
class TrackerDayActions extends StatelessWidget {
  const new({required this.date, required this.hijri, super.key});

  final DateTime date;
  final HijriDate hijri;

  /// Whether the sheet has anything to show for [date] on [today].
  static bool appliesTo({
    required DateTime date,
    required HijriDate hijri,
    required DateTime today,
  }) =>
      FastLogRules.canLog(date: date, hijri: hijri, today: today) ||
      FastLogRules.canMarkMissed(date: date, hijri: hijri, today: today);

  @override
  Widget build(BuildContext context) {
    final today = CalendarDays.dateOnly(clock.now());
    if (FastLogRules.canMarkMissed(date: date, hijri: hijri, today: today)) {
      return _RamadanDayToggle(date: date);
    }
    if (!FastLogRules.canLog(date: date, hijri: hijri, today: today)) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FastedToggle(date: date, hijri: hijri),
        if (FastLogRules.canMakeUp(date: date, hijri: hijri, today: today))
          _MakeUpSwitch(date: date),
      ],
    );
  }
}

/// Fasted or missed, either of which can be cleared.
class _RamadanDayToggle extends StatelessWidget {
  const new({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<TrackerBloc>();
    return BlocSelector<TrackerBloc, TrackerState, DayMark?>(
      selector: (state) => state.summary.markFor(date),
      builder: (context, mark) {
        return SegmentedButton<DayMark>(
          emptySelectionAllowed: true,
          segments: [
            ButtonSegment(
              value: DayMark.fasted,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(localization.fasted),
            ),
            ButtonSegment(
              value: DayMark.missed,
              icon: const Icon(Icons.cancel_outlined),
              label: Text(localization.missed),
            ),
          ],
          selected: {?mark},
          onSelectionChanged: (selection) {
            // Selecting a segment sets it; tapping the selected one clears it.
            final tapped = selection.firstOrNull ?? mark;
            switch (tapped) {
              case DayMark.fasted:
                bloc.add(ToggleDayFasted(date));
              case DayMark.missed:
                bloc.add(ToggleRamadanMissed(date));
              case DayMark.makeUp || null:
                break;
            }
          },
        );
      },
    );
  }
}

/// Shown while make-up days are owed, or when [date] already is one.
class _MakeUpSwitch extends StatelessWidget {
  const new({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return BlocBuilder<TrackerBloc, TrackerState>(
      buildWhen: (previous, current) =>
          previous.summary.isMakeUp(date) != current.summary.isMakeUp(date) ||
          previous.summary.qada.remaining != current.summary.qada.remaining,
      builder: (context, state) {
        final isMakeUp = state.summary.isMakeUp(date);
        if (!isMakeUp && state.summary.qada.remaining == 0) {
          return const SizedBox.shrink();
        }
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.history),
          title: Text(localization.makeUpFast),
          subtitle: Text(localization.makeUpFastHint),
          value: isMakeUp,
          onChanged: (_) => context.read<TrackerBloc>().add(ToggleMakeUp(date)),
        );
      },
    );
  }
}
