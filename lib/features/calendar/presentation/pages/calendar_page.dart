import 'dart:async';

import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/utils/app_localizations.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_header.dart';
import 'package:fasomo/features/calendar/presentation/widgets/day_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      // A failed month change keeps the last good month and shows a snackbar.
      listenWhen: (previous, current) =>
          current.status == CalendarStatus.error && current.days.isNotEmpty,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).monthUnavailable)),
      ),
      builder: (context, state) {
        final month = state.month;
        if (month == null || state.days.isEmpty) {
          return state.status == CalendarStatus.error
              ? const _CalendarError()
              : const Center(child: CircularProgressIndicator());
        }

        final bloc = context.read<CalendarBloc>();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CalendarHeader(
                month: month,
                onPreviousMonth: () => bloc.add(const PreviousMonth()),
                onNextMonth: () => bloc.add(const NextMonth()),
              ),
              const SizedBox(height: 16),
              const _WeekdayHeaders(),
              const SizedBox(height: 8),
              Expanded(
                child: CalendarGrid(
                  days: state.days,
                  onDayTap: (day) => _showDay(context, day),
                ),
              ),
              const SizedBox(height: 16),
              const _Legend(),
            ],
          ),
        );
      },
    );
  }

  void _showDay(BuildContext context, CalendarDay day) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DayDetailSheet(day: day),
      ),
    );
  }
}

class _CalendarError extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(localization.monthUnavailable),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<CalendarBloc>().add(const LoadCalendar()),
            child: Text(localization.retry),
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeaders extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    // Sunday first, matching CalendarGrid.
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

class _Legend extends StatelessWidget {
  const new();

  static const List<FastingType> _types = [
    FastingType.whiteDays,
    FastingType.mondayThursday,
    FastingType.ramadan,
    FastingType.shawwal,
    FastingType.arafah,
  ];

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final type in _types)
              _LegendItem(
                type: type,
                label: type == FastingType.arafah
                    ? localization.specialDays
                    : localization.fastingTypeTitle(type),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const new({required this.type, required this.label});

  final FastingType type;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: type.color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: type.color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
