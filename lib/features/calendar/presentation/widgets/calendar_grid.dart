import 'package:flutter/material.dart';

import '../../domain/entities/calendar_day.dart';
import 'calendar_day_cell.dart';

class CalendarGrid extends StatelessWidget {
  final List<CalendarDay> days;
  final Function(CalendarDay) onDayTap;

  const CalendarGrid({
    super.key,
    required this.days,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the starting weekday offset
    final firstDay = days.first.gregorianDate;
    final startingWeekday = firstDay.weekday % 7; // 0 = Sunday

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
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
          onTap: () => onDayTap(day),
        );
      },
    );
  }
}
