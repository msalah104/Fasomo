import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/core/theme/app_shapes.dart';
import 'package:fasomo/features/home/domain/entities/week_day.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Today and the next six days, with a dot under each fasting day. Tapping a
/// day selects it.
class WeekStrip extends StatelessWidget {
  const new({
    required this.week,
    required this.selectedDate,
    required this.onDaySelected,
    super.key,
  });

  /// Today first.
  final List<WeekDay> week;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  /// The strip's height at [textScaler]. The strip is pinned in a header of
  /// fixed extent, so its height is worked out up front rather than measured;
  /// it grows with the text size instead of clipping it.
  static double heightFor(TextScaler textScaler) =>
      // Card padding and outline, cell padding and gaps, then the two lines
      // (labelSmall 11 × 1.45, titleMedium 16 × 1.5) and a little slack.
      48 + textScaler.scale(11) * 1.45 + textScaler.scale(16) * 1.5;

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
                  child: _DayCell(
                    day: day,
                    isToday: index == 0,
                    isSelected: CalendarDays.isSameDay(
                      day.gregorianDate,
                      selectedDate,
                    ),
                    onTap: () => onDaySelected(day.gregorianDate),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const new({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final WeekDay day;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final radius = AppShapes.of(context).smallRadius * 1.5;
    final ink = isSelected ? colors.onAccent : colors.onSurface;
    final primaryType = day.types.firstOrNull;

    final label = [
      DateFormat.MMMMEEEEd(localization.localeName).format(day.gregorianDate),
      localization.formatHijri(day.hijriDate),
      ...day.types.map(localization.fastingTypeTitle),
    ].join(', ');

    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.accent : null,
            borderRadius: radius,
            // Today keeps an outline when another day is selected.
            border: isToday && !isSelected
                ? Border.all(color: colors.accent, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat.E(localization.localeName).format(day.gregorianDate),
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
      ),
    );
  }
}
