import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The row above the month: a Today button, shown only away from the current
/// month, and the Gregorian day numbers toggle.
class CalendarToolbar extends StatelessWidget {
  const new({
    required this.showTodayButton,
    required this.showGregorianDays,
    required this.onToday,
    required this.onToggleGregorianDays,
    super.key,
  });

  final bool showTodayButton;
  final bool showGregorianDays;
  final VoidCallback onToday;
  final VoidCallback onToggleGregorianDays;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    // Wraps instead of overflowing on a narrow screen or at large text.
    return Wrap(
      alignment: WrapAlignment.end,
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
        FilterChip(
          label: Text(localization.gregorianDays),
          tooltip: localization.gregorianDaysTooltip,
          selected: showGregorianDays,
          onSelected: (_) => onToggleGregorianDays(),
        ),
      ],
    );
  }
}
