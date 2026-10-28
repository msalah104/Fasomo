import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/core/theme/app_shapes.dart';
import 'package:fasomo/features/home/domain/entities/week_day.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Today and the next six days, with a dot under each fasting day.
class WeekStrip extends StatelessWidget {
  const new({required this.week, super.key});

  /// Today first.
  final List<WeekDay> week;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: AppLocalizations.of(context).weekStripTitle,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              for (final (index, day) in week.indexed)
                Expanded(
                  child: _DayCell(day: day, isToday: index == 0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const new({required this.day, required this.isToday});

  final WeekDay day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final ink = isToday ? colors.onAccent : colors.onSurface;
    final primaryType = day.types.firstOrNull;
    final weekday = DateFormat.E(localization.localeName);

    final label = [
      DateFormat.MMMMEEEEd(localization.localeName).format(day.gregorianDate),
      localization.formatHijri(day.hijriDate),
      ...day.types.map(localization.fastingTypeTitle),
    ].join(', ');

    return Semantics(
      label: label,
      selected: isToday,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isToday ? colors.accent : null,
          borderRadius: AppShapes.of(context).smallRadius * 1.5,
        ),
        child: Column(
          children: [
            Text(
              weekday.format(day.gregorianDate),
              style: textTheme.labelSmall?.copyWith(color: ink),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.hijriDate.day}',
              style: textTheme.titleMedium?.copyWith(
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryType?.color(colors),
                border: primaryType == null
                    ? null
                    : Border.all(color: ink, width: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
