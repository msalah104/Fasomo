import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/reminders/presentation/widgets/reminder_card.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderSettingsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return BlocConsumer<ReminderBloc, ReminderState>(
      listenWhen: (previous, current) =>
          current.status != ReminderStatus.error &&
          (current.failure != null || current.permissionDenied) &&
          current != previous,
      listener: (context, state) {
        final message = state.permissionDenied
            ? localization.notificationsDenied
            : switch (state.failure) {
                NotificationFailure() => localization.reminderSyncFailed,
                StorageFailure() ||
                CalendarFailure() ||
                TrackerFailure() ||
                null => localization.reminderSaveFailed,
              };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      builder: (context, state) {
        if (state.status == ReminderStatus.loading && state.reminders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ReminderStatus.error) {
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
                  onPressed: () {
                    context.read<ReminderBloc>().add(const LoadReminders());
                  },
                  child: Text(localization.retry),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.reminderSettings,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localization.manageReminders,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localization.activeReminders,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (state.reminders.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localization.noRemindersYet,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localization.addRemindersFromHome,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...state.reminders.map(
                  (reminder) => ReminderCard(reminder: reminder),
                ),
            ],
          ),
        );
      },
    );
  }
}
