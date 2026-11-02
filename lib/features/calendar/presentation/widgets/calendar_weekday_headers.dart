import 'package:flutter/material.dart';

/// The narrow weekday names above the month grid, Sunday first to match
/// `CalendarGrid`.
class CalendarWeekdayHeaders extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final weekdays = MaterialLocalizations.of(context).narrowWeekdays;
    final style = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );
    return Row(
      children: [
        for (final day in weekdays)
          Expanded(
            child: Center(child: Text(day, style: style)),
          ),
      ],
    );
  }
}
