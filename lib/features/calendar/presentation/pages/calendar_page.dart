import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../bloc/calendar_bloc.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/calendar_header.dart';
import '../widgets/day_detail_sheet.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        if (state.status == CalendarStatus.loading &&
            state.days.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == CalendarStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'Error loading calendar'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CalendarBloc>().add(LoadCalendar());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return BlocListener<CalendarBloc, CalendarState>(
          listenWhen: (previous, current) =>
              previous.selectedDay != current.selectedDay &&
              current.selectedDay != null,
          listener: (context, state) {
            if (state.selectedDay != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => DayDetailSheet(day: state.selectedDay!),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CalendarHeader(
                  month: state.currentMonth,
                  year: state.currentYear,
                  onPreviousMonth: () {
                    context.read<CalendarBloc>().add(PreviousMonth());
                  },
                  onNextMonth: () {
                    context.read<CalendarBloc>().add(NextMonth());
                  },
                ),
                const SizedBox(height: 16),
                _buildWeekdayHeaders(context),
                const SizedBox(height: 8),
                Expanded(
                  child: CalendarGrid(
                    days: state.days,
                    onDayTap: (day) {
                      context.read<CalendarBloc>().add(SelectDay(day));
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegend(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    final locale = context.watch<HomeBloc>().state.locale;
    final weekdays = locale.languageCode == 'ar'
        ? ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س']
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem(
                  context,
                  Colors.green,
                  localization.whiteDays,
                ),
                _buildLegendItem(
                  context,
                  Colors.orange,
                  localization.mondayThursday,
                ),
                _buildLegendItem(
                  context,
                  Colors.purple,
                  localization.ramadan,
                ),
                _buildLegendItem(
                  context,
                  Colors.blue,
                  'Special Days',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
