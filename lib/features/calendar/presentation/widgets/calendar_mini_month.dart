import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/core/theme/app_shapes.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_month.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// A month of the year view: its name over a small day grid in which each
/// fasting day is a dot in its type's colour.
///
/// The whole card is one button. A screen reader hears the month name and its
/// number of fasting days instead of thirty bare numbers; the current month
/// is outlined and announced, not just coloured.
class CalendarMiniMonth extends StatelessWidget {
  const new({required this.month, required this.onTap, super.key});

  final CalendarMonth month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final shape = AppShapes.of(context).cardShape;
    final isCurrent = month.containsToday;
    final name = localization.hijriMonthName(month.month.month);

    return Semantics(
      container: true,
      button: true,
      label: localization.yearViewMonthLabel(name, month.fastingDayCount),
      value: isCurrent ? localization.currentMonth : null,
      // The node above carries the tap itself; everything below is excluded.
      onTap: onTap,
      child: Card(
        semanticContainer: false,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: isCurrent
            ? shape.copyWith(
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
              )
            : shape,
        child: InkWell(
          onTap: onTap,
          excludeFromSemantics: true,
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? theme.colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _MiniMonthDays(days: month.days),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The days in weeks, Sunday first to match the month grid.
class _MiniMonthDays extends StatelessWidget {
  const new({required this.days});

  final List<CalendarDay> days;

  @override
  Widget build(BuildContext context) {
    final leadingBlanks = days.first.gregorianDate.weekday % 7;
    final slots = <CalendarDay?>[
      for (var blank = 0; blank < leadingBlanks; blank++) null,
      ...days,
    ];
    final weeks = (slots.length / 7).ceil();
    return Column(
      children: [
        for (var week = 0; week < weeks; week++)
          Row(
            children: [
              for (var weekday = 0; weekday < 7; weekday++)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: switch (slots.elementAtOrNull(week * 7 + weekday)) {
                      final day? => _MiniDay(day: day),
                      null => const SizedBox.shrink(),
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MiniDay extends StatelessWidget {
  const new({required this.day});

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final type = day.fastingTypes.firstOrNull;
    return Padding(
      padding: const EdgeInsets.all(1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: type?.color(colors),
          shape: BoxShape.circle,
          border: switch ((day.isToday, type)) {
            (true, _) => Border.all(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
            // The outline keeps pale dots (White Days) visible.
            (false, _?) => Border.all(color: colors.onSurfaceMuted, width: 0.5),
            (false, null) => null,
          },
        ),
        child: Center(
          child: Text(
            '${day.hijriDate.day}',
            softWrap: false,
            style: theme.textTheme.labelSmall?.copyWith(
              color: type?.onColor(colors) ?? theme.colorScheme.onSurface,
              fontWeight: day.isToday ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }
}
