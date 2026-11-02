import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:flutter/material.dart';

class CalendarGrid extends StatelessWidget {
  const new({
    required this.days,
    required this.onDayTap,
    this.dayBadgeBuilder,
    this.showGregorianDays = false,
    super.key,
  });
  final List<CalendarDay> days;
  final ValueChanged<CalendarDay> onDayTap;
  final Widget? Function(CalendarDay day)? dayBadgeBuilder;

  /// Whether each cell shows the Gregorian day number too; the cells grow
  /// taller to make room for it.
  final bool showGregorianDays;

  @override
  Widget build(BuildContext context) {
    // Calculate the starting weekday offset
    final firstDay = days.first.gregorianDate;
    final startingWeekday = firstDay.weekday % 7; // 0 = Sunday

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: showGregorianDays ? 0.75 : 1,
      ),
      itemCount: days.length + startingWeekday,
      itemBuilder: (context, index) {
        if (index < startingWeekday) {
          return const SizedBox.shrink(); // Empty cell for alignment
        }

        final dayIndex = index - startingWeekday;
        final day = days[dayIndex];

        return CalendarDayCell(
          day: day,
          badge: dayBadgeBuilder?.call(day),
          showGregorianDay: showGregorianDays,
          onTap: () => onDayTap(day),
        );
      },
    );
  }
}
