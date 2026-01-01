import 'package:flutter/material.dart';

import '../../../home/domain/entities/fasting_day.dart';
import '../../domain/entities/calendar_day.dart';

class CalendarDayCell extends StatelessWidget {
  final CalendarDay day;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(theme),
          borderRadius: BorderRadius.circular(8),
          border: day.isToday
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${day.hijriDate.hDay}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
                  color: day.isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (day.isFastingDay) _buildFastingIndicators(theme),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (day.isToday) {
      return theme.colorScheme.primary.withOpacity(0.1);
    }
    if (day.isFastingDay) {
      return _getPrimaryFastingColor().withOpacity(0.15);
    }
    return Colors.transparent;
  }

  Color _getPrimaryFastingColor() {
    if (day.fastingTypes.contains(FastingType.ramadan)) {
      return Colors.purple;
    }
    if (day.fastingTypes.contains(FastingType.arafah) ||
        day.fastingTypes.contains(FastingType.ashura) ||
        day.fastingTypes.contains(FastingType.tasua)) {
      return Colors.blue;
    }
    if (day.fastingTypes.contains(FastingType.whiteDays)) {
      return Colors.green;
    }
    if (day.fastingTypes.contains(FastingType.mondayThursday)) {
      return Colors.orange;
    }
    return Colors.teal;
  }

  Widget _buildFastingIndicators(ThemeData theme) {
    return Positioned(
      bottom: 2,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: day.fastingTypes.take(3).map((type) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _getColorForType(type),
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForType(FastingType type) {
    switch (type) {
      case FastingType.ramadan:
        return Colors.purple;
      case FastingType.arafah:
      case FastingType.ashura:
      case FastingType.tasua:
        return Colors.blue;
      case FastingType.whiteDays:
        return Colors.green;
      case FastingType.mondayThursday:
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}
