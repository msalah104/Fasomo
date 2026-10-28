import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/home/presentation/sky_period.dart';
import 'package:fasomo/features/home/presentation/widgets/fasting_day_card.dart';
import 'package:fasomo/features/home/presentation/widgets/month_progress_bar.dart';
import 'package:fasomo/features/home/presentation/widgets/sky_hero.dart';
import 'package:fasomo/features/home/presentation/widgets/week_strip.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The sky header with today's date, this week, the month so far and the
/// upcoming fasting days.
///
/// Reminder state and the header action come from outside so this feature
/// does not depend on the reminders or settings features; the app shell wires
/// them together.
class HomePage extends StatelessWidget {
  const new({
    required this.isReminderOn,
    required this.onToggleReminder,
    this.headerActionBuilder,
    super.key,
  });

  final bool Function(FastingType type) isReminderOn;
  final ValueChanged<FastingType> onToggleReminder;

  /// Builds the action shown on the sky, in the colour that reads on it.
  final Widget Function(Color color)? headerActionBuilder;

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
          ),
        };
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const new({
    required this.state,
    required this.isReminderOn,
    required this.onToggleReminder,
    required this.headerActionBuilder,
  });

  final HomeState state;
  final bool Function(FastingType type) isReminderOn;
  final ValueChanged<FastingType> onToggleReminder;
  final Widget Function(Color color)? headerActionBuilder;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentDate = state.currentDate;

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<HomeBloc>().add(const RefreshHomeData()),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          if (currentDate != null)
            _TodayHeader(
              dateInfo: currentDate,
              actionBuilder: headerActionBuilder,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The header's translated cards leave ~18 dp above this.
                const SizedBox(height: 8),
                Text(
                  localization.upcomingFastingDays,
                  style: theme.textTheme.headlineMedium,
                ),
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
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The sky header with the week strip overlapping its bottom edge, then the
/// month bar.
class _TodayHeader extends StatelessWidget {
  const new({required this.dateInfo, required this.actionBuilder});

  final HijriDateInfo dateInfo;
  final Widget Function(Color color)? actionBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkyHero(
          dateInfo: dateInfo,
          art: skyArtAt(clock.now()),
          actionBuilder: actionBuilder,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Transform.translate(
            offset: const Offset(0, -SkyHero.overlap),
            child: WeekStrip(week: dateInfo.week),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Transform.translate(
            offset: const Offset(0, -SkyHero.overlap + 12),
            child: MonthProgressBar(
              today: dateInfo.hijriDate,
              daysInMonth: dateInfo.daysInMonth,
            ),
          ),
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
