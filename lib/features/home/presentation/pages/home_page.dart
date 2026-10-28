import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/home/presentation/widgets/current_date_card.dart';
import 'package:fasomo/features/home/presentation/widgets/fasting_day_card.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Today's date and the upcoming fasting days.
///
/// Reminder state comes from outside so this feature does not depend on the
/// reminders feature; the app shell wires the two together.
class HomePage extends StatelessWidget {
  const new({
    required this.isReminderOn,
    required this.onToggleReminder,
    super.key,
  });

  final bool Function(FastingType type) isReminderOn;
  final ValueChanged<FastingType> onToggleReminder;

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
  });

  final HomeState state;
  final bool Function(FastingType type) isReminderOn;
  final ValueChanged<FastingType> onToggleReminder;

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
        padding: const EdgeInsets.all(16),
        children: [
          if (currentDate != null) CurrentDateCard(dateInfo: currentDate),
          const SizedBox(height: 24),
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
