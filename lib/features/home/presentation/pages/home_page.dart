import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/home/presentation/sky_period.dart';
import 'package:fasomo/features/home/presentation/widgets/fasting_day_card.dart';
import 'package:fasomo/features/home/presentation/widgets/month_progress_bar.dart';
import 'package:fasomo/features/home/presentation/widgets/sky_hero.dart';
import 'package:fasomo/features/home/presentation/widgets/week_header_delegate.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// The sky header with today's date, this week, the month so far and the
/// upcoming fasting days.
///
/// Reminder state, the header action, the progress section and today's
/// action come from outside so this feature does not depend on the
/// reminders, settings or tracker features; the app shell wires them together.
class HomePage extends StatelessWidget {
  const new({
    required this.isReminderOn,
    required this.onToggleReminder,
    this.headerActionBuilder,
    this.progressSection,
    this.todayActionBuilder,
    super.key,
  });

  final bool Function(FastingType type) isReminderOn;
  final ValueChanged<FastingType> onToggleReminder;

  /// Builds the action shown on the sky, in the colour that reads on it.
  final Widget Function(Color color)? headerActionBuilder;

  /// Shown between the month bar and the fasting days list.
  final Widget? progressSection;

  /// Builds an extra action for today's fasting-day card.
  final TodayActionBuilder? todayActionBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return switch (state.status) {
          HomeStatus.initial || HomeStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          HomeStatus.error => const _HomeError(),
          HomeStatus.success => _HomeContent(
            state: state,
            isReminderOn: isReminderOn,
            onToggleReminder: onToggleReminder,
            headerActionBuilder: headerActionBuilder,
            progressSection: progressSection,
            todayActionBuilder: todayActionBuilder,
          ),
        };
      },
    );
  }
}

/// Builds an action for today's fasting day, given both of its dates.
typedef TodayActionBuilder = Widget Function(
  DateTime gregorianDate,
  HijriDate hijriDate,
);

class _HomeContent extends StatelessWidget {
  const new({
    required this.state,
    required this.isReminderOn,
    required this.onToggleReminder,
    required this.headerActionBuilder,
    required this.progressSection,
    required this.todayActionBuilder,
  });

  final HomeState state;
  final bool Function(FastingType type) isReminderOn;
  final ValueChanged<FastingType> onToggleReminder;
  final Widget Function(Color color)? headerActionBuilder;
  final Widget? progressSection;
  final TodayActionBuilder? todayActionBuilder;

  @override
  Widget build(BuildContext context) {
    final currentDate = state.currentDate;
    final selectedDate = state.selectedDate;
    final art = skyArtAt(clock.now());
    final bloc = context.read<HomeBloc>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: art.overlayStyle,
      child: Column(
        children: [
          // The status bar sits on the sky's top colour, so the sky reads as
          // full-bleed and the pinned week strip has a band to sit under.
          ColoredBox(
            color: art.top,
            child: SizedBox(
              height: MediaQuery.paddingOf(context).top,
              width: double.infinity,
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: RefreshIndicator(
                onRefresh: () async => bloc.add(const RefreshHomeData()),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (currentDate != null && selectedDate != null) ...[
                      SliverToBoxAdapter(
                        child: SkyHero(
                          dateInfo: currentDate,
                          art: art,
                          actionBuilder: headerActionBuilder,
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: WeekHeaderDelegate(
                          week: currentDate.week,
                          selectedDate: selectedDate,
                          onDaySelected: (date) => bloc.add(DaySelected(date)),
                          art: art,
                          textScaler: MediaQuery.textScalerOf(context),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: MonthProgressBar(
                            today: currentDate.hijriDate,
                            daysInMonth: currentDate.daysInMonth,
                          ),
                        ),
                      ),
                    ],
                    if (progressSection case final section?)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        sliver: SliverToBoxAdapter(child: section),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      sliver: _UpcomingList(
                        state: state,
                        isReminderOn: isReminderOn,
                        onToggleReminder: onToggleReminder,
                        todayActionBuilder: todayActionBuilder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The fasting days from the selected day on, as a sliver.
class _UpcomingList extends StatelessWidget {
  const new({
    required this.state,
    required this.isReminderOn,
    required this.onToggleReminder,
    required this.todayActionBuilder,
  });

  final HomeState state;
  final bool Function(FastingType type) isReminderOn;
  final ValueChanged<FastingType> onToggleReminder;
  final TodayActionBuilder? todayActionBuilder;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = state.currentDate?.gregorianDate;
    final selected = state.selectedDate;
    final title =
        today == null ||
            selected == null ||
            CalendarDays.isSameDay(today, selected)
        ? localization.upcomingFastingDays
        : localization.fastingDaysFrom(
            DateFormat.MMMEd(localization.localeName).format(selected),
          );

    return SliverList.list(
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        if (state.upcomingFastingDays.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  localization.noUpcomingFasting,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          )
        else
          for (final day in state.upcomingFastingDays)
            FastingDayCard(
              fastingDay: day,
              isReminderOn: isReminderOn(day.primaryType),
              onToggleReminder: () => onToggleReminder(day.primaryType),
              // Only today can be acted on; later days haven't happened yet.
              extraAction: day.daysUntil == 0
                  ? todayActionBuilder?.call(day.gregorianDate, day.hijriDate)
                  : null,
            ),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
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
          Text(localization.errorOccurred),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<HomeBloc>().add(const LoadHomeData()),
            child: Text(localization.retry),
          ),
        ],
      ),
    );
  }
}
