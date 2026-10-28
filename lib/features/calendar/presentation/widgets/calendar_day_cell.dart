import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  const new({required this.day, required this.onTap, super.key});

  final CalendarDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryType = day.fastingTypes.firstOrNull;
    final background = day.isToday
        ? theme.colorScheme.primary.withValues(alpha: 0.1)
        : primaryType?.color.withValues(alpha: 0.15) ?? Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: day.isToday
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${day.hijriDate.day}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
                  color: day.isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (day.isFastingDay)
              PositionedDirectional(
                bottom: 2,
                start: 0,
                end: 0,
                child: _FastingDots(day: day),
              ),
          ],
        ),
      ),
    );
  }
}

class _FastingDots extends StatelessWidget {
  const new({required this.day});

  final CalendarDay day;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final type in day.fastingTypes.take(3))
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: type.color,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
