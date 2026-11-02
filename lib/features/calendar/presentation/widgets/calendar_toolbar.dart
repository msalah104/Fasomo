import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The row above the calendar: the month/year view switch, a Today button
/// shown only away from the current month, and the Gregorian day numbers
/// toggle, which only applies to the month view.
class CalendarToolbar extends StatelessWidget {
  const new({
    required this.view,
    required this.showTodayButton,
    required this.showGregorianDays,
    required this.onViewChanged,
    required this.onToday,
    required this.onToggleGregorianDays,
    super.key,
  });

  final CalendarView view;
  final bool showTodayButton;
  final bool showGregorianDays;
  final ValueChanged<CalendarView> onViewChanged;
  final VoidCallback onToday;
  final VoidCallback onToggleGregorianDays;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    // Wraps instead of overflowing on a narrow screen or at large text.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        SegmentedButton<CalendarView>(
          segments: [
            ButtonSegment(
              value: CalendarView.month,
              label: Text(localization.monthView),
            ),
            ButtonSegment(
              value: CalendarView.year,
              label: Text(localization.yearView),
            ),
          ],
          selected: {view},
          // Kept narrow so the row fits a small phone. The selection is also
          // carried by the filled segment, the semantics and the view shown.
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          onSelectionChanged: (selection) => onViewChanged(selection.first),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            if (showTodayButton)
              Tooltip(
                message: localization.goToTodayTooltip,
                child: TextButton.icon(
                  onPressed: onToday,
                  icon: const Icon(Icons.today),
                  label: Text(localization.goToToday),
                ),
              ),
            // The check mark shows the state without relying on colour.
            if (view == CalendarView.month)
              FilterChip(
                label: Text(localization.gregorianDays),
                tooltip: localization.gregorianDaysTooltip,
                selected: showGregorianDays,
                onSelected: (_) => onToggleGregorianDays(),
              ),
          ],
        ),
      ],
    );
  }
}
