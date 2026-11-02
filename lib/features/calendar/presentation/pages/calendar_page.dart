import 'dart:async';

import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_month.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_header.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_legend.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_month_pager.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_toolbar.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_weekday_headers.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_year_view.dart';
import 'package:fasomo/features/calendar/presentation/widgets/day_detail_sheet.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Hijri calendar: one month at a time, swiped sideways, or the twelve
/// months of a year.
///
/// Each day's badge and the action in the day sheet come from outside so
/// this feature does not depend on the tracker; the app shell wires them.
class CalendarPage extends StatelessWidget {
  const new({this.dayBadgeBuilder, this.dayActionBuilder, super.key});

  /// Builds a small badge for a day's top-end corner, or `null` for none.
  final Widget? Function(CalendarDay day)? dayBadgeBuilder;

  /// Builds an extra action for the day sheet, or `null` for none. It is
  /// built inside the sheet, so it should listen to its own state to stay
  /// current while the sheet is open.
  final Widget? Function(CalendarDay day)? dayActionBuilder;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // A failed month or year change keeps the last good one and shows a
        // snackbar.
        BlocListener<CalendarBloc, CalendarState>(
          listenWhen: (previous, current) =>
              current.status == CalendarStatus.error &&
              previous.status != CalendarStatus.error &&
              current.days.isNotEmpty,
          listener: (context, state) => _showSnackBar(
            context,
            switch (state.view) {
              CalendarView.month => AppLocalizations.of(
                context,
              ).monthUnavailable,
              CalendarView.year => AppLocalizations.of(context).yearUnavailable,
            },
          ),
        ),
        BlocListener<CalendarBloc, CalendarState>(
          listenWhen: (previous, current) => current.preferenceFailure != null,
          listener: (context, state) => _showSnackBar(
            context,
            AppLocalizations.of(context).calendarSettingSaveFailed,
          ),
        ),
      ],
      child: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) => switch (state) {
          CalendarState(view: CalendarView.year, year: final year?)
              when state.yearMonths.isNotEmpty =>
            _CalendarFrame(
              state: state,
              child: _YearBody(year: year, months: state.yearMonths),
            ),
          CalendarState(month: final month?) when state.days.isNotEmpty =>
            _CalendarFrame(
              state: state,
              child: _MonthBody(
                month: month,
                state: state,
                dayBadgeBuilder: dayBadgeBuilder,
                onDayTap: (day) => _showDay(context, day),
              ),
            ),
          _ when state.status == CalendarStatus.error => const _CalendarError(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDay(BuildContext context, CalendarDay day) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            DayDetailSheet(day: day, action: dayActionBuilder?.call(day)),
      ),
    );
  }
}

/// What every loaded view shares: the toolbar above and, in the month view,
/// the legend pinned below. The year view scrolls its legend after the
/// months, leaving the room to the mini months.
class _CalendarFrame extends StatelessWidget {
  const new({required this.state, required this.child});

  final CalendarState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CalendarBloc>();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CalendarToolbar(
            view: state.view,
            showTodayButton: !state.isShowingCurrentMonth,
            showGregorianDays: state.showGregorianDays,
            onViewChanged: (view) => bloc.add(switch (view) {
              CalendarView.month => const ShowMonthView(),
              CalendarView.year => const ShowYearView(),
            }),
            onToday: () => bloc.add(const GoToToday()),
            onToggleGregorianDays: () => bloc.add(const ToggleGregorianDays()),
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
          if (state.view == CalendarView.month) ...[
            const SizedBox(height: 16),
            const CalendarLegend(),
          ],
        ],
      ),
    );
  }
}

/// One month: its header, weekday names and the swipeable grid.
class _MonthBody extends StatelessWidget {
  const new({
    required this.month,
    required this.state,
    required this.dayBadgeBuilder,
    required this.onDayTap,
  });

  final HijriMonth month;
  final CalendarState state;
  final Widget? Function(CalendarDay day)? dayBadgeBuilder;
  final ValueChanged<CalendarDay> onDayTap;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CalendarBloc>();
    return Column(
      children: [
        CalendarHeader(
          month: month,
          onPreviousMonth: () => bloc.add(const PreviousMonth()),
          onNextMonth: () => bloc.add(const NextMonth()),
        ),
        const SizedBox(height: 16),
        const CalendarWeekdayHeaders(),
        const SizedBox(height: 8),
        Expanded(
          child: CalendarMonthPager(
            month: month,
            days: state.days,
            previousDays: state.previousDays,
            nextDays: state.nextDays,
            showGregorianDays: state.showGregorianDays,
            dayBadgeBuilder: dayBadgeBuilder,
            onDayTap: onDayTap,
            onMonthChanged: (month) => bloc.add(ChangeMonth(month)),
          ),
        ),
      ],
    );
  }
}

/// One year: its header and the twelve mini months.
class _YearBody extends StatelessWidget {
  const new({required this.year, required this.months});

  final int year;
  final List<CalendarMonth> months;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<CalendarBloc>();
    return Column(
      children: [
        CalendarPeriodHeader(
          title: localization.hijriYear('$year'),
          previousTooltip: localization.previousYear,
          nextTooltip: localization.nextYear,
          onPrevious: () => bloc.add(const PreviousYear()),
          onNext: () => bloc.add(const NextYear()),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: CalendarYearView(
            months: months,
            onMonthTap: (month) => bloc.add(ChangeMonth(month)),
            footer: const CalendarLegend(),
          ),
        ),
      ],
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
