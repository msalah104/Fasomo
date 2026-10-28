import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/tracker/domain/fast_log_rules.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Marks [date] as fasted or clears it. Draws nothing for a day that cannot
/// be logged (a future or forbidden day).
class FastedToggle extends StatelessWidget {
  const new({required this.date, required this.hijri, super.key});

  final DateTime date;
  final HijriDate hijri;

  @override
  Widget build(BuildContext context) {
    final today = CalendarDays.dateOnly(clock.now());
    if (!FastLogRules.canLog(date: date, hijri: hijri, today: today)) {
      return const SizedBox.shrink();
    }

    final localization = AppLocalizations.of(context);
    final isToday = CalendarDays.isSameDay(date, today);
    final bloc = context.read<TrackerBloc>();
    void toggle() => bloc.add(ToggleDayFasted(date));

    return BlocSelector<TrackerBloc, TrackerState, bool>(
      selector: (state) => state.isFasted(date),
      builder: (context, isFasted) {
        // The label changes with the state and the icon changes shape, so the
        // state never rests on colour alone.
        return Semantics(
          toggled: isFasted,
          child: isFasted
              ? FilledButton.icon(
                  onPressed: toggle,
                  icon: const Icon(Icons.check_circle),
                  label: Text(localization.fasted),
                )
              : OutlinedButton.icon(
                  onPressed: toggle,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    isToday
                        ? localization.markFastedToday
                        : localization.markAsFasted,
                  ),
                ),
        );
      },
    );
  }
}
